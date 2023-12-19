const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;
const Registers = @import("gb/Cpu.zig").Registers;
const Emu = @import("gb/Emu.zig").Emu;
const RomTypes = @import("gb/configs/RomTypes.zig").RomTypes;
const ArrayList = std.ArrayList;
const print = std.debug.print;

pub fn main() !void {
    std.debug.print("\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // var licCodes: LicenseCodes = LicenseCodes.init(alloc);
    // try licCodes.createLicCodes();
    // defer licCodes.deinit();

    // const entry = try licCodes.LicCodeMap.getOrPut(0);

    // std.debug.print("Found entry : {s}\n", .{entry.value_ptr.*});

    var emu = Emu.new(alloc, "../roms/Legend of Zelda, The - Link's Awakening (G) [!].gb");

    std.debug.print("Created new Emu : '{s}' , of type : '{}'\n", .{ emu.romPath, @TypeOf(emu.romPath) });

    std.debug.print("emu_get_context returns this type: {}\n", .{@TypeOf(emu.emu_get_context())});

    for (RomTypes) |RomType| {
        std.debug.print("Rom Type : {s}\n", .{RomType});
    }

    const returnVal = try emu.emu_run();

    std.debug.print("Returned code: {}\n", .{returnVal});
}
