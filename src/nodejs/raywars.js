const rl = require('raylib')
const fs = require('fs')

const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 400

function main() {
    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Node.js,   <SPACE>:Start / Stop, <R>:Restart")

    const title_bar_icon = rl.LoadImage("../../resources/ray.png")
    rl.SetWindowIcon(title_bar_icon)
    rl.UnloadImage(title_bar_icon)

    // Read text content
    const text = []
    const fileContent = fs.readFileSync("../../resources/message.txt", "utf-8")
    const lines = fileContent.split('\n')
    for (let line of lines) {
        text.push(line.replace(/\r/g, ''))
    }

    const textCount = text.length
    let scrollOffset = 0.0
    const scrollSpeed = 0.47
    let paused = false

    // Generate random star positions
    const stars = []
    const starSizes = []
    for (let i = 0; i < 100; i++) {
        stars.push({
            x: rl.GetRandomValue(0, SCREEN_WIDTH),
            y: rl.GetRandomValue(0, SCREEN_HEIGHT)
        })
        starSizes.push(rl.GetRandomValue(5, 10) / 10.0)
    }

    // Create textures for each text line
    const baseFontSize = 60
    const textTextures = []

    for (let i = 0; i < text.length; i++) {
        const line = text[i]
        // First line uses double font size
        const fontSize = (i === 0) ? baseFontSize * 2 : baseFontSize
        const textWidth = rl.MeasureText(line, fontSize)
        const textHeight = fontSize + 10

        if (textWidth > 0 && textHeight > 0) {
            const texture = rl.LoadRenderTexture(textWidth, textHeight)

            rl.BeginTextureMode(texture)
            rl.ClearBackground(rl.BLANK)
            const textColor = (i === 0 || i === 1) ? rl.YELLOW : rl.Color(255, 232, 31, 255)
            rl.DrawText(line, 0, 0, fontSize, textColor)
            rl.EndTextureMode()

            rl.SetTextureFilter(texture.texture, rl.TEXTURE_FILTER_BILINEAR)
            textTextures.push(texture)
        } else {
            textTextures.push(null)
        }
    }

    // Setup 3D camera
    const camera = {
        position: { x: 0.0, y: 0.0, z: 0.0 },
        target: { x: 0.0, y: 0.0, z: -1.0 },
        up: { x: 0.0, y: 1.0, z: 0.0 },
        fovy: 45.0,
        projection: rl.CAMERA_PERSPECTIVE
    }

    rl.SetTargetFPS(60)

    rl.InitAudioDevice()
    const bgmName = '../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3'
    const bgm = rl.LoadMusicStream(bgmName)
    const BGM_START_POS = 16.0
    rl.SeekMusicStream(bgm, BGM_START_POS)
    rl.PlayMusicStream(bgm)

    while (!rl.WindowShouldClose()) {
        rl.UpdateMusicStream(bgm)

        // Check for space key (pause/resume)
        if (rl.IsKeyPressed(rl.KEY_SPACE)) {
            paused = !paused
        }

        // Check for R key (restart)
        if (rl.IsKeyPressed(rl.KEY_R)) {
            scrollOffset = 0.0
            paused = false
            rl.SeekMusicStream(bgm, BGM_START_POS)
        }

        // Update scroll position (only if not paused)
        if (!paused) {
            scrollOffset += scrollSpeed * rl.GetFrameTime()
            rl.ResumeMusicStream(bgm)
        } else {
            rl.PauseMusicStream(bgm)
        }

        // Reset when all lines have scrolled past
        if (scrollOffset > textCount * 0.8 + 10.0) {
            scrollOffset = 0.0
        }

        // Start drawing
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        // Draw background stars
        for (let i = 0; i < stars.length; i++) {
            rl.DrawCircle(Math.floor(stars[i].x), Math.floor(stars[i].y), starSizes[i], rl.WHITE)
        }

        // Begin 3D mode
        rl.BeginMode3D(camera)

        // Draw each line as a separate plane
        for (let i = 0; i < textTextures.length; i++) {
            const texture = textTextures[i]
            if (texture === null) {
                continue
            }

            const textWidth = texture.texture.width
            const textHeight = texture.texture.height

            // Calculate vertical offset for this line
            const lineOffset = scrollOffset - (i * 0.55)

            // Only draw if visible
            if (lineOffset > -2.0 && lineOffset < 15.0) {
                rl.rlPushMatrix()

                // Calculate movement along Y and Z (60° angle)
                const moveY = lineOffset * 0.866  // sin(60°)
                const moveZ = -lineOffset * 0.5   // cos(60°)

                rl.rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ)

                // Tilt plane backward 70 degrees
                rl.rlRotatef(-70.0, 1.0, 0.0, 0.0)

                // Plane size
                const planeWidth = textWidth / 100.0
                const planeHeight = textHeight / 100.0

                // Alpha fade (disappear near top)
                let alpha = 1.0

                // Fade out gradually when moving upward
                if (lineOffset > 5.0) {
                    alpha = 1.0 - ((lineOffset - 5.0) / 3.0)
                    alpha = Math.max(0.0, Math.min(1.0, alpha))  // clamp
                }

                // Fade in near start
                if (lineOffset < 1.0) {
                    alpha = lineOffset
                    alpha = Math.max(0.0, Math.min(1.0, alpha))  // clamp
                }

                // Draw textured plane
                rl.rlSetTexture(texture.texture.id)

                rl.rlBegin(rl.RL_QUADS)
                rl.rlColor4f(1.0, 1.0, 1.0, alpha)

                // Quad vertices
                rl.rlTexCoord2f(0.0, 0.0); rl.rlVertex3f(-planeWidth/2, 0.0, 0.0)
                rl.rlTexCoord2f(1.0, 0.0); rl.rlVertex3f(planeWidth/2, 0.0, 0.0)
                rl.rlTexCoord2f(1.0, 1.0); rl.rlVertex3f(planeWidth/2, planeHeight, 0.0)
                rl.rlTexCoord2f(0.0, 1.0); rl.rlVertex3f(-planeWidth/2, planeHeight, 0.0)

                rl.rlEnd()
                rl.rlSetTexture(0)

                rl.rlPopMatrix()
            }
        }

        rl.EndMode3D()
        rl.EndDrawing()
    }

    // Unload textures
    for (let texture of textTextures) {
        if (texture !== null) {
            rl.UnloadRenderTexture(texture)
        }
    }

    rl.CloseWindow()
}

main()
