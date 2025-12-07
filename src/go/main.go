package main

import (
	rl "github.com/gen2brain/raylib-go/raylib"
	"os"
	"strings"
)

const (
	SCREEN_WIDTH    = 800
	SCREEN_HEIGHT   = 400
	BASE_FONT_SIZE  = 60.0
	SCROLL_SPEED    = 0.47
	STAR_COUNT      = 100
)

func main() {
	rl.SetConfigFlags(rl.FlagMsaa4xHint)
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Go,   <SPACE>:Start / Stop, <R>:Restart")
	defer rl.CloseWindow()

	titleBarIcon := rl.LoadImage("./resources/ray.png")
	rl.SetWindowIcon(*titleBarIcon)
	rl.UnloadImage  (titleBarIcon)

	// Generate random stars
	stars := make([]rl.Vector2, STAR_COUNT)
	starSizes := make([]float32, STAR_COUNT)

	for i := 0; i < STAR_COUNT; i++ {
		rx := rl.GetRandomValue(0, SCREEN_WIDTH)
		ry := rl.GetRandomValue(0, SCREEN_HEIGHT)
		stars[i].X = float32(rx)
		stars[i].Y = float32(ry)
		rs := rl.GetRandomValue(5, 10)
		starSizes[i] = float32(rs) / 10.0
	}

	// Text lines
	data, err := os.ReadFile("../../resources/message.txt")
	if err != nil {
			panic(err)
	}
	rawLines := strings.Split(string(data), "\n")
  textLines := make([]string, 0, len(rawLines))
	for _, line := range rawLines {
		line = strings.TrimRight(line, "\r\n")
		// line = strings.TrimSpace(line)
		textLines = append(textLines, line)
	}

	textCount := len(textLines)
	textTextures := make([]rl.RenderTexture2D, textCount)

	for i, line := range textLines {
		if len(line) == 0 {
			textTextures[i] = rl.RenderTexture2D{}
			continue
		}

		var fontSize float32
		if i == 0 {
			fontSize = BASE_FONT_SIZE * 2
		} else {
			fontSize = BASE_FONT_SIZE
		}

		textWidth := rl.MeasureText(line, int32(fontSize))
		textHeight := int32(fontSize + 10)

		if textWidth <= 0 || textHeight <= 0 {
			textTextures[i] = rl.RenderTexture2D{}
			continue
		}

		tex := rl.LoadRenderTexture(textWidth, textHeight)
		rl.BeginTextureMode(tex)
		rl.ClearBackground(rl.Blank)

		var color rl.Color
		if i == 0 || i == 1 {
			color = rl.Yellow
		} else {
			color = rl.NewColor(255, 232, 31, 255)
		}

		rl.DrawText(line, 0, 0, int32(fontSize), color)
		rl.EndTextureMode()
		rl.SetTextureFilter(tex.Texture, rl.FilterBilinear)
		textTextures[i] = tex
	}

	camera := rl.Camera3D{
		Position:   rl.NewVector3(0.0, 0.0, 0.0),
		Target:     rl.NewVector3(0.0, 0.0, -1.0),
		Up:         rl.NewVector3(0.0, 1.0, 0.0),
		Fovy:       45.0,
		Projection: rl.CameraPerspective,
	}

	var scrollOffset float32 = 0.0
	var paused bool = false

	rl.SetTargetFPS(60)
	rl.InitAudioDevice()
	//rl.SetMasterVolume(1.0)
	const bgm_name= "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3"
	bgm := rl.LoadMusicStream(bgm_name)
	const BGM_START_POS = 16.0
	rl.SeekMusicStream(bgm, BGM_START_POS)
	rl.PlayMusicStream(bgm)

	for !rl.WindowShouldClose() {
		rl.UpdateMusicStream(bgm)
		// Check for space key (pause/resume)
		if rl.IsKeyPressed(rl.KeySpace) {
			paused = !paused
		}

		// Check for R key (restart)
		if rl.IsKeyPressed(rl.KeyR) {
			scrollOffset = 0.0
			paused = false
			rl.SeekMusicStream(bgm, BGM_START_POS)
		}
		// Update scroll position (only if not paused)
		if !paused {
			scrollOffset += SCROLL_SPEED * rl.GetFrameTime()
			rl.ResumeMusicStream(bgm)
		}else{
			rl.PauseMusicStream(bgm)
		}
		if scrollOffset > float32(textCount)*0.8+10.0 {
			scrollOffset = 0.0
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)

		// Draw stars
		for i := 0; i < STAR_COUNT; i++ {
			rl.DrawCircle(
				int32(stars[i].X),
				int32(stars[i].Y),
				starSizes[i],
				rl.White,
			)
		}

		rl.BeginMode3D(camera)

		for i := range textLines {
			if textTextures[i].ID == 0 {
				continue
			}

			texWidth := float32(textTextures[i].Texture.Width)
			texHeight := float32(textTextures[i].Texture.Height)
			lineOffset := scrollOffset - float32(i)*0.55

			if lineOffset > -2.0 && lineOffset < 15.0 {
				rl.PushMatrix()

				moveY := lineOffset * 0.866
				moveZ := -lineOffset * 0.5
				rl.Translatef(0.0, -3.0+moveY, -5.0+moveZ)
				rl.Rotatef(-70.0, 1.0, 0.0, 0.0)

				planeWidth := texWidth / 100.0
				planeHeight := texHeight / 100.0

				alpha := float32(1.0)
				if lineOffset > 5.0 {
					alpha = 1.0 - ((lineOffset - 5.0) / 3.0)
				}
				if lineOffset < 1.0 {
					alpha = lineOffset
				}
				if alpha < 0.0 {
					alpha = 0.0
				}
				if alpha > 1.0 {
					alpha = 1.0
				}

				rl.SetTexture(textTextures[i].Texture.ID)
				rl.Begin(rl.Quads)
				rl.Color4f(1.0, 1.0, 1.0, alpha)

				rl.TexCoord2f(0.0, 0.0)
				rl.Vertex3f(-planeWidth/2, 0.0, 0.0)
				rl.TexCoord2f(1.0, 0.0)
				rl.Vertex3f(planeWidth/2, 0.0, 0.0)
				rl.TexCoord2f(1.0, 1.0)
				rl.Vertex3f(planeWidth/2, planeHeight, 0.0)
				rl.TexCoord2f(0.0, 1.0)
				rl.Vertex3f(-planeWidth/2, planeHeight, 0.0)

				rl.End()
				rl.SetTexture(0)
				rl.PopMatrix()
			}
		}

		rl.EndMode3D()
		rl.EndDrawing()
	}

	// Unload textures
	for i := range textTextures {
		if textTextures[i].ID != 0 {
			rl.UnloadRenderTexture(textTextures[i])
		}
	}
}
