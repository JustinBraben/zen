const std = @import("std");

const CPU = @import("Cpu.zig").CPU;
const Constants = @import("configs/Constants.zig");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const GPU = struct {
    cpu: *CPU,
    name: []const u8,
    headless: bool,
    debug: bool,

    pub fn init(cpu: *CPU, name: []const u8, headless: bool, debug: bool) !GPU {
        return GPU{
            .cpu = cpu,
            .name = name,
            .headless = headless,
            .debug = debug,
        };
    }

    pub fn tick(self: *GPU) !void {

        // CPU STOP stops all LCD activity until a button is pressed
        if (self.cpu.stop) {
            return;
        }
    }
};
