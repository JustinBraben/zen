const std = @import("std");
const Entity = @import("entity.zig").Entity;

pub const void_group_hash = std.math.maxInt(u64);

pub const Registry = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayList(u64),
    next_id: u64,

    pub fn init(allocator: std.mem.Allocator) Registry {
        const registry = Registry{ .allocator = allocator, .entities = std.ArrayList(u64).init(allocator), .next_id = 0 };
        return registry;
    }

    pub fn deinit(self: *Registry) void {
        self.entities.deinit();
    }

    pub fn addEntity(self: *Registry) !u64 {
        try self.entities.append(self.next_id);
        const entityId = self.next_id;
        self.next_id += 1;
        return entityId;
    }
};
