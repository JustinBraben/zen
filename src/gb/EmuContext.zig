const std = @import("std");

pub const EmuContext = @This();

paused: bool,
running: bool,
ticks: u64,

pub fn init() !EmuContext {
    return EmuContext{
        .paused = false,
        .running = true,
        .ticks = 0,
    };
}