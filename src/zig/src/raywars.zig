const std = @import("std");
const rl = @import("raylib");
const rlgl = rl.gl;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 400;
const BASE_FONT_SIZE: f32 = 60;
const SCROLL_SPEED: f32 = 0.47;
const STAR_COUNT = 100;

pub fn main() !void {

    rl.setConfigFlags(.{.msaa_4x_hint = true, .window_hidden = true});
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Zig,   <SPACE>:Start / Stop, <R>:Restart");

    const title_bar_icon = try rl.loadImage("./resources/ray.png");
    rl.setWindowIcon(title_bar_icon);
    rl.unloadImage(title_bar_icon);

    var stars: [STAR_COUNT]rl.Vector2 = undefined;
    var starSizes: [STAR_COUNT]f32 = undefined;

    // Generate random stars
    for (0..STAR_COUNT) |i| {
        const rx = rl.getRandomValue(0, SCREEN_WIDTH);
        const ry = rl.getRandomValue(0, SCREEN_HEIGHT);
        stars[i].x = @as(f32, @floatFromInt(rx));
        stars[i].y = @as(f32, @floatFromInt(ry));
        const rs = rl.getRandomValue(5, 10);
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
                .texture = rl.Texture2D{ .id = 0, .width = 0, .height = 0, .mipmaps = 0, .format = .uncompressed_grayscale },
                .depth   = rl.Texture2D{ .id = 0, .width = 0, .height = 0, .mipmaps = 0, .format = .uncompressed_grayscale },
            };
            continue;
        }

        const fontSize: f32 = if (i == 0) BASE_FONT_SIZE * 2 else BASE_FONT_SIZE;
        const line_z: [:0]const u8 = line[0..line.len :0];
        const textWidth = rl.measureText(line_z, @intFromFloat(fontSize));
        const textHeight = @as(c_int, @intFromFloat(fontSize + 10));

        if (textWidth <= 0 or textHeight <= 0) {
            textTextures[i] = rl.RenderTexture2D{
                .id = 0,
                .texture = rl.Texture2D{ .id = 0, .width = 0, .height = 0, .mipmaps = 0, .format = .uncompressed_grayscale },
                .depth   = rl.Texture2D{ .id = 0, .width = 0, .height = 0, .mipmaps = 0, .format = .uncompressed_grayscale },
            };
            continue;
        }

        const tex = try rl.loadRenderTexture(textWidth, textHeight);
        rl.beginTextureMode(tex);
        rl.clearBackground(.blank);

        const color: rl.Color = if (i == 0 or i == 2)
            .yellow
        else
            rl.Color{ .r = 255, .g = 232, .b = 31, .a = 255 };

        rl.drawText(line_z, 0, 0, @intFromFloat(fontSize), color);
        rl.endTextureMode();
        rl.setTextureFilter(tex.texture, .bilinear);
        textTextures[i] = tex;
    }

    const camera = rl.Camera3D{
        .position = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = -1 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45.0,
        .projection = .perspective,
    };

    var scrollOffset: f32 = 0.0;
    var paused: bool = false;

    rl.setTargetFPS(60);

    rl.initAudioDevice();
    //rl.SetMasterVolume(1.0);
    const bgm_name= "resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
    const bgm = try rl.loadMusicStream(bgm_name);
    const BGM_START_POS = 16.0;
    rl.seekMusicStream(bgm, BGM_START_POS);
    rl.playMusicStream(bgm);

    var delayShowWindow: i32 = 1;

    while (!rl.windowShouldClose()) {
        rl.updateMusicStream(bgm);
        // Check for space key (pause/resume)
        if (rl.isKeyPressed(.space)){
            paused = ! paused;
        }
        // Check for R key (restart)
        if (rl.isKeyPressed(.r)) {
          scrollOffset = 0.0;
          paused = false;
          rl.seekMusicStream(bgm, BGM_START_POS);
        }
        // Update scroll position (only if not paused)
        if (!paused) {
            scrollOffset += SCROLL_SPEED * rl.getFrameTime();
            rl.resumeMusicStream(bgm);
        }else{
            rl.pauseMusicStream(bgm);
        }
        if (scrollOffset > @as(f32, @floatFromInt(textLines.items.len)) * 0.8 + 10.0)
            scrollOffset = 0.0;

        rl.beginDrawing();
        rl.clearBackground(.black);

        // Draw stars
        for (0..STAR_COUNT) |i| {
            rl.drawCircle(
                @intFromFloat(stars[i].x),
                @intFromFloat(stars[i].y),
                starSizes[i],
                .white,
            );
        }

        rl.beginMode3D(camera);

        for (textLines.items, 0..) |_, i| {
            if (textTextures[i].id == 0) continue;

            const texWidth: f32 = @as(f32, @floatFromInt(textTextures[i].texture.width));
            const texHeight: f32 = @as(f32, @floatFromInt(textTextures[i].texture.height));
            const lineOffset: f32 = scrollOffset - @as(f32, @floatFromInt(i)) * 0.55;

            if (lineOffset > -2.0 and lineOffset < 15.0) {
                rl.gl.rlPushMatrix();

                const moveY = lineOffset * 0.866;
                const moveZ = -lineOffset * 0.5;
                rl.gl.rlTranslatef(0.0, -3.0 + moveY, -5.0 + moveZ);
                rl.gl.rlRotatef(-70.0, 1.0, 0.0, 0.0);

                const planeWidth = texWidth / 100.0;
                const planeHeight = texHeight / 100.0;

                var alpha: f32 = 1.0;
                if (lineOffset > 5.0)
                    alpha = 1.0 - ((lineOffset - 5.0) / 3.0);
                if (lineOffset < 1.0)
                    alpha = lineOffset;
                if (alpha < 0.0) alpha = 0.0;
                if (alpha > 1.0) alpha = 1.0;

                rl.gl.rlSetTexture(textTextures[i].texture.id);
                rl.gl.rlBegin(rl.gl.rl_quads);
                rl.gl.rlColor4f(1.0, 1.0, 1.0, alpha);

                rl.gl.rlTexCoord2f(0.0, 0.0);
                rl.gl.rlVertex3f(-planeWidth / 2, 0.0, 0.0);
                rl.gl.rlTexCoord2f(1.0, 0.0);
                rl.gl.rlVertex3f(planeWidth / 2, 0.0, 0.0);
                rl.gl.rlTexCoord2f(1.0, 1.0);
                rl.gl.rlVertex3f(planeWidth / 2, planeHeight, 0.0);
                rl.gl.rlTexCoord2f(0.0, 1.0);
                rl.gl.rlVertex3f(-planeWidth / 2, planeHeight, 0.0);

                rl.gl.rlEnd();
                rl.gl.rlSetTexture(0);
                rl.gl.rlPopMatrix();
            }
        }

        rl.endMode3D();
        rl.endDrawing();

        if (delayShowWindow == 0) {
            rl.clearWindowState(rl.ConfigFlags { .window_hidden = true });
        }
        if (delayShowWindow >= 0) {
            delayShowWindow -= 1;
        }

    }

    rl.closeWindow();
}
