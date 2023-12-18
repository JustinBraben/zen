const RomHeader = @import("RomHeader.zig").RomHeader;
const LicenseCodes = @import("./configs/LicenseCodes.zig").LicenseCodes;
const RomTypes = @import("./configs/RomTypes.zig").RomType;
const CartContext = @import("CarContext.zig").CartContext;

pub const Cart = @This();

cart_context: CartContext,