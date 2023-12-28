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

    pub fn init(fileName: []const u8) !Cart {
        var f = try fs.cwd().openFile(fileName, fs.File.OpenFlags{ .mode = .read_only });
        defer f.close();

        var final_cart = Cart{};

        return final_cart;
    }
};
