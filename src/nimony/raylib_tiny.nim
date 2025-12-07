const RL_QUADS*:int32 = 7
const RL_TRIANGLES* = 4
const RL_LINES*:int32 = 1
const KEY_SPACE*:int32  = 32
const KEY_R*:int32  = 82
const FLAG_MSAA_4X_HINT*:uint32 = 32
const CAMERA_PERSPECTIVE*:cint = 0
const TEXTURE_FILTER_BILINEAR*:cint = 1
type
  struct_Vector2* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
  Vector2* = struct_Vector2
  struct_Vector3* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    z*: cfloat
  Vector3* = struct_Vector3
  struct_Camera3D* {.bycopy.} = object
    position*: Vector3
    target*: Vector3
    up*: Vector3
    fovy*: cfloat
    projection*: cint
  Camera3D* = struct_Camera3D
  Camera* = Camera3D
  struct_Color* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8
  Color* = struct_Color
  struct_Texture* {.bycopy.} = object
    id*: cuint
    width*: cint
    height*: cint
    mipmaps*: cint
    format*: cint
  Texture* = struct_Texture
  Texture2D* = Texture
  struct_RenderTexture* {.bycopy.} = object
    id*: cuint
    texture*: Texture
    depth*: Texture
  RenderTexture* = struct_RenderTexture
  RenderTexture2D* = RenderTexture
  struct_Rectangle* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    width*: cfloat
    height*: cfloat
  Rectangle* = struct_Rectangle
  struct_Image* {.bycopy.} = object
    data*: pointer
    width*: cint
    height*: cint
    mipmaps*: cint
    format*: cint
  Image* = struct_Image
  struct_GlyphInfo* {.bycopy.} = object
    value*: cint
    offsetX*: cint
    offsetY*: cint
    advanceX*: cint
    image*: Image
  GlyphInfo* = struct_GlyphInfo
  struct_Font* {.bycopy.} = object
    baseSize*: cint
    glyphCount*: cint
    glyphPadding*: cint
    texture*: Texture2D
    recs*: ptr Rectangle
    glyphs*: ptr GlyphInfo
  Font* = struct_Font
  struct_rAudioBuffer* = object
  struct_rAudioProcessor* = object
  rAudioBuffer* = struct_rAudioBuffer ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:460:29
  rAudioProcessor* = struct_rAudioProcessor ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:461:32
  struct_AudioStream* {.pure, inheritable, bycopy.} = object
    buffer*: ptr rAudioBuffer ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:464:16
    processor*: ptr rAudioProcessor
    sampleRate*: cuint
    sampleSize*: cuint
    channels*: cuint
  AudioStream* = struct_AudioStream ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:471:3
  struct_Music* {.pure, inheritable, bycopy.} = object
    stream*: AudioStream     ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:480:16
    frameCount*: cuint
    looping*: bool
    ctxType*: cint
    ctxData*: pointer
  Music* = struct_Music      ## Generated based on C:/000imguin_dev/imguinz_data/00raywars_data/libs/win/raylib/include/raylib.h:487:3
proc setConfigFlags*(flags: cuint): void {.cdecl, importc: "SetConfigFlags".}
proc initWindow*(width: cint; height: cint; title: cstring): void {.cdecl, importc: "InitWindow".}
proc setTargetFPS*(fps: cint): void {.cdecl, importc: "SetTargetFPS".}
proc measureText*(text: cstring; fontSize: cint): cint {.cdecl, importc: "MeasureText".}
proc measureTextEx*(font: Font; text: cstring; fontSize: cfloat; spacing: cfloat): Vector2 {.  cdecl, importc: "MeasureTextEx".}
proc loadRenderTexture*(width: cint; height: cint): RenderTexture2D {.cdecl, importc: "LoadRenderTexture".}
proc beginTextureMode*(target: RenderTexture2D): void {.cdecl, importc: "BeginTextureMode".}
proc clearBackground*(color: Color): void {.cdecl, importc: "ClearBackground".}
proc drawText*(text: cstring; posX: cint; posY: cint; fontSize: cint; color: Color): void {.cdecl, importc: "DrawText".}
proc drawTextEx*(font: Font; text: cstring; position: Vector2; fontSize: cfloat; spacing: cfloat; tint: Color): void {.cdecl, importc: "DrawTextEx".}
proc drawTextPro*(font: Font; text: cstring; position: Vector2; origin: Vector2; rotation: cfloat; fontSize: cfloat; spacing: cfloat; tint: Color): void {.cdecl, importc: "DrawTextPro".}
proc drawTextCodepoint*(font: Font; codepoint: cint; position: Vector2; fontSize: cfloat; tint: Color): void {.cdecl, importc: "DrawTextCodepoint".}
proc drawTextCodepoints*(font: Font; codepoints: ptr cint; codepointCount: cint; position: Vector2; fontSize: cfloat; spacing: cfloat; tint: Color): void {.cdecl, importc: "DrawTextCodepoints".}
proc endTextureMode*(): void {.cdecl, importc: "EndTextureMode".}
proc setTextureFilter*(texture: Texture2D; filter: cint): void {.cdecl, importc: "SetTextureFilter".}
proc windowShouldClose*(): bool {.cdecl, importc: "WindowShouldClose".}
proc isKeyPressed*(key: cint): bool {.cdecl, importc: "IsKeyPressed".}
proc getFrameTime*(): cfloat {.cdecl, importc: "GetFrameTime".}
proc beginDrawing*(): void {.cdecl, importc: "BeginDrawing".}
proc drawCircle*(centerX: cint; centerY: cint; radius: cfloat; color: Color): void {.  cdecl, importc: "DrawCircle".}
proc beginMode3D*(camera: Camera3D): void {.cdecl, importc: "BeginMode3D".}
proc pushMatrix*(): void {.cdecl, importc: "rlPushMatrix".}
proc translatef*(x: cfloat; y: cfloat; z: cfloat): void {.cdecl, importc: "rlTranslatef".}
proc rotatef*(angle: cfloat; x: cfloat; y: cfloat; z: cfloat): void {.cdecl, importc: "rlRotatef".}
proc texCoord2f*(x: cfloat; y: cfloat): void {.cdecl, importc: "rlTexCoord2f".}
proc vertex3f*(x: cfloat; y: cfloat; z: cfloat): void {.cdecl, importc: "rlVertex3f".}
proc rlEnd*(): void {.cdecl, importc: "rlEnd".}
proc popMatrix*(): void {.cdecl, importc: "rlPopMatrix".}
proc endMode3D*(): void {.cdecl, importc: "EndMode3D".}
proc endDrawing*(): void {.cdecl, importc: "EndDrawing".}
proc closeWindow*(): void {.cdecl, importc: "CloseWindow".}
proc rlBegin*(mode: cint): void {.cdecl, importc: "rlBegin".}
proc color4f*(x: cfloat; y: cfloat; z: cfloat; w: cfloat): void {.cdecl, importc: "rlColor4f".}
proc setTexture*(id: cuint): void {.cdecl, importc: "rlSetTexture".}

proc initAudioDevice*(): void {.cdecl, importc: "InitAudioDevice".}
proc setMasterVolume*(volume: cfloat): void {.cdecl, importc: "SetMasterVolume".}
proc loadMusicStream*(fileName: cstring): Music {.cdecl, importc: "LoadMusicStream".}
proc seekMusicStream*(music: Music; position: cfloat): void {.cdecl, importc: "SeekMusicStream".}
proc resumeMusicStream*(music: Music): void {.cdecl, importc: "ResumeMusicStream".}
proc pauseAudioStream*(stream: AudioStream): void {.cdecl, importc: "PauseAudioStream".}
proc playMusicStream*(music: Music): void {.cdecl, importc: "PlayMusicStream".}
proc updateMusicStream*(music: Music): void {.cdecl, importc: "UpdateMusicStream".}
proc pauseMusicStream*(music: Music): void {.cdecl, importc: "PauseMusicStream".}
proc loadImage*(fileName: cstring): Image {.cdecl, importc: "LoadImage".}
proc setWindowIcon*(image: Image): void {.cdecl, importc: "SetWindowIcon".}
proc unloadImage*(image: Image): void {.cdecl, importc: "UnloadImage".}
