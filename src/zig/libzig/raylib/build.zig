const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const allocator = b.allocator;
    const current_dir_abs = b.build_root.handle.realpathAlloc(allocator, ".") catch unreachable;
    defer allocator.free(current_dir_abs);
    const mod_name = std.fs.path.basename(current_dir_abs);

    // -----
    // step
    // -----
    const step = b.addTranslateC(.{
        .root_source_file = b.path("src/impl_raylib.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const raylib_win   = "../../../../../libs/win/raylib";
    const raylib_linux = "../../../../../libs/linux/raylib";
    switch (builtin.target.os.tag) {
        .windows => step.addIncludePath(b.path(raylib_win   ++ "/include")),
        .linux =>   step.addIncludePath(b.path(raylib_linux ++ "/include")),
        else => {},
    }

    // -------
    // module
    // -------
    const mod = step.addModule(mod_name);
    switch (builtin.target.os.tag) {
        .windows => mod.addIncludePath(b.path(raylib_win   ++ "/include")),
        .linux =>   mod.addIncludePath(b.path(raylib_linux ++ "/include")),
        else => {},
    }
    mod.addImport(mod_name, mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });

    switch (builtin.target.os.tag) {
        .windows => lib.addObjectFile(b.path(raylib_win   ++ "/lib/libraylib.a" )),
        .linux =>   lib.addObjectFile(b.path(raylib_linux ++ "/lib/libraylib.a" )),
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
