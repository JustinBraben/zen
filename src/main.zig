const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;
const Registers = @import("gb/cpu.zig").Registers;
const Emu = @import("gb/Emu.zig").Emu;
const RomTypes = @import("gb/configs/RomTypes.zig").RomTypes;
const LicenseCodes = @import ("gb/configs/LicenseCodes.zig").LicenseCodes;
const ArrayList = std.ArrayList;
const print = std.debug.print;

pub fn main() !void {
    std.debug.print("\n", .{});

    var emu = Emu.new("../roms/Legend of Zelda, The - Link's Awakening (G) [!].gb");

    std.debug.print("Created new Emu : '{s}' , of type : '{}'\n", .{emu.romPath, @TypeOf(emu.romPath)});

    std.debug.print("emu_get_context returns this type: {}\n", .{@TypeOf(emu.emu_get_context())});

    for(RomTypes) |RomType| {
        std.debug.print("Rom Type : {s}\n", .{RomType});
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var licCodes: LicenseCodes = LicenseCodes.init(alloc);
    try licCodes.createLicCodes();
    defer licCodes.deinit();

    const entry = try licCodes.LicCodeMap.getOrPut(0);

    std.debug.print("Found entry : {s}\n", .{entry.value_ptr.*});

    const returnVal = try emu.emu_run();

    std.debug.print("Returned code: {}\n", .{returnVal});

    //try sdlExample();
}

pub fn sdlExample () !void {
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

    const zig_bmp = @embedFile("zig.bmp");
    const rw = c.SDL_RWFromConstMem(zig_bmp, zig_bmp.len) orelse {
        c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer assert(c.SDL_RWclose(rw) == 0);

    const zig_surface = c.SDL_LoadBMP_RW(rw, 0) orelse {
        c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_FreeSurface(zig_surface);

    const zig_texture = c.SDL_CreateTextureFromSurface(renderer, zig_surface) orelse {
        c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(zig_texture);

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, zig_texture, null, null);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}