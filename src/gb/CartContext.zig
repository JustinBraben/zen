const CartContext = @import("CartContext").CartContext;

pub const CartContext = @This();

filename: []const u8,
rom_size: u32,
rom_data: *u8,
rom_header: *CartContext,

pub fn init() !EmuContext {
    return EmuContext{
        .paused = false,
        .running = true,
        .ticks = 0,
    };
}