package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:c"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 400
BASE_FONT_SIZE :: 60
SCROLL_SPEED :: 0.5
STAR_COUNT :: 100

// rlGL functions external declarations
when ODIN_OS == .Windows {
    foreign import raylib "system:raylib.lib"
} else {
    foreign import raylib "system:raylib"
}

@(default_calling_convention="c")
foreign raylib {
    rlPushMatrix :: proc() ---
    rlPopMatrix :: proc() ---
    rlTranslatef :: proc(x, y, z: f32) ---
    rlRotatef :: proc(angle, x, y, z: f32) ---
    rlSetTexture :: proc(id: u32) ---
    rlBegin :: proc(mode: c.int) ---
    rlEnd :: proc() ---
    rlColor4f :: proc(r, g, b, a: f32) ---
    rlTexCoord2f :: proc(x, y: f32) ---
    rlVertex3f :: proc(x, y, z: f32) ---
}

RL_QUADS :: 7

main :: proc() {
    rl.SetConfigFlags({.MSAA_4X_HINT})
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Odin,   <SPACE>:Start / Stop, <R>:Restart")
    defer rl.CloseWindow()

    stars: [STAR_COUNT]rl.Vector2
    star_sizes: [STAR_COUNT]f32

    // Generate random stars
    for i in 0..<STAR_COUNT {
        rx := rl.GetRandomValue(0, SCREEN_WIDTH)
        ry := rl.GetRandomValue(0, SCREEN_HEIGHT)
        stars[i].x = f32(rx)
        stars[i].y = f32(ry)
        rs := rl.GetRandomValue(5, 10)
        star_sizes[i] = f32(rs) / 10.0
    }

    // Text lines
    text_lines := make([dynamic]cstring)
    defer {
        for line in text_lines {
            delete(line)
        }
        delete(text_lines)
    }

    // Read textt file
    data, ok := os.read_entire_file("../../resources/message.txt")
    if !ok {
        fmt.println("Error!: Fail read file")
        return
    }
    defer delete(data)

    content := string(data)
    lines := strings.split_lines(content)
    defer delete(lines)
    for line in lines {
        line_cstr := strings.clone_to_cstring(line)
        append(&text_lines, line_cstr)
    }

    text_count := len(text_lines)
    text_textures: [dynamic]rl.RenderTexture2D
    defer delete(text_textures)

    for line, i in text_lines {
        if len(line) == 0 {
            append(&text_textures, rl.RenderTexture2D{})
            continue
        }

        font_size := BASE_FONT_SIZE * 2 if i == 0 else BASE_FONT_SIZE
        text_width := rl.MeasureText(line, i32(font_size))
        text_height := i32(font_size + 10)

        if text_width <= 0 || text_height <= 0 {
            append(&text_textures, rl.RenderTexture2D{})
            continue
        }

        tex := rl.LoadRenderTexture(text_width, text_height)
        rl.BeginTextureMode(tex)
        rl.ClearBackground(rl.BLANK)

        color := rl.YELLOW if (i == 0 || i == 1) else rl.Color{255, 232, 31, 255}

        rl.DrawText(line, 0, 0, i32(font_size), color)
        rl.EndTextureMode()
        rl.SetTextureFilter(tex.texture, .BILINEAR)
        append(&text_textures, tex)
    }

    camera := rl.Camera3D{
        position = {0, 0, 0},
        target = {0, 0, -1},
        up = {0, 1, 0},
        fovy = 45.0,
        projection = .PERSPECTIVE,
    }

    scroll_offset: f32 = 0.0
    paused: bool = false

    rl.SetTargetFPS(60)

    rl.InitAudioDevice()
    //rl.SetMasterVolume(1.0);
    bgm_name : cstring = "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
    bgm := rl.LoadMusicStream(bgm_name)
    BGM_START_POS : f32 = 16.0
    rl.SeekMusicStream(bgm, BGM_START_POS)
    rl.PlayMusicStream(bgm)

    for !rl.WindowShouldClose() {
        rl.UpdateMusicStream(bgm)
        // Check for space key (pause/resume)
        if rl.IsKeyPressed(.SPACE) {
            paused = !paused
        }

        // Check for R key (restart)
        if rl.IsKeyPressed(.R) {
            scroll_offset = 0.0
            paused = false
            rl.SeekMusicStream(bgm, BGM_START_POS)
        }

        // Update scroll position (only if not paused)
        if !paused {
            scroll_offset += SCROLL_SPEED * rl.GetFrameTime()
            rl.ResumeMusicStream(bgm)
        }else{
            rl.PauseMusicStream(bgm)
        }

        if scroll_offset > f32(text_count) * 0.8 + 10.0 {
            scroll_offset = 0.0
        }

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.BLACK)

        // Draw stars
        for i in 0..<STAR_COUNT {
            rl.DrawCircle(
                i32(stars[i].x),
                i32(stars[i].y),
                star_sizes[i],
                rl.WHITE,
            )
        }

        rl.BeginMode3D(camera)
        defer rl.EndMode3D()

        for _, i in text_lines {
            if text_textures[i].id == 0 do continue

            tex_width := f32(text_textures[i].texture.width)
            tex_height := f32(text_textures[i].texture.height)
            line_offset := scroll_offset - f32(i) * 0.55

            if line_offset > -2.0 && line_offset < 15.0 {
                rlPushMatrix()
                defer rlPopMatrix()

                move_y := line_offset * 0.866
                move_z := -line_offset * 0.5
                rlTranslatef(0.0, -3.0 + move_y, -5.0 + move_z)
                rlRotatef(-70.0, 1.0, 0.0, 0.0)

                plane_width := tex_width / 100.0
                plane_height := tex_height / 100.0

                alpha: f32 = 1.0
                if line_offset > 5.0 {
                    alpha = 1.0 - ((line_offset - 5.0) / 3.0)
                }
                if line_offset < 1.0 {
                    alpha = line_offset
                }
                alpha = clamp(alpha, 0.0, 1.0)

                rlSetTexture(text_textures[i].texture.id)
                rlBegin(RL_QUADS)
                rlColor4f(1.0, 1.0, 1.0, alpha)

                rlTexCoord2f(0.0, 0.0)
                rlVertex3f(-plane_width / 2, 0.0, 0.0)
                rlTexCoord2f(1.0, 0.0)
                rlVertex3f(plane_width / 2, 0.0, 0.0)
                rlTexCoord2f(1.0, 1.0)
                rlVertex3f(plane_width / 2, plane_height, 0.0)
                rlTexCoord2f(0.0, 1.0)
                rlVertex3f(-plane_width / 2, plane_height, 0.0)

                rlEnd()
                rlSetTexture(0)
            }
        }
    }

    // Unload textures
    for texture in text_textures {
        if texture.id != 0 {
            rl.UnloadRenderTexture(texture)
        }
    }
}
