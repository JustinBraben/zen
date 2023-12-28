const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const Args = @import("gb/Args.zig").Args;

const print = std.debug.print;

pub fn main() !void {
    print("\n", .{});

    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa_allocator.deinit() != .leak) catch @panic("memory leak");
    const gpa = gpa_allocator.allocator();

    var parse_args = try Args.init(gpa);
    defer parse_args.deinit();

    print("Args : {any}\n", .{parse_args});

    // while (parse_args.args_allocated.next()) |arg| {
    //     print("arg : {s}\n", .{arg});
    // }
}
