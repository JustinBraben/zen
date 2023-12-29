const std = @import("std");
const print = std.debug.print;

const Constants = @import("configs/Constants.zig");
const Cart = @import("Cart.zig").Cart;

const BOOT = [0x100]u8{
    // prod memory
    0x31, 0xFE, 0xFF, // LD SP,$FFFE
    // enable LCD
    0x3E, 0x91, // LD A,$91
    0xE0, 0x40, // LDH [Mem::LCDC], A
    // set flags
    0x3E, 0x01, // LD A,$01
    0xCB, 0x7F, // BIT 7,A (sets Z,n,H)
    0x37, // SCF (sets C)
    // set registers
    0x3E, 0x01, // LD A,$01
    0x06, 0x00, // LD B,$00
    0x0E, 0x13, // LD C,$13
    0x16, 0x00, // LD D,$00
    0x1E, 0xD8, // LD E,$D8
    0x26, 0x01, // LD H,$01
    0x2E, 0x4D, // LD L,$4D
    // skip to the end of the bootloader
    0xC3, 0xFD, 0x00, // JP $00FD
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00, 0x00,
    0x00, 0x00,
    0x00,
    // this instruction must be at the end of ROM --
    // after these finish executing, PC needs to be 0x100
    0xE0, 0x50, // LDH 50,A (disable boot rom)
};
const ROM_BANK_SIZE: u16 = 0x4000;
const RAM_BANK_SIZE: u16 = 0x2000;

fn panic(s: []const u8) void {
    print("{s}\n", .{s});
    std.os.abort();
}

pub const RAM = struct {
    debug: bool,
    cart: *Cart,
    ram_enable: bool,
    ram_bank_mode: bool,
    rom_bank_low: u8,
    rom_bank_high: u8,
    rom_bank: u8,
    ram_bank: u8,
    boot: [0x100]u8,
    data: [0xFFFF + 1]u8,

    pub fn init(cart: *Cart, debug: bool) !RAM {
        // var final_ram = RAM{
        //     .cart = undefined,
        //     .debug = undefined,
        // };

        // final_ram.cart = cart;
        // final_ram.debug = debug;

        return RAM{
            .debug = debug,
            .cart = cart,
            .ram_enable = true,
            .ram_bank_mode = false,
            .rom_bank_low = 1,
            .rom_bank_high = 0,
            .rom_bank = 1,
            .ram_bank = 0,
            .boot = BOOT,
            .data = [_]u8{0} ** 0x10000,
        };
    }

    /// The `get` function is responsible for reading a byte from the Gameboy's memory at the specified address.
    /// It handles various memory regions, including ROM, VRAM, external RAM, work RAM, I/O registers, sprite attribute table, etc.
    /// The function implements the memory mapping logic based on the address and ensures proper bank switching.
    /// If debugging is enabled, it prints debug information about the memory read operation.
    pub fn get(self: *RAM, addr: u16) u8 {
        var val = self.data[addr];
        switch (addr) {
            0x000...0x3FFF => {
                // ROM bank 0
                if (self.data[Constants.Mem.BOOT] == 0 and addr < 0x0100) {
                    val = self.boot[addr];
                } else {
                    val = self.cart.data[addr];
                }
            },
            0x4000...0x7FFF => {
                // Switchable ROM bank
                const bank = self.rom_bank * ROM_BANK_SIZE;
                const offset = addr - 0x4000;
                val = self.cart.data[offset + bank];
            },
            0x8000...0x9FFF => {
                // VRAM
            },
            0xA000...0xBFFF => {
                if (!self.ram_enable) {
                    panic("Reading from external ram while disabled: {:04X}");
                }

                const bank = self.ram_bank * RAM_BANK_SIZE;
                const offset = addr - 0xA000;
                if (bank + offset > self.cart.ram_size) {
                    print("Reading from external ram beyond limit: {} ({}:{})\n", .{ bank + offset, self.ram_bank, (addr - 0xA000) });
                    panic(
                        "Reading from external ram beyond limit: {:04x} ({:02x}:{:04x})",
                        //    bank + offset,
                        //    self.ram_bank,
                        //    (addr - 0xA000)
                    );
                }
                val = self.cart.ram[bank + offset];
            },
            0xC000...0xCFFF => {
                // work RAM, bank 0
            },
            0xD000...0xDFFF => {
                // work RAM, bankable in CGB
            },
            0xE000...0xFDFF => {
                val = self.data[addr - 0x2000];
            },
            0xFE00...0xFE9F => {
                // Sprite attribut table
            },
            0xFEA0...0xFEFF => {
                // Unusable
                val = 0xFF;
            },
            0xFF00...0xFF7F => {
                // IO Registers
            },
            0xFF80...0xFFFE => {
                // High RAM
            },
            0xFFFF => {
                // IE Register
            },
        }

        if (self.debug) {
            std.io.getStdOut().writer().print("ram[{X:0>4}] -> {X:0>2}\n", .{ addr, val }) catch return 0;
        }

        return val;
    }

    /// The `set` function is responsible for writing a byte to the Gameboy's memory at the specified address.
    /// It handles various memory regions, including ROM, VRAM, external RAM, work RAM, I/O registers, sprite attribute table, etc.
    /// The function implements the memory mapping logic based on the address and ensures proper bank switching.
    /// If debugging is enabled, it prints debug information about the memory write operation.
    pub fn set(self: *RAM, addr: u16, val: u8) void {
        if (self.debug) {
            std.io.getStdOut().writer().print("ram[{X:0>4}] <- {X:0>2}\n", .{ addr, val }) catch return;
        }
        switch (addr) {
            0x0000...0x1FFF => {
                self.ram_enable = val != 0;
            },
            0x2000...0x3FFF => {
                self.rom_bank_low = val;
                self.rom_bank = (self.rom_bank_high << 5) | self.rom_bank_low;
                if (self.rom_bank * ROM_BANK_SIZE > self.cart.rom_size) {
                    panic("Set rom_bank beyond the size of ROM");
                }
            },
            0x4000...0x5FFF => {
                if (self.ram_bank_mode) {
                    self.ram_bank = val;
                    if (self.ram_bank * RAM_BANK_SIZE > self.cart.ram_size) {
                        panic("Set ram_bank beyond the size of RAM");
                    }
                } else {
                    self.rom_bank_high = val;
                    self.rom_bank = (self.rom_bank_high << 5) | self.rom_bank_low;
                    if (self.rom_bank * ROM_BANK_SIZE > self.cart.rom_size) {
                        panic("Set rom_bank beyond the size of ROM");
                    }
                }
            },
            0x6000...0x7FFF => {
                self.ram_bank_mode = val != 0;
            },
            0x8000...0x9FFF => {
                // VRAM
                // TODO: if writing to tile RAM, update tiles in IO class?
            },
            0xA000...0xBFFF => {
                // external RAM, bankable
                if (!self.ram_enable) {
                    panic(
                        "Writing to external ram while disabled: {:04x}={:02x}",
                        //    addr, val
                    );
                }
                const bank = self.ram_bank * RAM_BANK_SIZE;
                const offset = addr - 0xA000;

                if (bank + offset >= self.cart.ram_size) {
                    //panic("Writing beyond RAM limit");
                    return;
                }
                self.cart.ram[(bank + offset)] = val;
            },
            0xC000...0xCFFF => {
                // work RAM, bank 0
            },
            0xD000...0xDFFF => {
                // work RAM, bankable in CGB
            },
            0xE000...0xFDFF => {
                // ram[E000-FE00] mirrors ram[C000-DE00]
                self.data[addr - 0x2000] = val;
            },
            0xFE00...0xFE9F => {
                // Sprite attribute table
            },
            0xFEA0...0xFEFF => {
                // Unusable
            },
            0xFF00...0xFF7F => {
                // IO Registers
            },
            0xFF80...0xFFFE => {
                // High RAM
            },
            0xFFFF => {
                // IE Register
            },
        }

        self.data[addr] = val;
    }
};
