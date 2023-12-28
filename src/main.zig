const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const Args = @import("gb/Args.zig").Args;
const GameBoy = @import("gb/GameBoy.zig").GameBoy;

const print = std.debug.print;

pub fn main() !void {
    print("\n", .{});

    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa_allocator.deinit() != .leak) catch @panic("memory leak");
    const gpa = gpa_allocator.allocator();

    var parse_args = try Args.init(gpa);
    defer parse_args.deinit();

    //print("Args : {any}\n", .{parse_args});

    var gameboy: GameBoy = undefined;
    try gameboy.init(gpa, parse_args);
    defer gameboy.deinit(gpa);

    // inline for (std.meta.fields(@TypeOf(gameboy))) |field| {
    //     std.debug.print(field.name ++ " {any}", .{@as(field.type, @field(gameboy, field.name))});
    // }
    // print("\n", .{});

    print("logo : {any}, name : {s}, cart_type : {}\n", .{ gameboy.cart.logo, gameboy.cart.name, gameboy.cart.cart_type });

    // while (parse_args.args_allocated.next()) |arg| {
    //     print("arg : {s}\n", .{arg});
    // }
}
