# raywars.nim
# 3D Star Wars Opening Crawl with textured planes
import raylib_tiny
import std/[syncio,strutils]

when defined(nim_compiler):
  when defined(windows):
    include ./res/resource

proc rand*(): int32 {.cdecl,importc.}
proc clamp(x, a, b:float32): float32 =
  if x <= a:
    return a
  if x >=  b:
    return b

# import random
let BLANK = Color(r: 0, g: 0, b: 0, a: 255)
let BLACK = Color(r: 0, g: 0, b: 0, a: 255)
let YELLOW = Color(r: 253, g: 249, b: 0, a: 255)
let WHITE = Color(r: 255, g: 255, b: 255, a: 255)
const
  SCREEN_WIDTH:cint = 800
  SCREEN_HEIGHT :cint= 400
  BASE_FONT_SIZE :cint= 60
  SCROLL_SPEED :cfloat= 0.47f
  STAR_COUNT:cint = 100

# Text content
var textLines: seq[string] = @[]
var f:File
var line:string

when defined(nim_compiler):
  if open(f, "../../resources/message.txt"):
    while readLine(f, line):
      textLines.add(strip(line,chars={'\n','\r'}))
else:
  if open(f, "../../../resources/message.txt"):
    while readLine(f, line):
      textLines.add(strip(line,chars={'\n','\r'}))

#------
# main
#------
proc main() =
  # Initialize window
  setConfigFlags(FLAG_MSAA_4X_HINT or FLAG_WINDOW_HIDDEN)
  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Nimony v0.2,    <SPACE>:Start / Stop, <R>:Restart")

  when defined(nim_compiler):
    let titleBarIcon = loadImage("./resources/ray.png")
  else:
    let titleBarIcon = loadImage("../resources/ray.png")

  setWindowIcon(titleBarIcon)
  unloadImage(titleBarIcon)


  # Generate random stars
  when defined(nim_compiler):
    # for nim
    var
      stars: array[STAR_COUNT, Vector2]
      starSizes: array[STAR_COUNT, float32]
  else:
    # for nimony
    var
      stars: array[STAR_COUNT, Vector2] = {:}
      starSizes: array[STAR_COUNT, float32] = {:}

  for i in 0..<STAR_COUNT:
    stars[i] = Vector2(x: (rand() mod SCREEN_WIDTH).float32, y: (rand() mod SCREEN_HEIGHT).float32)
    starSizes[i] = clamp((rand() mod 11).float32,5,10) / 10.0f

  # Create textures for each line
  var textTextures: seq[RenderTexture2D] = @[]
  for i in 0..<textLines.len:
    if textLines[i].len == 0:
      textTextures.add(RenderTexture2D(id: 0, texture: Texture2D(id: 0), depth: Texture2D(id: 0)))
      continue

    let fontSize = if i == 0: BASE_FONT_SIZE * 2 else: BASE_FONT_SIZE
    when defined(nim_compiler):
      var str = textLines[i].cstring
    else:
      var str = textLines[i].toCString

    let textWidth = measureText(str, fontSize)
    let textHeight = (fontSize + 10).int32

    if textWidth <= 0 or textHeight <= 0:
      textTextures.add(RenderTexture2D(id: 0, texture: Texture2D(id: 0), depth: Texture2D(id: 0)))
      continue

    var tex = loadRenderTexture(textWidth, textHeight)
    beginTextureMode(tex)
    clearBackground(BLANK)
    let color = if i == 0 or i == 2: YELLOW else: Color(r: 255, g: 232, b: 31, a: 255)
    drawText(str, 0, 0, fontSize.int32, color)
    endTextureMode()
    setTextureFilter(tex.texture, TEXTURE_FILTER_BILINEAR)
    textTextures.add(tex)

  # 3D Camera
  var camera = Camera3D(
    position: Vector3(x: 0.0f, y: 0.0f, z: 0.0f),
    target: Vector3(x: 0.0f, y: 0.0f, z: -1.0f),
    up: Vector3(x: 0.0f, y: 1.0f, z: 0.0f),
    fovy: 45.0f,
    projection: CAMERA_PERSPECTIVE
  )

  var scrollOffset = 0.0f
  var paused = false

  setTargetFPS(60)
  initAudioDevice()
  #setMasterVolume(1.0)

  when defined(nim_compiler):
    const bgm_name: cstring = "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3"
  else:
    const bgm_name: cstring = "../../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3"

  let bgm = loadMusicStream(bgm_name)
  const BGM_START_POS = 16.0'f32
  seekMusicStream(bgm, BGM_START_POS)
  playMusicStream(bgm)

  var delayShowWindow: int32 = 1 # For eliminating flicker at startup

  # Main loop
  while not windowShouldClose():
    updateMusicStream(bgm)
    # Check for space key (pause/resume)
    if isKeyPressed(KEY_SPACE):
      paused = not paused

    # Check for R key (restart)
    if isKeyPressed(KEY_R):
      scrollOffset = 0.0f
      paused = false
      seekMusicStream(bgm, BGM_START_POS);

    # Update scroll position (only if not paused)
    if not paused:
      scrollOffset += SCROLL_SPEED * getFrameTime()
      resumeMusicStream(bgm)
    else:
      pauseMusicStream(bgm)

    if scrollOffset > textLines.len.float32 * 0.8f + 10.0f:
      scrollOffset = 0.0f

    beginDrawing()
    clearBackground(BLACK)

    # Draw stars
    for i in 0..<STAR_COUNT:
      drawCircle(stars[i].x.int32, stars[i].y.int32, starSizes[i], WHITE)

    # 3D Mode
    beginMode3D(camera)

    for i in 0..<textLines.len:
      if textTextures[i].id == 0:
        continue

      let texWidth  = textTextures[i].texture.width.float32
      let texHeight = textTextures[i].texture.height.float32
      let lineOffset = scrollOffset - i.float32 * 0.55f

      if lineOffset > -2.0f and lineOffset < 15.0f:
        pushMatrix()

        let moveY = lineOffset * 0.866f
        let moveZ = -lineOffset * 0.5f
        translatef(0.0f, -3.0f + moveY, -5.0f + moveZ)
        rotatef(-70.0f, 1.0f, 0.0f, 0.0f)

        let planeWidth = texWidth / 100.0f
        let planeHeight = texHeight / 100.0f

        var alpha = 1.0f
        if lineOffset > 5.0f:
          alpha = 1.0f - ((lineOffset - 5.0f) / 3.0f)
        if lineOffset < 1.0f:
          alpha = lineOffset
        alpha = clamp(alpha, 0.0f, 1.0f)

        setTexture(textTextures[i].texture.id)
        rlBegin(RL_QUADS)
        color4f(1.0f, 1.0f, 1.0f, alpha)

        texCoord2f(0.0f, 0.0f); vertex3f(-planeWidth/2, 0.0f, 0.0f)
        texCoord2f(1.0f, 0.0f); vertex3f( planeWidth/2, 0.0f, 0.0f)
        texCoord2f(1.0f, 1.0f); vertex3f( planeWidth/2, planeHeight, 0.0f)
        texCoord2f(0.0f, 1.0f); vertex3f(-planeWidth/2, planeHeight, 0.0f)

        rlEnd()
        setTexture(0)
        popMatrix()

    endMode3D()
    endDrawing()

    if delayShowWindow == 0:
      clearWindowState(FLAG_WINDOW_HIDDEN) #-- Show window
    if delayShowWindow >= 0:
      dec delayShowWindow

  #end while
  closeWindow()

#------
# main
#------
main()
