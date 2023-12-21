const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const Args = @import("gb/Args.zig").Args;
const errors = @import("gb/Errors.zig");
const assert = @import("std").debug.assert;
const Registers = @import("gb/Cpu.zig").Registers;
const Emu = @import("gb/Emu.zig").Emu;
const RomTypes = @import("gb/configs/RomTypes.zig").RomTypes;
const ArrayList = std.ArrayList;
const print = std.debug.print;

pub fn main() !void {
    std.debug.print("\n", .{});

    const args = Args.parse_args() catch |err| {
        switch (err) {
            errors.ControlledExit.Help => {
                std.os.exit(0);
            },
            else => {
                std.log.err("Unknown error {any}\n", .{err});
                std.os.exit(5);
            },
        }
    };

    std.debug.print("Arguments : {}\n", .{args});

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();

    // const alloc = arena.allocator();

    // var emu = Emu.new(alloc, "../roms/Legend of Zelda, The - Link's Awakening (G) [!].gb");

    // std.debug.print("Created new Emu : '{s}' , of type : '{}'\n", .{ emu.romPath, @TypeOf(emu.romPath) });

    // std.debug.print("emu_get_context returns this type: {}\n", .{@TypeOf(emu.emu_get_context())});

    // // for (RomTypes) |RomType| {
    // //     std.debug.print("Rom Type : {s}\n", .{RomType});
    // // }

    // const returnVal = try emu.emu_run();

    // std.debug.print("Returned code: {}\n", .{returnVal});
}
