const std = @import("std");
const testing = std.testing;

const Error = error{UnequalType};

pub fn Pair(comptime firstTypeName: type, comptime secondTypeName: type) type {
    return struct {
        first: firstTypeName,
        second: secondTypeName,
        const Self = @This();

        // Namespaced fuunction
        pub fn new(first: firstTypeName, second: secondTypeName) Self {
            return .{ .first = first, .second = second };
        }
    };
}

test "basic u8:u8 pair" {
    const testPair = Pair(u8, u8).new(0, 0);
    try testing.expect(testPair.first == 0);
    try testing.expect(testPair.second == 0);
    try testing.expectEqual(testPair.first, testPair.second);
}

fn compareUnequalType(comptime firstTypeName: type, comptime secondTypeName: type) Error!void {
    if (firstTypeName != secondTypeName) {
        return error.UnequalType;
    }
}

test "compare unequal type error" {
    const testPair = Pair(u16, [4]u16).new(1, .{ 1, 2, 3, 4 });
    try testing.expectError(error.UnequalType, compareUnequalType(@TypeOf(testPair.first), @TypeOf(testPair.second)));
}
