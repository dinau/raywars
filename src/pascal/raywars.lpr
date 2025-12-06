program raywars;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
  Classes, SysUtils, Math, raylib, raymath, rlgl;

const
  screenWidth = 800;
  screenHeight = 400;

var
  text: array of string;
  textCount: Integer;
  scrollOffset: Single;
  scrollSpeed: Single;
  paused: Boolean;
  stars: array[0..99] of TVector2;
  starSizes: array[0..99] of Single;
  textTextures: array of TRenderTexture2D;
  camera: TCamera3D;
  i: Integer;
  baseFontSize: Integer;
  fontSize, textWidth, textHeight: Integer;
  textColor: TColor;
  lineOffset, moveY, moveZ: Single;
  planeWidth, planeHeight: Single;
  alpha: Single;

  lineList: TStringList;
  bgm: TMusic;

const
  messageFile = '../../resources/message.txt';
  bgm_name = '../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3';
  BGM_START_POS = 16.0;

begin
  SetConfigFlags(FLAG_MSAA_4X_HINT);
  InitWindow(screenWidth, screenHeight, 'Ray Wars Opening Crawl in Pascal,   <SPACE>:Start / Stop, <R>:Restart');

  // Read text file
  lineList := TStringList.Create;
  try
    if FileExists(messageFile) then
    begin
      lineList.LoadFromFile(messageFile);
      textCount := lineList.Count;
      SetLength(text, textCount);
      for i := 0 to textCount - 1 do
      begin
        text[i] := lineList[i];
      end;
    end
    else
    begin
      WriteLn('Error: File not found: ' + messageFile);
      CloseWindow();
      Exit;
    end;
  finally
    lineList.Free;
  end;

  scrollOffset := 0;
  scrollSpeed := 0.47;
  paused := False;

  // Generate random star positions
  for i := 0 to 99 do
  begin
    stars[i].x := GetRandomValue(0, screenWidth);
    stars[i].y := GetRandomValue(0, screenHeight);
    starSizes[i] := GetRandomValue(5, 10) / 10.0;
  end;

  // Create textures for each text line
  baseFontSize := 60;
  SetLength(textTextures, textCount);

  for i := 0 to textCount - 1 do
  begin
    // First line uses double font size
    if i = 0 then
      fontSize := baseFontSize * 2
    else
      fontSize := baseFontSize;

    textWidth := MeasureText(PChar(text[i]), fontSize);
    textHeight := fontSize + 10;

    if (textWidth > 0) and (textHeight > 0) then
    begin
      textTextures[i] := LoadRenderTexture(textWidth, textHeight);

      BeginTextureMode(textTextures[i]);
      ClearBackground(BLANK);

      if (i = 0) or (i = 2) then
        textColor := YELLOW
      else
        textColor := ColorCreate(255, 232, 31, 255);

      DrawText(PChar(text[i]), 0, 0, fontSize, textColor);
      EndTextureMode();

      SetTextureFilter(textTextures[i].texture, TEXTURE_FILTER_BILINEAR);
    end;
  end;

  // Setup 3D camera
  camera.position := Vector3Create(0.0, 0.0, 0.0);
  camera.target := Vector3Create(0.0, 0.0, -1.0);
  camera.up := Vector3Create(0.0, 1.0, 0.0);
  camera.fovy := 45.0;
  camera.projection := CAMERA_PERSPECTIVE;

  SetTargetFPS(60);

  InitAudioDevice();
  //SetMasterVolume(1.0);
  bgm := LoadMusicStream(bgm_name);
  SeekMusicStream(bgm, BGM_START_POS);
  PlayMusicStream(bgm);

  while not WindowShouldClose() do
  begin
    UpdateMusicStream(bgm);
    // Check for space key (pause/resume)
    if IsKeyPressed(KEY_SPACE) then
      paused := not paused;

    // Check for R key (restart)
    if IsKeyPressed(KEY_R) then
    begin
      scrollOffset := 0.0;
      paused := False;
      SeekMusicStream(bgm, BGM_START_POS);
    end;

    // Update scroll position (only if not paused)
    if not paused then
    begin
      scrollOffset := scrollOffset + scrollSpeed * GetFrameTime();
      ResumeMusicStream(bgm);
    end
    else
     PauseMusicStream(bgm);

    // Reset when all lines have scrolled past
    if scrollOffset > textCount * 0.8 + 10.0 then
      scrollOffset := 0;

    // Start drawing
    BeginDrawing();
    ClearBackground(BLACK);

    // Draw background stars
    for i := 0 to 99 do
    begin
      DrawCircle(Trunc(stars[i].x), Trunc(stars[i].y), starSizes[i], WHITE);
    end;

    // Begin 3D mode
    BeginMode3D(camera);

    // Draw each line as a separate plane
    for i := 0 to textCount - 1 do
    begin
      textWidth := textTextures[i].texture.width;
      textHeight := textTextures[i].texture.height;

      // Calculate vertical offset for this line
      lineOffset := scrollOffset - (i * 0.55);

      // Only draw if visible
      if (lineOffset > -2.0) and (lineOffset < 15.0) then
      begin
        rlPushMatrix();

        // Calculate movement along Y and Z (60° angle)
        moveY := lineOffset * 0.866; // sin(60°)
        moveZ := -lineOffset * 0.5;  // cos(60°)

        rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ);

        // Tilt plane backward 70 degrees
        rlRotatef(-70.0, 1.0, 0.0, 0.0);

        // Plane size
        planeWidth := textWidth / 100.0;
        planeHeight := textHeight / 100.0;

        // Alpha fade (disappear near top)
        alpha := 1.0;

        // Fade out gradually when moving upward
        if lineOffset > 5.0 then
        begin
          alpha := 1.0 - ((lineOffset - 5.0) / 3.0);
          alpha := Clamp(alpha, 0.0, 1.0);
        end;

        // Fade in near start
        if lineOffset < 1.0 then
        begin
          alpha := lineOffset;
          alpha := Clamp(alpha, 0.0, 1.0);
        end;

        // Draw textured plane
        rlSetTexture(textTextures[i].texture.id);

        rlBegin(RL_QUADS);
        rlColor4f(1.0, 1.0, 1.0, alpha);

        // Quad vertices
        rlTexCoord2f(0.0, 0.0);
        rlVertex3f(-planeWidth / 2, 0.0, 0.0);
        rlTexCoord2f(1.0, 0.0);
        rlVertex3f(planeWidth / 2, 0.0, 0.0);
        rlTexCoord2f(1.0, 1.0);
        rlVertex3f(planeWidth / 2, planeHeight, 0.0);
        rlTexCoord2f(0.0, 1.0);
        rlVertex3f(-planeWidth / 2, planeHeight, 0.0);

        rlEnd();
        rlSetTexture(0);

        rlPopMatrix();
      end;
    end;

    EndMode3D();
    EndDrawing();
  end;

  // Unload textures
  for i := 0 to textCount - 1 do
  begin
    UnloadRenderTexture(textTextures[i]);
  end;

  CloseWindow();
end.
