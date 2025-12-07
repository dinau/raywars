from pyray import *

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 400


def main():
    set_config_flags(ConfigFlags.FLAG_MSAA_4X_HINT)
    init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Python,   <SPACE>:Start / Stop, <R>:Restart")
    title_bar_icon = load_image("../../resources/ray.png")
    set_window_icon(title_bar_icon)
    unload_image(title_bar_icon)

    # Text content
    text = []
    with open("../../resources/message.txt", "r", encoding="utf-8") as f:
        for line in f:
            text.append(line.rstrip("\n"))

    text_count = len(text)
    scroll_offset = 0.0
    scroll_speed = 0.47
    paused = False

    # Generate random star positions
    stars = []
    star_sizes = []
    for _ in range(100):
        stars.append(Vector2(get_random_value(0, SCREEN_WIDTH), get_random_value(0, SCREEN_HEIGHT)))
        star_sizes.append(get_random_value(5, 10) / 10.0)

    # Create textures for each text line
    base_font_size = 60
    text_textures = []

    for i, line in enumerate(text):
        # First line uses double font size
        font_size = base_font_size * 2 if i == 0 else base_font_size
        text_width = measure_text(line, font_size)
        text_height = font_size + 10

        if text_width > 0 and text_height > 0:
            texture = load_render_texture(text_width, text_height)

            begin_texture_mode(texture)
            clear_background(BLANK)
            text_color = YELLOW if (i == 0 or i == 1) else Color(255, 232, 31, 255)
            draw_text(line, 0, 0, font_size, text_color)
            end_texture_mode()

            set_texture_filter(texture.texture, TextureFilter.TEXTURE_FILTER_BILINEAR)
            text_textures.append(texture)
        else:
            text_textures.append(None)

    # Setup 3D camera
    camera = Camera3D(
        Vector3(0.0, 0.0, 0.0),
        Vector3(0.0, 0.0, -1.0),
        Vector3(0.0, 1.0, 0.0),
        45.0,
        CameraProjection.CAMERA_PERSPECTIVE
    )

    set_target_fps(60)

    init_audio_device()
    #set_master_volume(1.0)
    bgm_name= '../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3'
    bgm = load_music_stream(bgm_name)
    BGM_START_POS = 16.0
    seek_music_stream(bgm, BGM_START_POS)
    play_music_stream(bgm)

    while not window_should_close():
        update_music_stream(bgm)
        # Check for space key (pause/resume)
        if is_key_pressed(KeyboardKey.KEY_SPACE):
            paused = not paused

        # Check for R key (restart)
        if is_key_pressed(KeyboardKey.KEY_R):
            scroll_offset = 0.0
            paused = False
            seek_music_stream(bgm, BGM_START_POS)

        # Update scroll position (only if not paused)
        if not paused:
            scroll_offset += scroll_speed * get_frame_time()
            resume_music_stream(bgm)
        else:
            pause_music_stream(bgm)

        # Reset when all lines have scrolled past
        if scroll_offset > text_count * 0.8 + 10.0:
            scroll_offset = 0.0

        # Start drawing
        begin_drawing()

        clear_background(BLACK)

        # Draw background stars
        for i, star in enumerate(stars):
            draw_circle(int(star.x), int(star.y), star_sizes[i], WHITE)

        # Begin 3D mode
        begin_mode_3d(camera)

        # Draw each line as a separate plane
        for i, texture in enumerate(text_textures):
            if texture is None:
                continue

            text_width = texture.texture.width
            text_height = texture.texture.height

            # Calculate vertical offset for this line
            line_offset = scroll_offset - (i * 0.55)

            # Only draw if visible
            if -2.0 < line_offset < 15.0:
                rl_push_matrix()

                # Calculate movement along Y and Z (60° angle)
                move_y = line_offset * 0.866  # sin(60°)
                move_z = -line_offset * 0.5   # cos(60°)

                rl_translatef(0.0, -3.0 + move_y, -5.0 + move_z)

                # Tilt plane backward 70 degrees
                rl_rotatef(-70.0, 1.0, 0.0, 0.0)

                # Plane size
                plane_width = text_width / 100.0
                plane_height = text_height / 100.0

                # Alpha fade (disappear near top)
                alpha = 1.0

                # Fade out gradually when moving upward
                if line_offset > 5.0:
                    alpha = 1.0 - ((line_offset - 5.0) / 3.0)
                    alpha = clamp(alpha, 0.0, 1.0)

                # Fade in near start
                if line_offset < 1.0:
                    alpha = line_offset
                    alpha = clamp(alpha, 0.0, 1.0)

                # Draw textured plane
                rl_set_texture(texture.texture.id)

                rl_begin(RL_QUADS)
                rl_color4f(1.0, 1.0, 1.0, alpha)

                # Quad vertices
                rl_tex_coord2f(0.0, 0.0); rl_vertex3f(-plane_width/2, 0.0, 0.0)
                rl_tex_coord2f(1.0, 0.0); rl_vertex3f(plane_width/2, 0.0, 0.0)
                rl_tex_coord2f(1.0, 1.0); rl_vertex3f(plane_width/2, plane_height, 0.0)
                rl_tex_coord2f(0.0, 1.0); rl_vertex3f(-plane_width/2, plane_height, 0.0)

                rl_end()
                rl_set_texture(0)

                rl_pop_matrix()

        end_mode_3d()

        end_drawing()

    # Unload textures
    for texture in text_textures:
        if texture is not None:
            unload_render_texture(texture)

    close_window()


if __name__ == "__main__":
    main()
