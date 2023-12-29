const std = @import("std");
const Cart = @import("Cart.zig").Cart;
const Args = @import("Args.zig").Args;
const RAM = @import("Ram.zig").RAM;
const CPU = @import("Cpu.zig").CPU;
const GPU = @import("Gpu.zig").GPU;

pub const GameBoy = struct {
    ram: RAM,
    cart: Cart,
    cpu: CPU,
    gpu: GPU,

    pub fn init(self: *GameBoy, allocator: std.mem.Allocator, args: Args) !void {
        self.cart = try Cart.init(allocator, args.rom);
        self.ram = try RAM.init(&self.cart, args.debug_ram);
        self.cpu = try CPU.init(&self.ram, args.debug_cpu);
        self.gpu = try GPU.init(&self.cpu, self.cart.name, args.headless, args.debug_gpu);
    }

    pub fn deinit(self: *GameBoy, allocator: std.mem.Allocator) void {
        self.cart.deinit(allocator);
    }

    pub fn run(self: *GameBoy) !void {
        std.debug.print("GameBoy is now running\n", .{});
        while (true) {
            try self.tick();
        }
    }

    pub fn tick(self: *GameBoy) !void {
        try self.cpu.tick();
        try self.gpu.tick();
    }
};
