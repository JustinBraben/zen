const std = @import("std");
const fs = std.fs;

const errors = @import("errors.zig");

const KB: u32 = 1024;

fn parseRomSize(val: u8) u32 {
    return (32 * KB) << @as(u5, @intCast(val));
}

fn parseRamSize(val: u8) u32 {
    return switch (val) {
        0 => 0,
        2 => 8 * KB,
        3 => 32 * KB,
        4 => 128 * KB,
        5 => 64 * KB,
        else => 0,
    };
}

pub const Cart = struct {
    data: []const u8,

    pub fn init(fileName: []const u8) !Cart {

        std.debug.print("Printing Rom Name : {s}\n", .{fileName});

        return Cart{
            .data = fileName,
        };
    }
};