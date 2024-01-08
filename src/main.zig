const std = @import("std");
const Args = @import("gb/Args.zig").Args;
const GameBoy = @import("gb/GameBoy.zig").GameBoy;
const Errors = @import("gb/Errors.zig");

const print = std.debug.print;

pub fn main() !void {
    print("\n", .{});

    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa_allocator.deinit() != .leak) catch @panic("memory leak");
    const gpa = gpa_allocator.allocator();

    var parse_args = try Args.init(gpa);
    defer parse_args.deinit();

    // var gameboy: GameBoy = undefined;
    // try gameboy.init(gpa, parse_args);
    // defer gameboy.deinit(gpa);

    // defer c.SDL_Quit();

    // gameboy.run() catch |err| {
    //     switch (err) {
    //         Errors.ControlledExit.Timeout => {
    //             // the place that we raise this prints the output
    //             std.os.exit(0);
    //         },
    //         Errors.ControlledExit.Quit => {
    //             std.os.exit(0);
    //         },
    //         Errors.ControlledExit.Help => {
    //             std.os.exit(0);
    //         },
    //         else => {
    //             std.log.err("Unknown error {any}\n", .{err});
    //             std.os.exit(5);
    //         },
    //     }
    // };

    // std.os.exit(1);
}
