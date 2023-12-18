const std = @import("std");

pub fn isComptime(comptime TypeName: type) bool {
    return switch (@typeInfo(TypeName)) {
        .CompTimeInt, .ComptimeFloat => true,
        else => false,
    };
}
