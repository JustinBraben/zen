const clap = @import("clap");
const std = @import("std");
const builtin = @import("builtin");

const errors = @import("Errors.zig");

const debug = std.debug;
const io = std.io;

pub const Args = struct {
    rom: []const u8,
    headless: bool,
    silent: bool,
    debug_cpu: bool,
    debug_gpu: bool,
    debug_apu: bool,
    debug_ram: bool,
    frames: u32,
    profile: u32,
    turbo: bool,
};

pub fn printArgs() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-H, --headless         Disable GUI
        \\-S, --silent           Disable Sound
        \\-c, --debug-cpu        Debug CPU
        \\-g, --debug-gpu        Debug GPU
        \\-a, --debug-apu        Debug APU
        \\-r, --debug-ram        Debug RAM
        \\-f, --frames <u32>     Exit after N frames
        \\-p, --profile <u32>    Exit after N seconds
        \\-t, --turbo            No sleep()
        \\-v, --version          Show build info
        \\-s, --string <str>...  An option parameter which can be specified multiple times.
        \\
    );

    // Initialize our diagnostics, which can be used for reporting useful errors.
    // This is optional. You can also pass `.{}` to `clap.parse` if you don't
    // care about the extra information `Diagnostics` provides.
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        // Report useful error and exit
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        debug.print("--help\n", .{});
    }
    if (res.args.frames) |n|
        debug.print("--number = {}\n", .{n});
    if (res.args.profile) |prof|
        debug.print("--profile = {}\n", .{prof});
    for (res.args.string) |s|
        debug.print("--string = {s}\n", .{s});
}

pub fn parseArgs() !Args {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-H, --headless         Disable GUI
        \\-S, --silent           Disable Sound
        \\-c, --debug-cpu        Debug CPU
        \\-g, --debug-gpu        Debug GPU
        \\-a, --debug-apu        Debug APU
        \\-r, --debug-ram        Debug RAM
        \\-f, --frames <u32>     Exit after N frames
        \\-p, --profile <u32>    Exit after N seconds
        \\-t, --turbo            No sleep()
        \\-v, --version          Show build info
        \\-s, --string <str>...  An option parameter which can be specified multiple times.
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        // Report useful error and exit
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.version != 0) {
        try std.io.getStdOut().writer().print("{s} {s} {s}\n", .{
            builtin.zig_version_string,
            @tagName(builtin.mode),
            @tagName(builtin.zig_backend),
        });
        return errors.ControlledExit.Help;
    }

    if (res.args.help != 0) {
        try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
        return errors.ControlledExit.Help;
    }

    var frames: u32 = 0;
    if (res.args.frames) |n|{
        frames = n;
    }

    var profile: u32 = 0;
    if (res.args.profile) |n|{
            profile = n;
    }

    var rom: []const u8 = "";
    for (res.args.string) |file| {
        rom = file;
    }

    for(res.args) |arg| {
        std.debug.print()
    }

    return Args{
        .rom = rom,
        .headless = res.args.headless != 0,
        .silent = res.args.silent != 0,
        .debug_cpu = res.args.@"debug-cpu" != 0,
        .debug_gpu = res.args.@"debug-gpu" != 0,
        .debug_apu = res.args.@"debug-apu" != 0,
        .debug_ram = res.args.@"debug-ram" != 0,
        .frames = frames,
        .profile = profile,
        .turbo = res.args.turbo != 0,
    };
}

pub fn getArgs() !clap.Result {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-H, --headless         Disable GUI
        \\-S, --silent           Disable Sound
        \\-c, --debug-cpu        Debug CPU
        \\-g, --debug-gpu        Debug GPU
        \\-a, --debug-apu        Debug APU
        \\-r, --debug-ram        Debug RAM
        \\-f, --frames <u32>     Exit after N frames
        \\-p, --profile <u32>    Exit after N seconds
        \\-t, --turbo            No sleep()
        \\-v, --version          Show build info
        \\-s, --string <str>...  An option parameter which can be specified multiple times.
        \\
    );

    // Initialize our diagnostics, which can be used for reporting useful errors.
    // This is optional. You can also pass `.{}` to `clap.parse` if you don't
    // care about the extra information `Diagnostics` provides.
    var diag = clap.Diagnostic{};
    const res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        // Report useful error and exit
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    return res;
}