const c = @import("../clibs.zig");

const Errors = @import("Errors.zig");
const Constants = @import("configs/Constants.zig");
const CPU = @import("Cpu.zig").CPU;
const RAM = @import("Ram.zig").RAM;

const Joypad = struct {
    const MODE_BUTTONS: u8 = 1 << 5;
    const MODE_DPAD: u8 = 1 << 4;
    const DOWN: u8 = 1 << 3;
    const START: u8 = 1 << 3;
    const UP: u8 = 1 << 2;
    const SELECT: u8 = 1 << 2;
    const LEFT: u8 = 1 << 1;
    const B: u8 = 1 << 1;
    const RIGHT: u8 = 1 << 0;
    const A: u8 = 1 << 0;
    const BUTTON_BITS: u8 = 0b00001111;
};

pub const Buttons = struct {
    cpu: *CPU,
    ram: *RAM,
    turbo: bool,

    cycle: u32,
    up: bool,
    down: bool,
    left: bool,
    right: bool,
    a: bool,
    b: bool,
    start: bool,
    select: bool,

    pub fn init(cpu: *CPU, ram: *RAM, headless: bool) !Buttons {
        if (!headless) {
            if (c.SDL_Init(c.SDL_INIT_GAMEPAD) != 0) {
                return error.SDLGamePadInitializationFailed;
            }
        }

        return Buttons{
            .cpu = cpu,
            .ram = ram,
            .turbo = false,
            .cycle = 0,
            .up = false,
            .down = false,
            .left = false,
            .right = false,
            .a = false,
            .b = false,
            .start = false,
            .select = false,
        };
    }

    pub fn tick(self: *Buttons) !void {
        self.cycle += 1;
        self.update_buttons();
        if (self.cycle % 17556 == 20) {
            if (try self.handle_inputs()) {
                self.cpu.stop = false;
                self.cpu.interrupt(Constants.Interrupt.JOYPAD);
            }
        }
    }

    pub fn update_buttons(self: *Buttons) void {
        var joyp = ~self.ram.get(Constants.Mem.JOYP);
        joyp &= 0x30;
        if (joyp & Joypad.MODE_DPAD != 0) {
            if (self.up) joyp |= Joypad.UP;
            if (self.down) joyp |= Joypad.DOWN;
            if (self.left) joyp |= Joypad.LEFT;
            if (self.right) joyp |= Joypad.RIGHT;
        }
        if (joyp & Joypad.MODE_BUTTONS != 0) {
            if (self.b) joyp |= Joypad.B;
            if (self.a) joyp |= Joypad.A;
            if (self.start) joyp |= Joypad.START;
            if (self.select) joyp |= Joypad.SELECT;
        }
        self.ram.set(Constants.Mem.JOYP, ~joyp & 0x3F);
    }

    pub fn handle_inputs(self: *Buttons) !bool {
        var need_interrupt = false;
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => return Errors.ControlledExit.Quit,
                c.SDL_EVENT_KEY_DOWN => {
                    need_interrupt = true;
                    switch (event.key.keysym.scancode) {
                        c.SDL_SCANCODE_ESCAPE => return Errors.ControlledExit.Quit,
                        c.SDL_SCANCODE_LSHIFT => {
                            self.turbo = true;
                            need_interrupt = false;
                        },
                        c.SDL_SCANCODE_W => self.up = true,
                        c.SDL_SCANCODE_S => self.down = true,
                        c.SDL_SCANCODE_A => self.left = true,
                        c.SDL_SCANCODE_D => self.right = true,
                        c.SDL_SCANCODE_Z => self.b = true,
                        c.SDL_SCANCODE_X => self.a = true,
                        c.SDL_SCANCODE_RETURN => self.start = true,
                        c.SDL_SCANCODE_SPACE => self.select = true,
                        else => {
                            need_interrupt = false;
                        },
                    }
                },
                c.SDL_EVENT_KEY_UP => {
                    need_interrupt = true;
                    switch (event.key.keysym.scancode) {
                        c.SDL_SCANCODE_LSHIFT => self.turbo = false,
                        c.SDL_SCANCODE_W => self.up = false,
                        c.SDL_SCANCODE_S => self.down = false,
                        c.SDL_SCANCODE_A => self.left = false,
                        c.SDL_SCANCODE_D => self.right = false,
                        c.SDL_SCANCODE_Z => self.b = false,
                        c.SDL_SCANCODE_X => self.a = false,
                        c.SDL_SCANCODE_RETURN => self.start = false,
                        c.SDL_SCANCODE_SPACE => self.select = false,
                        else => {},
                    }
                },
                else => {},
            }
        }

        return need_interrupt;
    }
};
