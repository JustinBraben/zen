entry: [4]u8 = undefined,
logo: [0x30]u8 = undefined,

title: [16]const u8 = undefined,
new_lic_code: u16 = undefined,
sgb_flag: u8 = undefined,
typeName: u8 = undefined,
rom_size: u8 = undefined,
ram_size: u8 = undefined,
dest_code: u8 = undefined,
lic_code: u8 = undefined,
version: u8 = undefined,
checksum: u8 = undefined,
global_checksum: u16 = undefined,

pub const RomHeader = @This();

pub fn init() !RomHeader {
    return RomHeader{

    }
}

pub fn cart_load(cart: []const u8) bool{

    
    return true;
}