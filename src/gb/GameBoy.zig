const std = @import("std");
const Cart = @import("Cart.zig").Cart;
const Args = @import("Args.zig").Args;
const RAM = @import("Ram.zig").RAM;
const CPU = @import("Cpu.zig").CPU;

pub const GameBoy = struct {
    ram: RAM,
    cart: Cart,
    cpu: CPU,

    pub fn init(self: *GameBoy, allocator: std.mem.Allocator, args: Args) !void {
        self.cart = try Cart.init(allocator, args.rom);
        self.ram = try RAM.init(&self.cart, args.debug_ram);
        self.cpu = try CPU.init(&self.ram, args.debug_cpu);
    }

    pub fn deinit(self: *GameBoy, allocator: std.mem.Allocator) void {
        self.cart.deinit(allocator);
    }

    pub fn run(self: *GameBoy) !void {
        while (true) {
            try self.tick();
        }
    }

    pub fn tick(self: *GameBoy) !void {
        try self.cpu.tick();
    }
};
