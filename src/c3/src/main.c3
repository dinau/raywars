module raywars;
import raylib;

const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 400;
const float BASE_FONT_SIZE = 60.0;
const float SCROLL_SPEED = 0.5;
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

fn int main(String[] args)
{
    raylib::set_config_flags(0x00000020); // FLAG_MSAA_4X_HINT
    raylib::init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Ray Wars Opening Crawl in C3,   <SPACE>:Start / Stop, <R>:Restart");
    raylib::set_target_fps(60);

    // Generate random stars
    raylib::Vector2[STAR_COUNT] stars;
    float[STAR_COUNT] star_sizes;

    for (int i = 0; i < STAR_COUNT; i++)
    {
        int rx = raylib::get_random_value(0, SCREEN_WIDTH);
        int ry = raylib::get_random_value(0, SCREEN_HEIGHT);
        stars[i].x = (float)rx;
        stars[i].y = (float)ry;
        int rs = raylib::get_random_value(5, 10);
        star_sizes[i] = (float)rs / 10.0;
    }

    // Text lines
    String[] text_lines = {
        "Epic I",
        "THE CODING ADVENTURE",
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
        ""
    };

    int text_count = text_lines.len;
    raylib::RenderTexture2D[25] text_textures;

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
        int text_width = raylib::measure_text((char*)line.ptr, (int)font_size);
        int text_height = (int)(font_size + 10);

        if (text_width <= 0 || text_height <= 0)
        {
            text_textures[i].id = 0;
            text_textures[i].texture.id = 0;
            text_textures[i].depth.id = 0;
            continue;
        }

        raylib::RenderTexture2D tex = raylib::load_render_texture(text_width, text_height);
        raylib::begin_texture_mode(tex);
        raylib::clear_background(raylib::BLANK);

        raylib::Color color = (i == 0 || i == 1) ? raylib::YELLOW : (raylib::Color){ 255, 232, 31, 255 };

        raylib::draw_text((char*)line.ptr, 0, 0, (int)font_size, color);
        raylib::end_texture_mode();
        raylib::set_texture_filter(tex.texture, raylib::TextureFilter.BILINEAR);
        text_textures[i] = tex;
    }

    raylib::Camera3D camera;
    camera.position = (raylib::Vector3){ 0.0, 0.0, 0.0 };
    camera.target = (raylib::Vector3){ 0.0, 0.0, -1.0 };
    camera.up = (raylib::Vector3){ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = raylib::CameraProjection.PERSPECTIVE.ordinal;

    float scroll_offset = 0.0;
    bool paused = false;

    while (!raylib::window_should_close())
    {
        // Check for space key (pause/resume)
        if (raylib::is_key_pressed(32)) // KEY_SPACE
        {
            paused = !paused;
        }

        // Check for R key (restart)
        if (raylib::is_key_pressed(82)) // KEY_R
        {
            scroll_offset = 0.0;
            paused = false;
        }

        // Update scroll position (only if not paused)
        if (!paused)
        {
            scroll_offset += SCROLL_SPEED * raylib::get_frame_time();
        }

        if (scroll_offset > (float)text_count * 0.8 + 10.0)
        {
            scroll_offset = 0.0;
        }

        raylib::begin_drawing();
        raylib::clear_background(raylib::BLACK);

        // Draw stars
        for (int i = 0; i < STAR_COUNT; i++)
        {
            raylib::draw_circle(
                (int)stars[i].x,
                (int)stars[i].y,
                star_sizes[i],
                raylib::WHITE
            );
        }

        raylib::begin_mode3d(camera);

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

        raylib::end_mode3d();
        raylib::end_drawing();
    }

    // Unload textures
    for (int i = 0; i < text_count; i++)
    {
        if (text_textures[i].id != 0)
        {
            raylib::unload_render_texture(text_textures[i]);
        }
    }

    raylib::close_window();
    return 0;
}
