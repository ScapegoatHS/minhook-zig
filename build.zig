const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const minhook = b.dependency("minhook", .{});

    const minhook_c_module = b.createModule(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    minhook_c_module.addIncludePath(minhook.path("include"));
    minhook_c_module.addCSourceFiles(.{
        .root = minhook.path("src"),
        .files = &.{
            "buffer.c",
            "hook.c",
            "trampoline.c",
            "hde/hde32.c",
            "hde/hde64.c",
        },
        .flags = &.{},
    });

    const lib = b.addLibrary(.{
        .name = "minhook",
        .linkage = .static,
        .root_module = minhook_c_module,
    });

    b.installArtifact(lib);

    const minhook_module = b.addModule("minhook", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("minhook.zig"),
    });

    const test_executable = b.addTest(.{
        .root_module = minhook_module,
    });

    const test_step = b.step("test", "");
    test_step.dependOn(&test_executable.step);
}
