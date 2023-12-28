const std = @import("std");
const Cart = @import("Cart.zig").Cart;
const Args = @import("Args.zig").Args;

pub const GameBoy = struct {
    cart: Cart,

    pub fn init(self: *GameBoy, allocator: std.mem.Allocator, args: Args) !void {
        self.cart = try Cart.init(allocator, args.rom);
    }

    pub fn deinit(self: *GameBoy, allocator: std.mem.Allocator) void {
        self.cart.deinit(allocator);
    }

    pub fn run(self: *GameBoy) !void {
        while (true) {
            try self.tick();
        }
    }

    pub fn tick(self: *GameBoy) !void {
        _ = self; // autofix

    }
};
