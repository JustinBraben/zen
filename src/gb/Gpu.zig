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
        // Window
        var width: i32 = 160;
        var height: i32 = 144;
        if (debug) {
            width = 160 + 256;
            height = 144;
        }

        if (!headless) {
            if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
                c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
                return error.SDLInitializationFailed;
            }

            const screen = c.SDL_CreateWindow("ZenBoy", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_OPENGL) orelse {
                c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
                return error.SDLInitializationFailed;
            };
            _ = screen; // autofix
        }

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
