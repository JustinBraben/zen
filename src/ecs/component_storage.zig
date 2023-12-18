const std = @import("std");
const utils = @import("utils.zig");

pub fn ComponentStorage(comptime ComponentTypeName: type, comptime EntityTypeName: type) type {
    return struct {
        const Self = @This();

        set: std.AutoHashMap(EntityTypeName, void),
        allocator: ?std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            var store = Self{
                .set = std.AutoArrayHashMap(EntityTypeName, void).init(allocator),
            };
            _ = store;
        }
    };

    std.debug.assert(!utils.isComptime(ComponentTypeName));
}
