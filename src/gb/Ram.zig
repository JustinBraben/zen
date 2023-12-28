const std = @import("std");
const print = std.debug.print;

const Constants = @import("configs/Constants.zig");
const Cart = @import("Cart.zig").Cart;

pub const RAM = struct {
    debug: bool,
    cart: *Cart,

    pub fn init(cart: *Cart, debug: bool) !RAM {
        var final_ram = RAM{
            .cart = undefined,
            .debug = undefined,
        };

        final_ram.cart = cart;
        final_ram.debug = debug;

        return final_ram;
    }
};
