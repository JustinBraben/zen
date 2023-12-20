const clap = @import("clap");
const std = @import("std");
const builtin = @import("builtin");

const errors = @import("../gb/Errors.zig");

const debug = std.debug;
const io = std.io;

// pub const params = clap.parseParamsComptime(
//     \\-h, --help             Display this help and exit.
//     \\-H, --headless         Disable GUI
//     \\-S, --silent           Disable Sound
//     \\-c, --debug-cpu        Debug CPU
//     \\-g, --debug-gpu        Debug GPU
//     \\-a, --debug-apu        Debug APU
//     \\-r, --debug-ram        Debug RAM
//     \\-f, --frames <u32>     Exit after N frames
//     \\-p, --profile <u32>    Exit after N seconds
//     \\-t, --turbo            No sleep()
//     \\-v, --version          Show build info
//     \\-s, --string <str>...  An option parameter which can be specified multiple times.
//     \\
// );

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
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) Args {
        return Args{
            .rom = "Default Rom",
            .headless = false,
            .silent = false,
            .debug_cpu = false,
            .debug_gpu = false,
            .debug_apu = false,
            .debug_ram = false,
            .frames = 0,
            .profile = 0,
            .turbo = false,
            .allocator = alloc,
        };
    }

    pub fn deinit(self: *Args) void {
        self.allocator.destroy();
    }
};