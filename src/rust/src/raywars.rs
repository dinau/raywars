use raylib::prelude::*;
use std::fs::File;
use std::io::{BufRead, BufReader};

const SCREEN_WIDTH: i32 = 800;
const SCREEN_HEIGHT: i32 = 400;
const BASE_FONT_SIZE: f32 = 60.0;
const SCROLL_SPEED: f32 = 0.47;
const STAR_COUNT: usize = 100;

fn main() {
    let (mut rl, thread) = raylib::init()
        .size(SCREEN_WIDTH, SCREEN_HEIGHT)
        .title("Ray Wars Opening Crawl in Rust,   <SPACE>:Start / Stop, <R>:Restart")
        .msaa_4x()
        .build();

    // Set window icon
    let title_bar_icon = Image::load_image("./resources/ray.png").expect("Failed to load icon");
    rl.set_window_icon(title_bar_icon);

    // Generate random stars
    let mut stars: Vec<Vector2> = Vec::with_capacity(STAR_COUNT);
    let mut star_sizes: Vec<f32> = Vec::with_capacity(STAR_COUNT);

    for _ in 0..STAR_COUNT {
        let rx = rl.get_random_value::<i32>(0..SCREEN_WIDTH);
        let ry = rl.get_random_value::<i32>(0..SCREEN_HEIGHT);
        stars.push(Vector2::new(rx as f32, ry as f32));
        let rs = rl.get_random_value::<i32>(5..10);
        star_sizes.push(rs as f32 / 10.0);
    }

    // Read text lines from file
    let file = File::open("./resources/message.txt").expect("Failed to open file");
    let reader = BufReader::new(file);
    let text_lines: Vec<String> = reader
        .lines()
        .map(|line| line.unwrap().trim_end_matches(&['\r', '\n'][..]).to_string())
        .collect();

    // Create textures for each text line
    let mut text_textures: Vec<Option<RenderTexture2D>> = Vec::new();

    for (i, line) in text_lines.iter().enumerate() {
        let font_size = if i == 0 { BASE_FONT_SIZE * 2.0 } else { BASE_FONT_SIZE };
        let text_width = rl.measure_text(line, font_size as i32);
        let text_height = font_size as i32 + 10;

        if text_width > 0 && text_height > 0 {
            let mut tex = rl.load_render_texture(&thread, text_width as u32, text_height as u32)
                .expect("Failed to load render texture");

            {
                let mut d = rl.begin_texture_mode(&thread, &mut tex);
                d.clear_background(Color::BLANK);

                let color = if i == 0 || i == 1 {
                    Color::YELLOW
                } else {
                    Color::new(255, 232, 31, 255)
                };

                d.draw_text(line, 0, 0, font_size as i32, color);
            }

            // Set texture filter
            unsafe {
                ffi::SetTextureFilter(tex.texture, ffi::TextureFilter::TEXTURE_FILTER_BILINEAR as i32);
            }

            text_textures.push(Some(tex));
        } else {
            text_textures.push(None);
        }
    }

    // Setup 3D camera
    let camera = Camera3D::perspective(
        Vector3::new(0.0, 0.0, 0.0),
        Vector3::new(0.0, 0.0, -1.0),
        Vector3::new(0.0, 1.0, 0.0),
        45.0,
    );

    let mut scroll_offset: f32 = 0.0;
    let mut paused: bool = false;

    rl.set_target_fps(60);

    // Initialize audio
    let audio = raylib::core::audio::RaylibAudio::init_audio_device().unwrap();
    let bgm_name = "./resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
    let bgm = audio.new_music(bgm_name).unwrap();
    const BGM_START_POS: f32 = 16.0;

    bgm.seek_stream(BGM_START_POS);
    bgm.play_stream();

    while !rl.window_should_close() {
        bgm.update_stream();

        // Check for space key (pause/resume)
        if rl.is_key_pressed(KeyboardKey::KEY_SPACE) {
            paused = !paused;
        }

        // Check for R key (restart)
        if rl.is_key_pressed(KeyboardKey::KEY_R) {
            scroll_offset = 0.0;
            paused = false;
            bgm.seek_stream(BGM_START_POS);
        }

        // Update scroll position (only if not paused)
        if !paused {
            scroll_offset += SCROLL_SPEED * rl.get_frame_time();
            bgm.resume_stream();
        } else {
            bgm.pause_stream();
        }

        // Reset when all lines have scrolled past
        if scroll_offset > text_lines.len() as f32 * 0.8 + 10.0 {
            scroll_offset = 0.0;
        }

        let mut d = rl.begin_drawing(&thread);

        d.clear_background(Color::BLACK);

        // Draw stars
        for i in 0..STAR_COUNT {
            d.draw_circle(
                stars[i].x as i32,
                stars[i].y as i32,
                star_sizes[i],
                Color::WHITE,
            );
        }

        // Begin 3D mode
        {
            let _d3d = d.begin_mode3D(camera);

            // Draw each line as a separate plane
            for (i, _) in text_lines.iter().enumerate() {
                if let Some(ref tex) = text_textures[i] {
                    let tex_width = tex.texture.width as f32;
                    let tex_height = tex.texture.height as f32;
                    let line_offset = scroll_offset - i as f32 * 0.55;

                    // Only draw if visible
                    if line_offset > -2.0 && line_offset < 15.0 {
                        unsafe {
                            ffi::rlPushMatrix();

                            // Calculate movement along Y and Z (60° angle)
                            let move_y = line_offset * 0.866;  // sin(60°)
                            let move_z = -line_offset * 0.5;   // cos(60°)

                            ffi::rlTranslatef(0.0, -3.0 + move_y, -5.0 + move_z);

                            // Tilt plane backward 70 degrees
                            ffi::rlRotatef(-70.0, 1.0, 0.0, 0.0);

                            // Plane size
                            let plane_width = tex_width / 100.0;
                            let plane_height = tex_height / 100.0;

                            // Alpha fade (disappear near top)
                            let mut alpha = 1.0f32;

                            // Fade out gradually when moving upward
                            if line_offset > 5.0 {
                                alpha = 1.0 - ((line_offset - 5.0) / 3.0);
                                alpha = alpha.clamp(0.0, 1.0);
                            }

                            // Fade in near start
                            if line_offset < 1.0 {
                                alpha = line_offset;
                                alpha = alpha.clamp(0.0, 1.0);
                            }

                            // Draw textured plane
                            ffi::rlSetTexture(tex.texture.id);

                            ffi::rlBegin(ffi::RL_QUADS as i32);
                            ffi::rlColor4f(1.0, 1.0, 1.0, alpha);

                            // Quad vertices
                            ffi::rlTexCoord2f(0.0, 0.0);
                            ffi::rlVertex3f(-plane_width / 2.0, 0.0, 0.0);
                            ffi::rlTexCoord2f(1.0, 0.0);
                            ffi::rlVertex3f(plane_width / 2.0, 0.0, 0.0);
                            ffi::rlTexCoord2f(1.0, 1.0);
                            ffi::rlVertex3f(plane_width / 2.0, plane_height, 0.0);
                            ffi::rlTexCoord2f(0.0, 1.0);
                            ffi::rlVertex3f(-plane_width / 2.0, plane_height, 0.0);

                            ffi::rlEnd();
                            ffi::rlSetTexture(0);

                            ffi::rlPopMatrix();
                        }
                    }
                }
            }
        } // end_mode3D is auto executed

    } // end_drawing is auot executed

    // Unload textures
    for texture in text_textures {
        if let Some(tex) = texture {
            drop(tex); // RenderTexture2D
        }
    }
}
