const std = @import("std");
const RomHeader = @import("RomHeader.zig").RomHeader;
const LicenseCodes = @import("./configs/LicenseCodes.zig").LicenseCodes;
const RomTypes = @import("./configs/RomTypes.zig").RomTypes;
const CartContext = @import("CartContext.zig").CartContext;

pub const Cart = @This();

cart_context: CartContext,
license_codes: LicenseCodes,

pub fn init(allocator: std.mem.Allocator, pathToRom: []const u8) Cart {
    return Cart{
        .cart_context = CartContext.init(pathToRom),
        .license_codes = LicenseCodes.init(allocator),
    };
}

pub fn cart_lic_name(self: *Cart) []const u8 {
    if (self.cart_context.rom_header.new_lic_code <= 0xA4){
        return self.license_codes.LicCodeMap.getOrPut(self.cart_context.rom_header.lic_code);
    }

    return "UNKNOWN";
}

pub fn cart_type_name(self: *Cart) []const u8 {
    if (self.cart_context.rom_header.typeName <= 0x22) {
        return RomTypes[self.cart_context.rom_header.typeName];
    }

    return "UNKNOWN";
}

pub fn cart_load(self: *Cart) bool {
    
    const data = @embedFile(self.cart_context.filename);

    std.debug.print("{}\n", .{data});

    return true;
}