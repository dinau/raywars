require_relative 'util/setup_dll'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 400


def main()
  Raylib.SetConfigFlags(Raylib::FLAG_MSAA_4X_HINT)
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in Ruby,   <SPACE>:Start / Stop, <R>:Restart")

  # Text content
  text = []
  File.foreach("../../resources/message.txt") do |line|
    text << line.chomp
  end

  text_count = text.length
  scroll_offset = 0.0
  scroll_speed = 0.46
  paused = false

  # Generate random star positions
  stars = []
  star_sizes = []
  100.times do
    stars << Raylib::Vector2.create(Raylib.GetRandomValue(0, SCREEN_WIDTH), Raylib.GetRandomValue(0, SCREEN_HEIGHT))
    star_sizes << Raylib.GetRandomValue(5, 10) / 10.0
  end

  # Create textures for each text line
  base_font_size = 60
  text_textures = []

  text.each_with_index do |line, i|
    # First line uses double font size
    font_size = (i == 0) ? base_font_size * 2 : base_font_size
    text_width = Raylib.MeasureText(line, font_size)
    text_height = font_size + 10

    if text_width > 0 && text_height > 0
      texture = Raylib.LoadRenderTexture(text_width, text_height)

      Raylib.BeginTextureMode(texture)
      Raylib.ClearBackground(Raylib::BLANK)
      text_color = (i == 0 || i == 1) ? Raylib::YELLOW : Color.from_u8(255, 232, 31, 255)
      Raylib.DrawText(line, 0, 0, font_size, text_color)
      Raylib.EndTextureMode()

      Raylib.SetTextureFilter(texture.texture, Raylib::TEXTURE_FILTER_BILINEAR)
      text_textures << texture
    else
      text_textures << nil
    end
  end

  # Setup 3D camera
  camera = Camera3D.new
  camera.position = Vector3.create(0.0, 0.0, 0.0)
  camera.target = Vector3.create(0.0, 0.0, -1.0)
  camera.up = Vector3.create(0.0, 1.0, 0.0)
  camera.fovy = 45.0
  camera.projection = CAMERA_PERSPECTIVE

  Raylib.SetTargetFPS(60)

  Raylib.InitAudioDevice()
  #Raylib.SetMasterVolume(1.0)
  bgm_name = "../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3"
  bgm = Raylib.LoadMusicStream(bgm_name)
  bgm_start_pos = 16.0
  Raylib.SeekMusicStream(bgm, bgm_start_pos)
  Raylib.PlayMusicStream(bgm)

  until Raylib.WindowShouldClose()
    Raylib.UpdateMusicStream(bgm)
    # Check for space key (pause/resume)
    if Raylib.IsKeyPressed(Raylib::KEY_SPACE)
      paused = !paused
    end

    # Check for R key (restart)
    if Raylib.IsKeyPressed(Raylib::KEY_R)
      scroll_offset = 0.0
      paused = false
      Raylib.SeekMusicStream(bgm, bgm_start_pos)
    end

    # Update scroll position (only if not paused)
    unless paused
      scroll_offset += scroll_speed * Raylib.GetFrameTime()
      Raylib..ResumeMusicStream(bgm)
    else
      Raylib.PauseMusicStream(bgm)
    end

    # Reset when all lines have scrolled past
    if scroll_offset > text_count * 0.8 + 10.0
      scroll_offset = 0.0
    end

    # Start drawing
    Raylib.BeginDrawing()

    Raylib.ClearBackground(Raylib::BLACK)

    # Draw background stars
    stars.each_with_index do |star, i|
      Raylib.DrawCircle(star.x.to_i, star.y.to_i, star_sizes[i], Raylib::WHITE)
    end

    # Begin 3D mode
    Raylib.BeginMode3D(camera)

    # Draw each line as a separate plane
    text_textures.each_with_index do |texture, i|
      next if texture.nil?

      text_width = texture.texture.width
      text_height = texture.texture.height

      # Calculate vertical offset for this line
      line_offset = scroll_offset - (i * 0.55)

      # Only draw if visible
      if line_offset > -2.0 && line_offset < 15.0
        Raylib.rlPushMatrix()

        # Calculate movement along Y and Z (60° angle)
        move_y = line_offset * 0.866  # sin(60°)
        move_z = -line_offset * 0.5   # cos(60°)

        Raylib.rlTranslatef(0.0, -3.0 + move_y, -5.0 + move_z)

        # Tilt plane backward 70 degrees
        Raylib.rlRotatef(-70.0, 1.0, 0.0, 0.0)

        # Plane size
        plane_width = text_width / 100.0
        plane_height = text_height / 100.0

        # Alpha fade (disappear near top)
        alpha = 1.0

        # Fade out gradually when moving upward
        if line_offset > 5.0
          alpha = 1.0 - ((line_offset - 5.0) / 3.0)
          alpha = Raylib.Clamp(alpha, 0.0, 1.0)
        end

        # Fade in near start
        if line_offset < 1.0
          alpha = line_offset
          alpha = Raylib.Clamp(alpha, 0.0, 1.0)
        end

        # Draw textured plane
        Raylib.rlSetTexture(texture.texture.id)

        Raylib.rlBegin(Raylib::RL_QUADS)
        Raylib.rlColor4f(1.0, 1.0, 1.0, alpha)

        # Quad vertices
        Raylib.rlTexCoord2f(0.0, 0.0); Raylib.rlVertex3f(-plane_width/2, 0.0, 0.0)
        Raylib.rlTexCoord2f(1.0, 0.0); Raylib.rlVertex3f(plane_width/2, 0.0, 0.0)
        Raylib.rlTexCoord2f(1.0, 1.0); Raylib.rlVertex3f(plane_width/2, plane_height, 0.0)
        Raylib.rlTexCoord2f(0.0, 1.0); Raylib.rlVertex3f(-plane_width/2, plane_height, 0.0)

        Raylib.rlEnd()
        Raylib.rlSetTexture(0)

        Raylib.rlPopMatrix()
      end
    end

    Raylib.EndMode3D()

    Raylib.EndDrawing()
  end

  # Unload textures
  text_textures.each do |texture|
    Raylib.UnloadRenderTexture(texture) unless texture.nil?
  end

  Raylib.CloseWindow()
end

if __FILE__ == $PROGRAM_NAME
  main()
end
