module raywars;
import raylib5::rl;

const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 400;
const float BASE_FONT_SIZE = 60.0;
const float SCROLL_SPEED = 0.47;
const int STAR_COUNT = 100;

// external rlGL functions
extern fn void rl_push_matrix() @extern("rlPushMatrix");
extern fn void rl_pop_matrix() @extern("rlPopMatrix");
extern fn void rl_translatef(float x, float y, float z) @extern("rlTranslatef");
extern fn void rl_rotatef(float angle, float x, float y, float z) @extern("rlRotatef");
extern fn void rl_set_texture(uint id) @extern("rlSetTexture");
extern fn void rl_begin(int mode) @extern("rlBegin");
extern fn void rl_end() @extern("rlEnd");
extern fn void rl_color4f(float r, float g, float b, float a) @extern("rlColor4f");
extern fn void rl_tex_coord2f(float x, float y) @extern("rlTexCoord2f");
extern fn void rl_vertex3f(float x, float y, float z) @extern("rlVertex3f");

const int RL_QUADS = 7;

ZString bgm_name = "../../../resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";

fn int main(String[] args)
{
    rl::setConfigFlags(ConfigFlag.MSAA_4X_HINT); // FLAG_MSAA_4X_HINT
    rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in C3,   <SPACE>:Start / Stop, <R>:Restart");

    Image title_bar_icon = rl::loadImage("./resources/ray.png");
    rl::setWindowIcon(title_bar_icon);
    rl::unloadImage(title_bar_icon);

    // Generate random stars
    rl::Vector2[STAR_COUNT] stars;
    float[STAR_COUNT] star_sizes;

    for (int i = 0; i < STAR_COUNT; i++)
    {
        int rx = rl::getRandomValue(0, SCREEN_WIDTH);
        int ry = rl::getRandomValue(0, SCREEN_HEIGHT);
        stars[i].x = (float)rx;
        stars[i].y = (float)ry;
        int rs = rl::getRandomValue(5, 10);
        star_sizes[i] = (float)rs / 10.0;
    }

    // Text lines
    String[] text_lines = {
        "Epic I",
        "MAY THE RAYLIB BE WITH YOU",
        "",
        "",
        "In a galaxy powered by code,",
        "brave programmers unite to",
        "build incredible software",
        "that brings joy to users",
        "across the digital realm.",
        "",
        "Armed with keyboards and",
        "determination, these heroes",
        "debug complex systems and",
        "craft elegant solutions to",
        "seemingly impossible",
        "technical challenges.",
        "",
        "Now, a new generation of",
        "developers embarks on an",
        "epic quest to master the",
        "ancient art of programming,",
        "seeking to create applications",
        "that will shape the future",
        "of technology forever....",
        "",
        "CLASSICALS.DE",
        "If you use this track",
        "in a project, please credit:",
        "www.classicals.de",
        "Licensing Information:",
        "Conducted by Philip Milman:",
        "https://pmmusic.pro/",
        "Creative Commons",
        "Attribution 3.0 Unported",
        "CC BY 3.0",
        "You are free to:",
        "Share copy and redistribute",
        "the material in any medium",
        "or format Adapt",
        "remix, transform, and",
        "build upon the material",
        "Under the following terms:",
        "Attribution You must give",
        "appropriate credit, provide",
        "a link to the website, and",
        "indicate if changes were made.",
        "You may do so",
        "in any reasonable manner, but",
        "not in any way that suggests",
        "the licensor endorses you",
        "or your use.",
        "No additional restrictions",
        "You may not apply legal terms",
        "or technological measures",
        "that legally restrict others",
        "from doing anything",
        "the license permits.",
        "Classicals.de @2025",
        "www.classicals.de",
    };

    int text_count = text_lines.len;
    rl::RenderTexture2D[25] text_textures;

    for (int i = 0; i < text_count; i++)
    {
        String line = text_lines[i];

        if (line.len == 0)
        {
            text_textures[i].id = 0;
            text_textures[i].texture.id = 0;
            text_textures[i].depth.id = 0;
            continue;
        }

        float font_size = (i == 0) ? BASE_FONT_SIZE * 2 : BASE_FONT_SIZE;
        int text_width = rl::measureText((ZString)line.ptr, (int)font_size);
        int text_height = (int)(font_size + 10);

        if (text_width <= 0 || text_height <= 0)
        {
            text_textures[i].id = 0;
            text_textures[i].texture.id = 0;
            text_textures[i].depth.id = 0;
            continue;
        }

        rl::RenderTexture2D tex = rl::loadRenderTexture(text_width, text_height);
        rl::beginTextureMode(tex);
        rl::clearBackground(rl::BLANK);

        rl::Color color = (i == 0 || i == 1) ? rl::YELLOW : (rl::Color){ 255, 232, 31, 255 };

        rl::drawText((ZString)line.ptr, 0, 0, (int)font_size, color);
        rl::endTextureMode();
        rl::setTextureFilter(tex.texture, rl::TextureFilter.BILINEAR);
        text_textures[i] = tex;
    }

    rl::Camera3D camera;
    camera.position = (rl::Vector3){ 0.0, 0.0, 0.0 };
    camera.target = (rl::Vector3){ 0.0, 0.0, -1.0 };
    camera.up = (rl::Vector3){ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = CameraProjection.PERSPECTIVE;

    float scroll_offset = 0.0;
    bool paused = false;

    rl::setTargetFPS(60);

    rl::initAudioDevice();
    //rl::setMasterVolume(1.0);
    rl::Music bgm = rl::loadMusicStream(bgm_name);
    const float BGM_START_POS = 16.0;
    rl::seekMusicStream(bgm, BGM_START_POS);
    rl::playMusicStream(bgm);

    while (!rl::windowShouldClose())
    {
        rl::updateMusicStream(bgm);
        // Check for space key (pause/resume)
        if (rl::isKeyPressed(32)) // KEY_SPACE
        {
            paused = !paused;
        }

        // Check for R key (restart)
        if (rl::isKeyPressed(82)) // KEY_R
        {
            scroll_offset = 0.0;
            paused = false;
            rl::seekMusicStream(bgm, BGM_START_POS);
        }

        // Update scroll position (only if not paused)
        if (!paused)
        {
            scroll_offset += SCROLL_SPEED * rl::getFrameTime();
            rl::resumeMusicStream(bgm);
        }else{
            rl::pauseMusicStream(bgm);
        }


        if (scroll_offset > (float)text_count * 0.8 + 10.0)
        {
            scroll_offset = 0.0;
        }

        rl::beginDrawing();
        rl::clearBackground(rl::BLACK);

        // Draw stars
        for (int i = 0; i < STAR_COUNT; i++)
        {
            rl::drawCircle(
                (int)stars[i].x,
                (int)stars[i].y,
                star_sizes[i],
                rl::WHITE
            );
        }

        rl::beginMode3D(camera);

        for (int i = 0; i < text_count; i++)
        {
            if (text_textures[i].id == 0) continue;

            float tex_width = (float)text_textures[i].texture.width;
            float tex_height = (float)text_textures[i].texture.height;
            float line_offset = scroll_offset - (float)i * 0.55;

            if (line_offset > -2.0 && line_offset < 15.0)
            {
                rl_push_matrix();

                float move_y = line_offset * 0.866;
                float move_z = line_offset * -0.5;
                rl_translatef(0.0, -3.0 + move_y, -5.0 + move_z);
                rl_rotatef(-70.0, 1.0, 0.0, 0.0);

                float plane_width = tex_width / 100.0;
                float plane_height = tex_height / 100.0;

                float alpha = 1.0;
                if (line_offset > 5.0)
                {
                    alpha = 1.0 - ((line_offset - 5.0) / 3.0);
                }
                if (line_offset < 1.0)
                {
                    alpha = line_offset;
                }
                if (alpha < 0.0) alpha = 0.0;
                if (alpha > 1.0) alpha = 1.0;

                rl_set_texture(text_textures[i].texture.id);
                rl_begin(RL_QUADS);
                rl_color4f(1.0, 1.0, 1.0, alpha);

                rl_tex_coord2f(0.0, 0.0);
                rl_vertex3f(-plane_width / 2, 0.0, 0.0);
                rl_tex_coord2f(1.0, 0.0);
                rl_vertex3f(plane_width / 2, 0.0, 0.0);
                rl_tex_coord2f(1.0, 1.0);
                rl_vertex3f(plane_width / 2, plane_height, 0.0);
                rl_tex_coord2f(0.0, 1.0);
                rl_vertex3f(-plane_width / 2, plane_height, 0.0);

                rl_end();
                rl_set_texture(0);
                rl_pop_matrix();
            }
        }

        rl::endMode3D();
        rl::endDrawing();
    }

    // Unload textures
    for (int i = 0; i < text_count; i++)
    {
        if (text_textures[i].id != 0)
        {
            rl::unloadRenderTexture(text_textures[i]);
        }
    }

    rl::closeWindow();
    return 0;
}
