#include once "raylib.bi"
'#include once "./rlgl.bi"
'

' Note: rlgl functions need to be declared if not in raylib.bi
' Declare rlgl functions
declare sub rlPushMatrix cdecl alias "rlPushMatrix" ()
declare sub rlPopMatrix cdecl alias "rlPopMatrix" ()
declare sub rlTranslatef cdecl alias "rlTranslatef" (byval x as single, byval y as single, byval z as single)
declare sub rlRotatef cdecl alias "rlRotatef" (byval angle as single, byval x as single, byval y as single, byval z as single)
declare sub rlSetTexture cdecl alias "rlSetTexture" (byval id as uinteger)
declare sub rlBegin cdecl alias "rlBegin" (byval mode as integer)
declare sub rlEnd cdecl alias "rlEnd" ()
declare sub rlColor4f cdecl alias "rlColor4f" (byval r as single, byval g as single, byval b as single, byval a as single)
declare sub rlTexCoord2f cdecl alias "rlTexCoord2f" (byval x as single, byval y as single)
declare sub rlVertex3f cdecl alias "rlVertex3f" (byval x as single, byval y as single, byval z as single)

' Constants
const RL_QUADS = 7
const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 400
const BASE_FONT_SIZE = 60
const SCROLL_SPEED = 0.47
const STAR_COUNT = 100
const BGM_START_POS = 16.0

' Star data
type Star
    x as single
    y as single
    size as single
end type

' Global variables
dim shared stars(STAR_COUNT-1) as Star
dim shared textTextures() as RenderTexture2D
dim shared textLines() as string
dim shared scrollOffset as single = 0.0
dim shared paused as boolean = false

' Initialize stars
sub InitStars()
    for i as integer = 0 to STAR_COUNT-1
        stars(i).x = GetRandomValue(0, SCREEN_WIDTH)
        stars(i).y = GetRandomValue(0, SCREEN_HEIGHT)
        stars(i).size = GetRandomValue(5, 10) / 10.0
    next
end sub

' Load text from file
sub LoadTextFile(filename as string)
    dim fileNum as integer = freefile
    dim lineText as string
    dim lineCount as integer = 0

    ' Count lines first
    if open(filename for input as #fileNum) = 0 then
        while not eof(fileNum)
            line input #fileNum, lineText
            lineCount += 1
        wend
        close #fileNum
    else
        print "Error: Could not open " & filename
        return
    end if

    ' Allocate arrays
    redim textLines(lineCount-1)
    redim textTextures(lineCount-1)

    ' Read lines
    lineCount = 0
    if open(filename for input as #fileNum) = 0 then
        while not eof(fileNum)
            line input #fileNum, lineText
            ' Trim carriage return if exists
            if right(lineText, 1) = chr(13) then
                lineText = left(lineText, len(lineText)-1)
            end if
            textLines(lineCount) = lineText
            lineCount += 1
        wend
        close #fileNum
    end if
end sub

' Create text textures
sub CreateTextTextures()
    for i as integer = 0 to ubound(textLines)
        if len(textLines(i)) = 0 then
            ' Empty texture for blank lines
            textTextures(i).id = 0
            textTextures(i).texture.id = 0
            textTextures(i).depth.id = 0
            continue for
        end if

        dim fontSize as integer
        if i = 0 then
            fontSize = BASE_FONT_SIZE * 2
        else
            fontSize = BASE_FONT_SIZE
        end if

        dim textWidth as integer = MeasureText(textLines(i), fontSize)
        dim textHeight as integer = fontSize + 10

        if textWidth <= 0 or textHeight <= 0 then
            textTextures(i).id = 0
            textTextures(i).texture.id = 0
            textTextures(i).depth.id = 0
            continue for
        end if

        dim tex as RenderTexture2D = LoadRenderTexture(textWidth, textHeight)
        BeginTextureMode(tex)
        ClearBackground(BLANK)

        ' Use type<RayColor> syntax for color
        if i = 0 or i = 2 then
            DrawText(textLines(i), 0, 0, fontSize, YELLOW)
        else
            DrawText(textLines(i), 0, 0, fontSize, type<RayColor>(255, 232, 31, 255))
        end if

        EndTextureMode()
        SetTextureFilter(tex.texture, TEXTURE_FILTER_BILINEAR)

        textTextures(i) = tex
    next
end sub

' Main program
SetConfigFlags(FLAG_MSAA_4X_HINT or FLAG_WINDOW_HIDDEN)
InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in FreeBasic, <SPACE>:Start/Stop, <R>:Restart")

' Load and set icon
dim title_bar_icon as Image = LoadImage("./resources/ray.png")
SetWindowIcon(title_bar_icon)
UnloadImage(title_bar_icon)

' Initialize
InitStars()
LoadTextFile("../../resources/message.txt")
CreateTextTextures()

' Setup camera
dim camera as Camera3D
camera.position = type<Vector3>(0, 0, 0)
camera.target = type<Vector3>(0, 0, -1)
camera.up = type<Vector3>(0, 1, 0)
camera.fovy = 45.0
camera.projection = CAMERA_PERSPECTIVE

SetTargetFPS(60)

' Initialize audio
InitAudioDevice()
dim bgm_name as string = "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3"
dim bgm as Music = LoadMusicStream(bgm_name)
SeekMusicStream(bgm, BGM_START_POS)
PlayMusicStream(bgm)

dim delayShowWindow as integer  = 1

' Main loop
while not WindowShouldClose()
    UpdateMusicStream(bgm)

    ' Check for space key (pause/resume)
    if IsKeyPressed(KEY_SPACE) then
        paused = not paused
    end if

    ' Check for R key (restart)
    if IsKeyPressed(KEY_R) then
        scrollOffset = 0.0
        paused = false
        SeekMusicStream(bgm, BGM_START_POS)
    end if

    ' Update scroll position
    if not paused then
        scrollOffset += SCROLL_SPEED * GetFrameTime()
        ResumeMusicStream(bgm)
    else
        PauseMusicStream(bgm)
    end if

    if scrollOffset > (ubound(textLines) + 1) * 0.8 + 10.0 then
        scrollOffset = 0.0
    end if

    BeginDrawing()
    ClearBackground(BLACK)

    ' Draw stars
    for i as integer = 0 to STAR_COUNT-1
        DrawCircle(cint(stars(i).x), cint(stars(i).y), stars(i).size, WHITE)
    next

    BeginMode3D(camera)

    ' Draw text in 3D using low-level rlgl functions
    for i as integer = 0 to ubound(textLines)
        if textTextures(i).id = 0 then continue for

        dim texWidth as single = textTextures(i).texture.width_
        dim texHeight as single = textTextures(i).texture.height
        dim lineOffset as single = scrollOffset - i * 0.55

        if lineOffset > -2.0 and lineOffset < 15.0 then
            rlPushMatrix()

            dim moveY as single = lineOffset * 0.866
            dim moveZ as single = -lineOffset * 0.5
            rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ)
            rlRotatef(-70.0, 1.0, 0.0, 0.0)

            dim planeWidth as single = texWidth / 100.0
            dim planeHeight as single = texHeight / 100.0

            dim alpha as single = 1.0
            if lineOffset > 5.0 then
                alpha = 1.0 - ((lineOffset - 5.0) / 3.0)
            end if
            if lineOffset < 1.0 then
                alpha = lineOffset
            end if
            if alpha < 0.0 then alpha = 0.0
            if alpha > 1.0 then alpha = 1.0

            rlSetTexture(textTextures(i).texture.id)
            rlBegin(RL_QUADS)
            rlColor4f(1.0, 1.0, 1.0, alpha)

            rlTexCoord2f(0.0, 0.0)
            rlVertex3f(-planeWidth / 2, 0.0, 0.0)
            rlTexCoord2f(1.0, 0.0)
            rlVertex3f(planeWidth / 2, 0.0, 0.0)
            rlTexCoord2f(1.0, 1.0)
            rlVertex3f(planeWidth / 2, planeHeight, 0.0)
            rlTexCoord2f(0.0, 1.0)
            rlVertex3f(-planeWidth / 2, planeHeight, 0.0)

            rlEnd()
            rlSetTexture(0)
            rlPopMatrix()
        end if
    next

    EndMode3D()
    EndDrawing()
    if delayShowWindow = 0 then
        ClearWindowState(FLAG_WINDOW_HIDDEN) ' Show window
    end if
    if delayShowWindow >= 0 then
        delayShowWindow -= 1
    end if
wend

' Cleanup
for i as integer = 0 to ubound(textTextures)
    if textTextures(i).id <> 0 then
        UnloadRenderTexture(textTextures(i))
    end if
next

UnloadMusicStream(bgm)
CloseAudioDevice()
CloseWindow()
