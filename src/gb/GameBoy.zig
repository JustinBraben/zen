const Cart = @import("Cart.zig").Cart;
const Args = @import("Args.zig").Args;

pub const GameBoy = struct {
    cart: Cart,

    pub fn init(self: *GameBoy, args: Args) !void {
        _ = self; // autofix
        _ = args; // autofix

    }
};
