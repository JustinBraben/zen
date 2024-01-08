const std = @import("std");

const CPU = @import("Cpu.zig").CPU;
const Constants = @import("configs/Constants.zig");

const c = @import("../clibs.zig");

pub const GPU = struct {
    cpu: *CPU,
    name: []const u8,
    headless: bool,
    debug: bool,
    cycle: u32,

    window: ?*c.SDL_Window,
    renderer: ?*c.SDL_Renderer,
    framebuffer: ?*c.SDL_Texture,

    pub fn init(cpu: *CPU, name: []const u8, headless: bool, debug: bool) !GPU {
        // Window
        var width: i32 = 160;
        var height: i32 = 144;
        if (debug) {
            width = 160 + 256;
            height = 144;
        }

        var window: ?*c.SDL_Window = undefined;
        var renderer: ?*c.SDL_Renderer = undefined;
        var framebuffer: ?*c.SDL_Texture = undefined;

        if (!headless) {
            if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) != 0) {
                return error.SDLInitializationFailed;
            }

            window = c.SDL_CreateWindow("ZenBoy", width, height, c.SDL_WINDOW_HIDDEN | c.SDL_WINDOW_VULKAN) orelse @panic("Failed to create SDL window");

            _ = c.SDL_ShowWindow(window);

            renderer = c.SDL_CreateRenderer(window, null, c.SDL_RENDERER_ACCELERATED) orelse {
                c.SDL_DestroyWindow(window);
                c.SDL_Quit();
                @panic("Failed to create SDL Renderer");
            };

            framebuffer = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ABGR8888, c.SDL_TEXTUREACCESS_STREAMING, @intCast(width), @intCast(height)) orelse {
                c.SDL_DestroyRenderer(renderer);
                c.SDL_DestroyWindow(window);
                c.SDL_Quit();
                @panic("Failed to create SDL frame buffer");
            };
        }

        // if (!headless) {
        //     if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        //         c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        //         return error.SDLInitializationFailed;
        //     }

        //     const screen = c.SDL_CreateWindow("ZenBoy", width, height, c.SDL_WINDOW_OPENGL) orelse {
        //         c.SDL_Quit();
        //         return error.SDLWindowCreationFailed;
        //     };
        //     _ = screen; // autofix
        // }

        return GPU{
            .cpu = cpu,
            .name = name,
            .headless = headless,
            .debug = debug,
            .cycle = 0,
            .window = window,
            .renderer = renderer,
            .framebuffer = framebuffer,
        };
    }

    pub fn tick(self: *GPU) !void {

        // CPU STOP stops all LCD activity until a button is pressed
        if (self.cpu.stop) {
            return;
        }
    }

    pub fn deinit(self: *GPU) void {
        if (self.debug) {
            std.debug.print("GPU deinit has been called, closing sdl window if not headless\n", .{});
        }

        if (!self.headless) {
            c.SDL_DestroyWindow(self.window);
            c.SDL_Quit();
        }
    }
};
