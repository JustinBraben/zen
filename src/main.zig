const std = @import("std");
const Pair = @import("data_structures/pair.zig").Pair;
const Registry = @import("ecs/registry.zig").Registry;
const ArrayList = std.ArrayList;
const print = std.debug.print;

const ComponentId = usize;

const Position = struct {
    x: f32,
    y: f32,
};

pub fn main() !void {
    var reg = Registry.init(std.heap.c_allocator);
    defer reg.deinit();

    //print("The next entity id is: {}\n", .{reg.next_entity_id});

    var count: u64 = 0;

    while (count < 5) : (count += 1) {
        const entityId = try reg.addEntity();
        print("Created entity with id = {}\n", .{entityId});
    }

    const pair1 = Pair(u8, u16).new(0, 2);

    print("I have created a : {}\n", .{@TypeOf(pair1)});
    print("First : {} , Type : {}\n", .{ pair1.first, @TypeOf(pair1.first) });
    print("Second : {} , Type : {}\n", .{ pair1.second, @TypeOf(pair1.second) });
}
