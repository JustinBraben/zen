const std = @import("std");

pub const Entity = struct {
    id: usize,

    pub fn init() @This() {
        return @This(){};
    }
};
