const std = @import("std");
const rl = @import("raylib");

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 400;
const BASE_FONT_SIZE: f32 = 60;
const SCROLL_SPEED: f32 = 0.47;
const STAR_COUNT = 100;

pub fn main() !void {

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT);
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Zig,   <SPACE>:Start / Stop, <R>:Restart");

    var stars: [STAR_COUNT]rl.Vector2 = undefined;
    var starSizes: [STAR_COUNT]f32 = undefined;

    // Generate random stars
    for (0..STAR_COUNT) |i| {
        const rx = rl.GetRandomValue(0, SCREEN_WIDTH);
        const ry = rl.GetRandomValue(0, SCREEN_HEIGHT);
        stars[i].x = @as(f32, @floatFromInt(rx));
        stars[i].y = @as(f32, @floatFromInt(ry));
        const rs = rl.GetRandomValue(5, 10);
        starSizes[i] = @as(f32, @floatFromInt(rs)) / 10.0;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open file
    const file = try std.fs.cwd().openFile("resources/message.txt", .{});
    defer file.close();
    var textLines: std.ArrayList([]u8) = .empty;
    defer {
        for (textLines.items) |line| {
            allocator.free(line);
        }
        textLines.deinit(allocator);
    }

    var file_buffer: [4096]u8 = undefined;
    var file_reader = file.reader(&file_buffer);
    const reader = &file_reader.interface;

    while (try reader.takeDelimiter('\n')) |line| {
        const trimmed = std.mem.trimRight(u8, line, "\r\n");
        const line_copy = try allocator.dupe(u8, trimmed);
        try textLines.append(allocator, line_copy);
        //std.debug.print("{s}\n", .{line_copy});
    }

    const textTextures = try allocator.alloc(rl.RenderTexture2D, textLines.items.len);
    defer allocator.free(textTextures);

    for (textLines.items, 0..) |line, i| {
        if (line.len == 0) {
            textTextures[i] = rl.RenderTexture2D{
                .id = 0,
                .texture = rl.Texture2D{ .id = 0 },
                .depth = rl.Texture2D{ .id = 0 },
            };
            continue;
        }

        const fontSize: f32 = if (i == 0) BASE_FONT_SIZE * 2 else BASE_FONT_SIZE;
        const textWidth = rl.MeasureText(line.ptr, @intFromFloat(fontSize));
        const textHeight = @as(c_int, @intFromFloat(fontSize + 10));

        if (textWidth <= 0 or textHeight <= 0) {
            textTextures[i] = rl.RenderTexture2D{
                .id = 0,
                .texture = rl.Texture2D{ .id = 0 },
                .depth = rl.Texture2D{ .id = 0 },
            };
            continue;
        }

        const tex = rl.LoadRenderTexture(textWidth, textHeight);
        rl.BeginTextureMode(tex);
        rl.ClearBackground(rl.BLANK);

        const color = if (i == 0 or i == 2)
            rl.YELLOW
        else
            rl.Color{ .r = 255, .g = 232, .b = 31, .a = 255 };

        rl.DrawText(line.ptr, 0, 0, @intFromFloat(fontSize), color);
        rl.EndTextureMode();
        rl.SetTextureFilter(tex.texture, rl.TEXTURE_FILTER_BILINEAR);
        textTextures[i] = tex;
    }

    const camera = rl.Camera3D{
        .position = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = -1 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45.0,
        .projection = rl.CAMERA_PERSPECTIVE,
    };

    var scrollOffset: f32 = 0.0;
    var paused: bool = false;

    rl.SetTargetFPS(60);

    rl.InitAudioDevice();
    //rl.SetMasterVolume(1.0);
    const bgm_name= "resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
    const bgm = rl.LoadMusicStream(bgm_name);
    const BGM_START_POS = 16.0;
    rl.SeekMusicStream(bgm, BGM_START_POS);
    rl.PlayMusicStream(bgm);

    while (!rl.WindowShouldClose()) {
        rl.UpdateMusicStream(bgm);
        // Check for space key (pause/resume)
        if (rl.IsKeyPressed(rl.KEY_SPACE)){
            paused = ! paused;
        }
        // Check for R key (restart)
        if (rl.IsKeyPressed(rl.KEY_R)) {
          scrollOffset = 0.0;
          paused = false;
          rl.SeekMusicStream(bgm, BGM_START_POS);
        }
        // Update scroll position (only if not paused)
        if (!paused) {
            scrollOffset += SCROLL_SPEED * rl.GetFrameTime();
            rl.ResumeMusicStream(bgm);
        }else{
            rl.PauseMusicStream(bgm);
        }
        if (scrollOffset > @as(f32, @floatFromInt(textLines.items.len)) * 0.8 + 10.0)
            scrollOffset = 0.0;

        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        // Draw stars
        for (0..STAR_COUNT) |i| {
            rl.DrawCircle(
                @intFromFloat(stars[i].x),
                @intFromFloat(stars[i].y),
                starSizes[i],
                rl.WHITE,
            );
        }

        rl.BeginMode3D(camera);

        for (textLines.items, 0..) |_, i| {
            if (textTextures[i].id == 0) continue;

            const texWidth: f32 = @as(f32, @floatFromInt(textTextures[i].texture.width));
            const texHeight: f32 = @as(f32, @floatFromInt(textTextures[i].texture.height));
            const lineOffset: f32 = scrollOffset - @as(f32, @floatFromInt(i)) * 0.55;

            if (lineOffset > -2.0 and lineOffset < 15.0) {
                rl.rlPushMatrix();

                const moveY = lineOffset * 0.866;
                const moveZ = -lineOffset * 0.5;
                rl.rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ);
                rl.rlRotatef(-70.0, 1.0, 0.0, 0.0);

                const planeWidth = texWidth / 100.0;
                const planeHeight = texHeight / 100.0;

                var alpha: f32 = 1.0;
                if (lineOffset > 5.0)
                    alpha = 1.0 - ((lineOffset - 5.0) / 3.0);
                if (lineOffset < 1.0)
                    alpha = lineOffset;
                if (alpha < 0.0) alpha = 0.0;
                if (alpha > 1.0) alpha = 1.0;

                rl.rlSetTexture(textTextures[i].texture.id);
                rl.rlBegin(rl.RL_QUADS);
                rl.rlColor4f(1.0, 1.0, 1.0, alpha);

                rl.rlTexCoord2f(0.0, 0.0);
                rl.rlVertex3f(-planeWidth / 2, 0.0, 0.0);
                rl.rlTexCoord2f(1.0, 0.0);
                rl.rlVertex3f(planeWidth / 2, 0.0, 0.0);
                rl.rlTexCoord2f(1.0, 1.0);
                rl.rlVertex3f(planeWidth / 2, planeHeight, 0.0);
                rl.rlTexCoord2f(0.0, 1.0);
                rl.rlVertex3f(-planeWidth / 2, planeHeight, 0.0);

                rl.rlEnd();
                rl.rlSetTexture(0);
                rl.rlPopMatrix();
            }
        }

        rl.EndMode3D();
        rl.EndDrawing();
    }

    rl.CloseWindow();
}
