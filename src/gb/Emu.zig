const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const EmuContext = @import("EmuContext.zig").EmuContext;
const Cart = @import("Cart.zig").Cart;

pub const Emu = @This();

romPath: []const u8,
emu_context: EmuContext,
cartridge: Cart,

pub fn new(allocator: std.mem.Allocator, pathToRom: []const u8) Emu {
    return .{
        .romPath = pathToRom, 
        .emu_context = try EmuContext.init(),
        .cartridge = Cart.init(allocator, pathToRom),
    };
}

pub fn emu_get_context(self: *Emu) *EmuContext {
    return &self.emu_context;
}

pub fn emu_run(self: *Emu) !i8 {
    std.debug.print("Usage: emu {s}\n", .{self.romPath});
    std.debug.print("Emu is running: {}\n", .{self.emu_context.running});

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 400, 140, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    while (self.emu_context.running) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    self.emu_context.running = false;
                },
                else => {},
            }
        }

        if(self.emu_context.paused){
            c.SDL_Delay(10);
            continue;
        }
    }

    return 0;
}

fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}