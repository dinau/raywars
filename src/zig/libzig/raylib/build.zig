const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const allocator = b.allocator;
    const current_dir_abs = b.build_root.handle.realpathAlloc(allocator, ".") catch unreachable;
    defer allocator.free(current_dir_abs);
    const mod_name = std.fs.path.basename(current_dir_abs);

    const sOS = @tagName(builtin.target.os.tag);
    const raylib_path = "../../../../../libs/" ++ sOS ++ "/raylib";
    const static_link = true;

    // -----
    // step
    // -----
    const step = b.addTranslateC(.{
        .root_source_file = b.path("src/impl_raylib.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    step.addIncludePath(b.path(raylib_path   ++ "/include"));

    // -------
    // module
    // -------
    const mod = step.addModule(mod_name);
    mod.addIncludePath(b.path(raylib_path   ++ "/include"));
    mod.addImport(mod_name, mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });

    switch (builtin.target.os.tag) {
        .windows => {
            mod.addIncludePath(b.path(raylib_path ++ "/include"));
            if (static_link){
                mod.addObjectFile(b.path(raylib_path ++ "/lib/libraylib.a"));
            }else{
                mod.addObjectFile(b.path(raylib_path ++ "/lib/libraylibdll.a"));
            }
        },
        .linux => {
            mod.addIncludePath(b.path(raylib_path ++ "/include"));
            if (static_link){
                mod.addObjectFile(b.path(raylib_path ++ "/lib/libraylib.a"));
            }else{
                mod.addObjectFile(b.path(raylib_path ++ "/lib/libraylib.so.550"));
            }
        },
        else => {},
    }

    //---------
    // Linking
    //---------
    if (builtin.target.os.tag == .windows) {
        lib.root_module.linkSystemLibrary("opengl32", .{});
        lib.root_module.linkSystemLibrary("gdi32", .{});
        lib.root_module.linkSystemLibrary("winmm", .{});
        lib.root_module.linkSystemLibrary("user32", .{});
        lib.root_module.linkSystemLibrary("kernel32", .{});
        lib.root_module.linkSystemLibrary("shell32", .{});
        lib.root_module.linkSystemLibrary("imm32", .{});
    } else if (builtin.target.os.tag == .linux) {
        lib.root_module.linkSystemLibrary("GL", .{});
        lib.root_module.linkSystemLibrary("X11", .{});
    }

    b.installArtifact(lib);
}
