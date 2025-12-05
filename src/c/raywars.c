#include "raylib.h"
#include "raymath.h"
#include "rlgl.h"
#include <stdio.h>

int main(void) {
  const int screenWidth = 800;
  const int screenHeight = 400;

  SetConfigFlags(FLAG_MSAA_4X_HINT);
  InitWindow(screenWidth, screenHeight, "Ray Wars Opening Crawl in C,   <SPACE>:Start / Stop, <R>:Restart");

  // Text content
  const char *text[] = {
        "Epic I",
        "MAY THE RAYLIB BE WITH YOU",
        "",
        "",
        "In a galaxy powered by code,",
        "brave programmers unite to",
        "build incredible software",
        "that brings joy to users",
        "across the digital realm.",
        "",
        "Armed with keyboards and",
        "determination, these heroes",
        "debug complex systems and",
        "craft elegant solutions to",
        "seemingly impossible",
        "technical challenges.",
        "",
        "Now, a new generation of",
        "developers embarks on an",
        "epic quest to master the",
        "ancient art of programming,",
        "seeking to create applications",
        "that will shape the future",
        "of technology forever....",
        "",
        "CLASSICALS.DE",
        "If you use this track",
        "in a project, please credit:",
        "www.classicals.de",
        "Licensing Information:",
        "Conducted by Philip Milman:",
        "https://pmmusic.pro/",
        "Creative Commons",
        "Attribution 3.0 Unported",
        "CC BY 3.0",
        "You are free to:",
        "Share copy and redistribute",
        "the material in any medium",
        "or format Adapt",
        "remix, transform, and",
        "build upon the material",
        "Under the following terms:",
        "Attribution You must give",
        "appropriate credit, provide",
        "a link to the website, and",
        "indicate if changes were made.",
        "You may do so",
        "in any reasonable manner, but",
        "not in any way that suggests",
        "the licensor endorses you",
        "or your use.",
        "No additional restrictions",
        "You may not apply legal terms",
        "or technological measures",
        "that legally restrict others",
        "from doing anything",
        "the license permits.",
        "Classicals.de @2025",
        "www.classicals.de",
  };

  int textCount = sizeof(text) / sizeof(text[0]);
  float scrollOffset = 0;
  float scrollSpeed = 0.47;
  bool paused = false;

  // Generate random star positions
  Vector2 stars[100];
  float starSizes[100];
  for (int i = 0; i < 100; i++) {
    stars[i].x = GetRandomValue(0, screenWidth);
    stars[i].y = GetRandomValue(0, screenHeight);
    starSizes[i] = GetRandomValue(5, 10) / 10.0f;
  }

  // Create textures for each text line
  const int baseFontSize = 60;
  // const int lineSpacing = 80;
  RenderTexture2D textTextures[sizeof(text) / sizeof(text[0])];

  for (int i = 0; i < textCount; i++) {
    // First line uses double font size
    int fontSize = (i == 0) ? baseFontSize * 2 : baseFontSize;
    int textWidth = MeasureText(text[i], fontSize);
    int textHeight = fontSize + 10;

    if (textWidth > 0 && textHeight > 0) {
      textTextures[i] = LoadRenderTexture(textWidth, textHeight);

      BeginTextureMode(textTextures[i]);
      ClearBackground(BLANK);
      Color textColor =
          (i == 0 || i == 2) ? YELLOW : (Color){255, 232, 31, 255};
      DrawText(text[i], 0, 0, fontSize, textColor);
      EndTextureMode();

      SetTextureFilter(textTextures[i].texture, TEXTURE_FILTER_BILINEAR);
    }
  }

  // Setup 3D camera
  Camera3D camera = {0};
  camera.position = (Vector3){0.0f, 0.0f, 0.0f};
  camera.target = (Vector3){0.0f, 0.0f, -1.0f};
  camera.up = (Vector3){0.0f, 1.0f, 0.0f};
  camera.fovy = 45.0f;
  camera.projection = CAMERA_PERSPECTIVE;

  SetTargetFPS(60);

  InitAudioDevice();
  //SetMasterVolume(1.0);
  const char * bgm_name= "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
  Music bgm = LoadMusicStream(bgm_name);
  const float BGM_START_POS = 16.0;
  SeekMusicStream(bgm, BGM_START_POS);
  PlayMusicStream(bgm);

  while (!WindowShouldClose()) {
    UpdateMusicStream(bgm);

    // Check for space key (pause/resume)
    if (IsKeyPressed(KEY_SPACE)) {
      paused = !paused;
    }

    // Check for R key (restart)
    if (IsKeyPressed(KEY_R)) {
      scrollOffset = 0.0;
      paused = false;
      SeekMusicStream(bgm, BGM_START_POS);
    }
    // Update scroll position (only if not paused)
    if (!paused) {
      scrollOffset += scrollSpeed * GetFrameTime();
      ResumeMusicStream(bgm);
    } else {
      PauseMusicStream(bgm);
    }

    // Reset when all lines have scrolled past
    if (scrollOffset > textCount * 0.8f + 10.0f) {
      scrollOffset = 0;
    }

    // Start drawing
    BeginDrawing();

    ClearBackground(BLACK);

    // Draw background stars
    for (int i = 0; i < 100; i++) {
      DrawCircle((int)stars[i].x, (int)stars[i].y, starSizes[i], WHITE);
    }

    // Begin 3D mode
    BeginMode3D(camera);

    // Draw each line as a separate plane
    for (int i = 0; i < textCount; i++) {
      int textWidth = textTextures[i].texture.width;
      int textHeight = textTextures[i].texture.height;

      // Calculate vertical offset for this line
      float lineOffset = scrollOffset - (i * 0.55f);

      // Only draw if visible
      if (lineOffset > -2.0f && lineOffset < 15.0f) {
        rlPushMatrix();

        // Calculate movement along Y and Z (60° angle)
        float moveY = lineOffset * 0.866f; // sin(60°)
        float moveZ = -lineOffset * 0.5f;  // cos(60°)

        rlTranslatef(0.0f, -3.0f + moveY, -5.0f + moveZ);

        // Tilt plane backward 70 degrees
        rlRotatef(-70.0f, 1.0f, 0.0f, 0.0f);

        // Plane size
        float planeWidth = textWidth / 100.0f;
        float planeHeight = textHeight / 100.0f;

        // Alpha fade (disappear near top)
        float alpha = 1.0f;

        // Fade out gradually when moving upward
        if (lineOffset > 5.0f) {
          alpha = 1.0f - ((lineOffset - 5.0f) / 3.0f);
          alpha = Clamp(alpha, 0.0f, 1.0f);
        }

        // Fade in near start
        if (lineOffset < 1.0f) {
          alpha = lineOffset;
          alpha = Clamp(alpha, 0.0f, 1.0f);
        }

        // Draw textured plane
        rlSetTexture(textTextures[i].texture.id);

        rlBegin(RL_QUADS);
        rlColor4f(1.0f, 1.0f, 1.0f, alpha);

        // Quad vertices
        rlTexCoord2f(0.0f, 0.0f);
        rlVertex3f(-planeWidth / 2, 0.0f, 0.0f);
        rlTexCoord2f(1.0f, 0.0f);
        rlVertex3f(planeWidth / 2, 0.0f, 0.0f);
        rlTexCoord2f(1.0f, 1.0f);
        rlVertex3f(planeWidth / 2, planeHeight, 0.0f);
        rlTexCoord2f(0.0f, 1.0f);
        rlVertex3f(-planeWidth / 2, planeHeight, 0.0f);

        rlEnd();
        rlSetTexture(0);

        rlPopMatrix();
      }
    }

    EndMode3D();
    EndDrawing();
  }

  // Unload textures
  for (int i = 0; i < textCount; i++) {
    UnloadRenderTexture(textTextures[i]);
  }

  CloseWindow();

  return 0;
}
