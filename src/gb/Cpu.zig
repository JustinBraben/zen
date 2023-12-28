const std = @import("std");

const RAM = @import("Ram.zig").RAM;
const Constants = @import("configs/Constants.zig");
const Errors = @import("Errors.zig");

pub const CPU = struct {
    ram: *RAM,
    debug: bool,

    pub fn init(ram: *RAM, debug: bool) !CPU {
        return CPU{
            .ram = ram,
            .debug = debug,
        };
    }

    pub fn tick(self: *CPU) !void {
        _ = self; // autofix

    }
};
