const RomHeader = @import("./configs/RomTypes.zig").RomHeader;

pub const CartContext = @This();

filename: []const u8,
rom_size: u32,
rom_data: *u8,
rom_header: *RomHeader,

pub fn init(pathToFile: []const u8) !CartContext {
    return CartContext{
        .filename = pathToFile
        .rom_size = 0,
        .rom_data = 0,
        rom_header = RomHeader.init(),
    };
}