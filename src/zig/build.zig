const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib = "raylib";
    const exe = b.addExecutable(.{
        .name = "raywars",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/raywars.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{.name = raylib, .module = b.lazyDependency(raylib, .{}).?.module(raylib)},
            },
        }),
    });

    // for root_module
    exe.root_module.link_libc = true;

    // Add Icon to Windows exe file
    switch (builtin.target.os.tag) {
        .windows => {
            exe.root_module.addWin32ResourceFile(.{ .file = b.path("src/res/ray.rc") });
        },
        .linux => {},
        else => {},
    }

    // Hide console window
    exe.subsystem = .Windows;

    b.installArtifact(exe);

    const res1 = b.addInstallFile(b.path("../../resources/message.txt"), "bin/resources/message.txt");
    b.getInstallStep().dependOn(&res1.step);

    const soundName = "Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30.mp3";
    const res2 = b.addInstallFile(b.path(b.pathJoin(&.{"../../resources/", soundName})), b.pathJoin(&.{"bin/resources/", soundName}));
    b.getInstallStep().dependOn(&res2.step);

    const res3 = b.addInstallFile(b.path("./resources/ray.png"), "bin/resources/ray.png");
    b.getInstallStep().dependOn(&res3.step);


    // for Dynamic link
    //switch (builtin.target.os.tag) {
    //    .windows => {
    //        const raylib_lib_win_dir = "../../../libs/win/raylib/lib";
    //        const dll = "/raylib.dll";
    //        const res = b.addInstallFile(b.path(raylib_lib_win_dir ++ dll), "bin" ++ dll);
    //        b.getInstallStep().dependOn(&res.step);
    //    },
    //    .linux => {},
    //    else => {},
    //}

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
