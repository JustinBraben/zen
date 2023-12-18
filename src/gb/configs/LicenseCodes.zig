const std = @import("std");

pub const LicenseCodes = @This();

LicCodeMap: std.AutoHashMap(u8, []const u8),

pub fn init(allocator: std.mem.Allocator) LicenseCodes {
    return LicenseCodes{
        .LicCodeMap = std.AutoHashMap(u8, []const u8).init(allocator),
    };
}

pub fn deinit(self: *LicenseCodes) void {
    self.LicCodeMap.deinit();
}

pub fn createLicCodes(self: *LicenseCodes) !void {
    try self.LicCodeMap.put(0x00, "None");
    try self.LicCodeMap.put(0x01, "Nintendo R&D1");
    try self.LicCodeMap.put(0x08, "Capcom");
    try self.LicCodeMap.put(0x13, "Electronic Arts");
    try self.LicCodeMap.put(0x18, "Hudson Soft");
    try self.LicCodeMap.put(0x19, "b-ai");
    try self.LicCodeMap.put(0x20, "kss");
    try self.LicCodeMap.put(0x22, "pow");
    try self.LicCodeMap.put(0x24, "PCM Complete");
    try self.LicCodeMap.put(0x25, "san-x");
    try self.LicCodeMap.put(0x28, "Kemco Japan");
    try self.LicCodeMap.put(0x29, "seta");
    try self.LicCodeMap.put(0x30, "Viacom");
    try self.LicCodeMap.put(0x31, "Nintendo");
    try self.LicCodeMap.put(0x32, "Bandai");
    try self.LicCodeMap.put(0x33, "Ocean/Acclaim");
    try self.LicCodeMap.put(0x34, "Konami");
    try self.LicCodeMap.put(0x35, "Hector");
    try self.LicCodeMap.put(0x37, "Taito");
    try self.LicCodeMap.put(0x38, "Hudson");
    try self.LicCodeMap.put(0x39, "Banpresto");
    try self.LicCodeMap.put(0x41, "Ubi Soft");
    try self.LicCodeMap.put(0x42, "Atlus");
    try self.LicCodeMap.put(0x44, "Malibu");
    try self.LicCodeMap.put(0x46, "angel");
    try self.LicCodeMap.put(0x47, "Bullet-Proof");
    try self.LicCodeMap.put(0x49, "irem");
    try self.LicCodeMap.put(0x50, "Absolute");
    try self.LicCodeMap.put(0x51, "Acclaim");
    try self.LicCodeMap.put(0x52, "Activision");
    try self.LicCodeMap.put(0x53, "American sammy");
    try self.LicCodeMap.put(0x54, "Konami");
    try self.LicCodeMap.put(0x55, "Hi tech entertainment");
    try self.LicCodeMap.put(0x56, "LJN");
    try self.LicCodeMap.put(0x57, "Matchbox");
    try self.LicCodeMap.put(0x58, "Mattel");
    try self.LicCodeMap.put(0x59, "Milton Bradley");
    try self.LicCodeMap.put(0x60, "Titus");
    try self.LicCodeMap.put(0x61, "Virgin");
    try self.LicCodeMap.put(0x64, "LucasArts");
    try self.LicCodeMap.put(0x67, "Ocean");
    try self.LicCodeMap.put(0x69, "Electronic Arts");
    try self.LicCodeMap.put(0x70, "Infogrames");
    try self.LicCodeMap.put(0x71, "Interplay");
    try self.LicCodeMap.put(0x72, "Broderbund");
    try self.LicCodeMap.put(0x73, "sculptured");
    try self.LicCodeMap.put(0x75, "sci");
    try self.LicCodeMap.put(0x78, "THQ");
    try self.LicCodeMap.put(0x79, "Accolade");
    try self.LicCodeMap.put(0x80, "misawa");
    try self.LicCodeMap.put(0x83, "lozc");
    try self.LicCodeMap.put(0x86, "Tokuma Shoten Intermedia");
    try self.LicCodeMap.put(0x87, "Tsukuda Original");
    try self.LicCodeMap.put(0x91, "Chunsoft");
    try self.LicCodeMap.put(0x92, "Video system");
    try self.LicCodeMap.put(0x93, "Ocean/Acclaim");
    try self.LicCodeMap.put(0x95, "Varie");
    try self.LicCodeMap.put(0x96, "Yonezawa/s’pal");
    try self.LicCodeMap.put(0x97, "Kaneko");
    try self.LicCodeMap.put(0x99, "Pack in soft");
    try self.LicCodeMap.put(0xA4, "Konami (Yu-Gi-Oh!)");
}