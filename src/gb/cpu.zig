pub fn Registers() type {
    return struct {
        a: u8,
        b: u8,
        c: u8,
        d: u8,
        e: u8,
        f: u8,
        h: u8,
        l: u8,

        const Self = @This();

        pub fn get_bc(self: *Registers) u16 {
            return @as(u16, @as(u16, self.b << 8) | self.c);
        }

        pub fn set_bc(self: *Registers, value: u16) void {
            self.b = @as(u8, (value & 0xFF00) >> 8);
            self.c = @as(u8, value & 0xFF);
        }
    };
}