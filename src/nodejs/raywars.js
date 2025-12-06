const r = require('raylib')
const fs = require('fs')

const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 400

function main() {
    r.SetConfigFlags(r.FLAG_MSAA_4X_HINT)
    r.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Node.js,   <SPACE>:Start / Stop, <R>:Restart")

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
            x: r.GetRandomValue(0, SCREEN_WIDTH),
            y: r.GetRandomValue(0, SCREEN_HEIGHT)
        })
        starSizes.push(r.GetRandomValue(5, 10) / 10.0)
    }

    // Create textures for each text line
    const baseFontSize = 60
    const textTextures = []

    for (let i = 0; i < text.length; i++) {
        const line = text[i]
        // First line uses double font size
        const fontSize = (i === 0) ? baseFontSize * 2 : baseFontSize
        const textWidth = r.MeasureText(line, fontSize)
        const textHeight = fontSize + 10

        if (textWidth > 0 && textHeight > 0) {
            const texture = r.LoadRenderTexture(textWidth, textHeight)

            r.BeginTextureMode(texture)
            r.ClearBackground(r.BLANK)
            const textColor = (i === 0 || i === 1) ? r.YELLOW : r.Color(255, 232, 31, 255)
            r.DrawText(line, 0, 0, fontSize, textColor)
            r.EndTextureMode()

            r.SetTextureFilter(texture.texture, r.TEXTURE_FILTER_BILINEAR)
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
        projection: r.CAMERA_PERSPECTIVE
    }

    r.SetTargetFPS(60)

    r.InitAudioDevice()
    const bgmName = '../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3'
    const bgm = r.LoadMusicStream(bgmName)
    const BGM_START_POS = 16.0
    r.SeekMusicStream(bgm, BGM_START_POS)
    r.PlayMusicStream(bgm)

    while (!r.WindowShouldClose()) {
        r.UpdateMusicStream(bgm)

        // Check for space key (pause/resume)
        if (r.IsKeyPressed(r.KEY_SPACE)) {
            paused = !paused
        }

        // Check for R key (restart)
        if (r.IsKeyPressed(r.KEY_R)) {
            scrollOffset = 0.0
            paused = false
            r.SeekMusicStream(bgm, BGM_START_POS)
        }

        // Update scroll position (only if not paused)
        if (!paused) {
            scrollOffset += scrollSpeed * r.GetFrameTime()
            r.ResumeMusicStream(bgm)
        } else {
            r.PauseMusicStream(bgm)
        }

        // Reset when all lines have scrolled past
        if (scrollOffset > textCount * 0.8 + 10.0) {
            scrollOffset = 0.0
        }

        // Start drawing
        r.BeginDrawing()
        r.ClearBackground(r.BLACK)

        // Draw background stars
        for (let i = 0; i < stars.length; i++) {
            r.DrawCircle(Math.floor(stars[i].x), Math.floor(stars[i].y), starSizes[i], r.WHITE)
        }

        // Begin 3D mode
        r.BeginMode3D(camera)

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
                r.rlPushMatrix()

                // Calculate movement along Y and Z (60° angle)
                const moveY = lineOffset * 0.866  // sin(60°)
                const moveZ = -lineOffset * 0.5   // cos(60°)

                r.rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ)

                // Tilt plane backward 70 degrees
                r.rlRotatef(-70.0, 1.0, 0.0, 0.0)

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
                r.rlSetTexture(texture.texture.id)

                r.rlBegin(r.RL_QUADS)
                r.rlColor4f(1.0, 1.0, 1.0, alpha)

                // Quad vertices
                r.rlTexCoord2f(0.0, 0.0); r.rlVertex3f(-planeWidth/2, 0.0, 0.0)
                r.rlTexCoord2f(1.0, 0.0); r.rlVertex3f(planeWidth/2, 0.0, 0.0)
                r.rlTexCoord2f(1.0, 1.0); r.rlVertex3f(planeWidth/2, planeHeight, 0.0)
                r.rlTexCoord2f(0.0, 1.0); r.rlVertex3f(-planeWidth/2, planeHeight, 0.0)

                r.rlEnd()
                r.rlSetTexture(0)

                r.rlPopMatrix()
            }
        }

        r.EndMode3D()
        r.EndDrawing()
    }

    // Unload textures
    for (let texture of textTextures) {
        if (texture !== null) {
            r.UnloadRenderTexture(texture)
        }
    }

    r.CloseWindow()
}

main()
