const std = @import("std");
const fs = std.fs;

const Errors = @import("Errors.zig");

const KB: u32 = 1024;

fn parse_rom_size(val: u8) u32 {
    return (32 * KB) << @as(u5, @intCast(val));
}

fn parse_ram_size(val: u8) u32 {
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
        errdefer allocator.free(data);
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

        final_cart.logo = data[0x104 .. 0x104 + 48];
        final_cart.name = data[0x134 .. 0x134 + 15];

        final_cart.is_gbc = data[0x143] == 0x80;
        final_cart.licensee = @as(u16, @intCast(data[0x144])) << 8 | @as(u16, @intCast(data[0x145]));
        final_cart.is_sgb = data[0x146] == 0x03;
        final_cart.cart_type = data[0x147];
        final_cart.rom_size = parse_rom_size(data[0x148]);
        final_cart.ram_size = parse_ram_size(data[0x149]);
        final_cart.destination = data[0x14A];
        final_cart.old_licensee = data[0x14B];
        final_cart.rom_version = data[0x14C];
        final_cart.complement_check = data[0x14D];
        final_cart.checksum = @as(u16, @intCast(data[0x14E])) << 8 | @as(u16, @intCast(data[0x14F]));

        var logo_checksum: u16 = 0;
        for (final_cart.logo) |i| {
            logo_checksum += i;
        }
        if (logo_checksum != 5446) {
            return Errors.UserException.LogoChecksumFailed;
        }

        var header_checksum: u16 = 25;
        for (data[0x0134..0x014E]) |i| {
            header_checksum += i;
        }
        if ((header_checksum & 0xFF) != 0) {
            return Errors.UserException.HeaderChecksumFailed;
        }

        final_cart.ram = try allocator.alloc(u8, final_cart.ram_size);
        errdefer allocator.free(final_cart.ram);

        return final_cart;
    }

    pub fn deinit(self: *Cart, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
        allocator.free(self.ram);
    }
};
