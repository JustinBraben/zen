const std = @import("std");
const fs = std.fs;

const errors = @import("Errors.zig");

const KB: u32 = 1024;

pub const Cart = struct {
    data: []const u8,
    ram: []u8,

    logo: []u8,
    name: []const u8,
    is_gbc: bool,
    licensee: u16,
    is_sgb: bool,
    cart_type: u8,
    rom_size: u32,
    ram_size: u32,
    destination: u8,
    old_licensee: u8,
    rom_version: u8,
    complement_check: u8,
    checksum: u16,

    pub fn init(allocator: std.mem.Allocator, fileName: []const u8) !Cart {
        var file = try fs.cwd().openFile(fileName, fs.File.OpenFlags{ .mode = .read_only });
        defer file.close();

        var data = try allocator.alloc(u8, (try file.stat()).size);
        _ = try file.read(data[0..]);

        var final_cart = Cart{
            .data = undefined,
            .ram = undefined,

            .logo = undefined,
            .name = undefined,
            .is_gbc = false,
            .licensee = undefined,
            .is_sgb = false,
            .cart_type = undefined,
            .rom_size = undefined,
            .ram_size = undefined,
            .destination = undefined,
            .old_licensee = undefined,
            .rom_version = undefined,
            .complement_check = undefined,
            .checksum = undefined,
        };

        final_cart.data = data;

        const logo: *[48]u8 = data[0x104 .. 0x104 + 48];
        const name: *[15]u8 = data[0x134 .. 0x134 + 15];

        final_cart.logo = logo;
        final_cart.name = name;

        return final_cart;
    }

    pub fn deinit(self: *Cart, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }
};
