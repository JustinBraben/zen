const std = @import("std");
const Args = @import("Args.zig").Args;
const Cart = @import("Cart.zig").Cart;

pub const GameBoy = struct {
    cart: Cart,

    pub fn init(self: *GameBoy, args: Args) !void {
        self.cart = try Cart.init(args.rom);
    }

    pub fn run(self: *GameBoy) !void {
        std.debug.print("\nGameBoy is running", .{});
        _ = self;
    }

    pub fn tick(self: *GameBoy) !void {
        _ = self;
    }
};