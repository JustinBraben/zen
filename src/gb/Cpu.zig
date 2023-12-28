const std = @import("std");

const RAM = @import("Ram.zig").RAM;
const Constants = @import("configs/Constants.zig");
const Errors = @import("Errors.zig");

pub const CPU = struct {
    regs: packed union {
        r16: packed struct {
            af: u16,
            bc: u16,
            de: u16,
            hl: u16,
        },
        r8: packed struct {
            f: u8,
            a: u8,
            c: u8,
            b: u8,
            e: u8,
            d: u8,
            l: u8,
            h: u8,
        },
        flags: packed struct {
            _p1: u4,
            c: bool,
            h: bool,
            n: bool,
            z: bool,
            _p2: u56,
        },
    },
    sp: u16,
    pc: u16,
    stop: bool,
    halt: bool,
    interrupts: bool,

    ram: *RAM,
    debug: bool,
    cycle: u32,
    owed_cycles: u32,

    pub fn init(ram: *RAM, debug: bool) !CPU {
        return CPU{
            .regs = .{
                .r16 = .{
                    .af = 0,
                    .bc = 0,
                    .de = 0,
                    .hl = 0,
                },
            },
            .sp = 0,
            .pc = 0,
            .stop = false,
            .halt = false,
            .interrupts = false,
            .ram = ram,
            .debug = debug,
            .cycle = 0,
            .owed_cycles = 0,
        };
    }

    pub fn interrupt(self: *CPU, i: u8) void {
        self.ram.set(Constants.Mem.IF, self.ram.get(Constants.Mem.IF) | i);
        self.halt = false; // interrupts interrupt HALT state
    }

    pub fn tick(self: *CPU) !void {
        self.tickDMA();
        self.tickClock();
    }

    fn tickDMA(self: *CPU) void {
        // DMA should take 26 cycles, during which main RAM is unavailable
        if (self.ram.get(Constants.Mem.DMA) != 0) {
            const dma_src = @as(u16, @intCast(self.ram.get(Constants.Mem.DMA))) << 8;

            var index: u16 = 0;
            while (index <= 0xA0) : (index += 1) {
                self.ram.set(Constants.Mem.OamBase + index, self.ram.get(dma_src + index));
            }
            self.ram.set(Constants.Mem.DMA, 0x00);
        }
    }

    fn tickClock(self: *CPU) void {
        self.cycle += 1;

        // increment at 16384Hz (each 64 cycles)
        if (self.cycle % 64 == 0) {
            self.ram.set(Constants.Mem.DIV, self.ram.get(Constants.Mem.DIV) +% 1);
        }

        if (self.ram.get(Constants.Mem.TAC) & 1 << 2 == 1 << 2) {
            // timer enable
            const speeds = [_]u16{ 256, 4, 16, 64 }; // increment per X cycles
            const speed = speeds[(self.ram.get(Constants.Mem.TAC) & 0x03)];
            if (self.cycle % speed == 0) {
                if (self.ram.get(Constants.Mem.TIMA) == 0xFF) {
                    self.ram.set(Constants.Mem.TIMA, self.ram.get(Constants.Mem.TMA)); // if timer overflows, load base
                    self.interrupt(Constants.Interrupt.TIMER);
                }
                self.ram.set(Constants.Mem.TIMA, self.ram.get(Constants.Mem.TIMA) +% 1);
            }
        }
    }
};
