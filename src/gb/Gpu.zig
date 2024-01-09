const std = @import("std");

const CPU = @import("Cpu.zig").CPU;
const Constants = @import("configs/Constants.zig");

const c = @import("../clibs.zig");

const SCALE = 2;
const rmask = 0x000000ff;
const gmask = 0x0000ff00;
const bmask = 0x00ff0000;
const amask = 0xff000000;

const LCDC = struct {
    const ENABLED: u8 = 1 << 7;
    const WINDOW_MAP: u8 = 1 << 6;
    const WINDOW_ENABLED: u8 = 1 << 5;
    const DATA_SRC: u8 = 1 << 4;
    const BG_MAP: u8 = 1 << 3;
    const OBJ_SIZE: u8 = 1 << 2;
    const OBJ_ENABLED: u8 = 1 << 1;
    const BG_WIN_ENABLED: u8 = 1 << 0;
};

const Stat = struct {
    const LYC_INTERRUPT: u8 = 1 << 6;
    const OAM_INTERRUPT: u8 = 1 << 5;
    const VBLANK_INTERRUPT: u8 = 1 << 4;
    const HBLANK_INTERRUPT: u8 = 1 << 3;
    const LYC_EQUAL: u8 = 1 << 2;
    const MODE_BITS: u8 = 1 << 1 | 1 << 0;

    const HBLANK: u8 = 0x00;
    const VBLANK: u8 = 0x01;
    const OAM: u8 = 0x02;
    const DRAWING: u8 = 0x03;
};

pub const GPU = struct {
    cpu: *CPU,
    name: []const u8,
    headless: bool,
    debug: bool,
    cycle: u32,

    window: ?*c.SDL_Window,
    renderer: ?*c.SDL_Renderer,
    framebuffer: ?*c.SDL_Texture,
    software_buffer: ?*c.SDL_Surface,
    software_renderer: ?*c.SDL_Renderer,
    colors: [4]c.SDL_Color,
    bgp: [4]c.SDL_Color,
    obp0: [4]c.SDL_Color,
    obp1: [4]c.SDL_Color,

    pub fn init(cpu: *CPU, name: []const u8, headless: bool, debug: bool) !GPU {
        // Window
        var width: i32 = 160;
        var height: i32 = 144;
        if (debug) {
            std.debug.print("Debug has been passed, increasing SDL window size\n", .{});
            width = 160 + 256;
            height = 144;
        }

        var window: ?*c.SDL_Window = undefined;
        var renderer: ?*c.SDL_Renderer = undefined;
        var framebuffer: ?*c.SDL_Texture = undefined;

        if (!headless) {
            if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) != 0) {
                return error.SDLInitializationFailed;
            }

            window = c.SDL_CreateWindow("ZenBoy", width, height, c.SDL_WINDOW_HIDDEN | c.SDL_WINDOW_VULKAN) orelse @panic("Failed to create SDL window");

            _ = c.SDL_ShowWindow(window);

            renderer = c.SDL_CreateRenderer(window, null, c.SDL_RENDERER_ACCELERATED) orelse {
                c.SDL_DestroyWindow(window);
                c.SDL_Quit();
                @panic("Failed to create SDL Renderer");
            };

            framebuffer = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ABGR8888, c.SDL_TEXTUREACCESS_STREAMING, @intCast(width), @intCast(height)) orelse {
                c.SDL_DestroyRenderer(renderer);
                c.SDL_DestroyWindow(window);
                c.SDL_Quit();
                @panic("Failed to create SDL frame buffer");
            };
        }

        var software_buffer: ?*c.SDL_Surface = undefined;
        var software_renderer: ?*c.SDL_Renderer = undefined;

        software_buffer = c.SDL_CreateSurface(width, height, c.SDL_PIXELFORMAT_ABGR8888);
        software_renderer = c.SDL_CreateSoftwareRenderer(software_buffer);

        // Colors
        const colors: [4]c.SDL_Color = .{
            c.SDL_Color{ .r = 0x9B, .g = 0xBC, .b = 0x0F, .a = 0xFF },
            c.SDL_Color{ .r = 0x8B, .g = 0xAC, .b = 0x0F, .a = 0xFF },
            c.SDL_Color{ .r = 0x30, .g = 0x62, .b = 0x30, .a = 0xFF },
            c.SDL_Color{ .r = 0x0F, .g = 0x38, .b = 0x0F, .a = 0xFF },
        };

        // if (!headless) {
        //     if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        //         c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        //         return error.SDLInitializationFailed;
        //     }

        //     const screen = c.SDL_CreateWindow("ZenBoy", width, height, c.SDL_WINDOW_OPENGL) orelse {
        //         c.SDL_Quit();
        //         return error.SDLWindowCreationFailed;
        //     };
        //     _ = screen; // autofix
        // }

        if (debug) {
            std.debug.print("debug-gpa has been set \n", .{});
        }

        return GPU{
            .cpu = cpu,
            .name = name,
            .headless = headless,
            .debug = debug,
            .cycle = 0,
            .window = window,
            .renderer = renderer,
            .framebuffer = framebuffer,
            .software_buffer = software_buffer,
            .software_renderer = software_renderer,
            .colors = colors,
            .bgp = colors,
            .obp0 = colors,
            .obp1 = colors,
        };
    }

    pub fn tick(self: *GPU) !void {
        self.cycle += 1;

        // CPU STOP stops all LCD activity until a button is pressed
        if (self.cpu.stop) {
            return;
        }

        // Check if LCD enabled at all
        const lcdc = self.cpu.ram.get(Constants.Mem.LCDC);
        if ((lcdc & LCDC.ENABLED) == 0) {
            // When LCD is re-enabled, LY is 0
            // Does it become 0 as soon as disabled??
            self.cpu.ram.set(Constants.Mem.LY, 0);
            if (!self.debug) {
                return;
            }
        }

        const lx: u8 = @as(u8, @intCast(self.cycle % 114));
        const ly: u8 = @as(u8, @intCast((self.cycle / 114) % 154));
        self.cpu.ram.set(Constants.Mem.LY, ly);

        var stat = self.cpu.ram.get(Constants.Mem.STAT);
        stat &= ~Stat.LYC_EQUAL;
        stat &= ~Stat.MODE_BITS;

        // LYC compare & interrupt
        if (ly == self.cpu.ram.get(Constants.Mem.LYC)) {
            stat |= Stat.LYC_EQUAL;
            if (stat & Stat.LYC_INTERRUPT != 0) {
                self.cpu.interrupt(Constants.Interrupt.STAT);
            }
        }

        // Set mode
        if (lx == 0 and ly < 144) {
            stat |= Stat.OAM;
            if (stat & Stat.OAM_INTERRUPT != 0) {
                self.cpu.interrupt(Constants.Interrupt.STAT);
            }
        } else if (lx == 20 and ly < 144) {
            stat |= Stat.DRAWING;
            if (ly == 0) {
                // TODO: how often should we update palettes?
                // Should every pixel reference them directly?
                self.update_palettes();
                _ = c.SDL_SetRenderDrawColor(self.renderer, self.bgp[0].r, self.bgp[0].g, self.bgp[0].b, self.bgp[0].a);
                _ = c.SDL_RenderClear(self.renderer);
            }
            try self.draw_line(ly);
            if (ly == 143) {
                if (self.debug) {
                    try self.draw_debug();
                }
                if (self.renderer) |hw_renderer| {
                    _ = hw_renderer; // autofix
                    if (self.framebuffer) |hw_buffer| {
                        var pixels: ?*anyopaque = null;
                        var pitch: i32 = 0;

                        if (c.SDL_LockTexture(self.framebuffer, null, &pixels, &pitch) != 0) {
                            c.SDL_Log("Failed to lock texture: %s\n", c.SDL_GetError());
                            return;
                        }

                        _ = c.SDL_UpdateTexture(hw_buffer, null, pixels, pitch);

                        //hw_renderer.*.copy(hw_buffer, null, null);

                        _ = c.SDL_UnlockTexture(self.framebuffer);

                        _ = c.SDL_RenderClear(self.renderer);
                        _ = c.SDL_RenderTexture(self.renderer, self.framebuffer, null, null);
                        _ = c.SDL_RenderPresent(self.renderer);
                    }
                }
                // if (self.renderer) |hw_renderer| {
                //     if (self.framebuffer) |hw_buffer| {
                //         if (self.framebuffer.?.*.pixels) |pixels| {
                //             // update() takes []const u8 but pixels are *anyopaque...
                //             // try hw_buffer.update(pixels, @intCast(usize, self.buffer.ptr.*.pitch), null);
                //             if (c.SDL_UpdateTexture(
                //                 hw_buffer.ptr,
                //                 null,
                //                 pixels,
                //                 @as(c_int, @intCast(self.buffer.ptr.*.pitch)),
                //             ) != 0) return c.SDL_GetError();
                //         }
                //         try hw_renderer.copy(hw_buffer, null, null);
                //         hw_renderer.present();
                //     }
                // }
            }
        } //else if (lx == 63 and ly < 144) {
        //     stat |= Stat.HBLANK;
        //     if (stat & Stat.HBLANK_INTERRUPT != 0) {
        //         self.cpu.interrupt(Constants.Interrupt.STAT);
        //     }
        // } else if (lx == 0 and ly == 144) {
        //     stat |= Stat.VBLANK;
        //     if (stat & Stat.VBLANK_INTERRUPT != 0) {
        //         self.cpu.interrupt(Constants.Interrupt.STAT);
        //     }
        //     self.cpu.interrupt(Constants.Interrupt.VBLANK);
        // }

        self.cpu.ram.set(Constants.Mem.STAT, stat);
    }

    fn update_palettes(self: *GPU) void {
        const raw_bgp = self.cpu.ram.get(Constants.Mem.BGP);
        self.bgp[0] = self.colors[(raw_bgp >> 0) & 0x3];
        self.bgp[1] = self.colors[(raw_bgp >> 2) & 0x3];
        self.bgp[2] = self.colors[(raw_bgp >> 4) & 0x3];
        self.bgp[3] = self.colors[(raw_bgp >> 6) & 0x3];

        const raw_obp0 = self.cpu.ram.get(Constants.Mem.OBP0);
        self.obp0[0] = self.colors[(raw_obp0 >> 0) & 0x3];
        self.obp0[1] = self.colors[(raw_obp0 >> 2) & 0x3];
        self.obp0[2] = self.colors[(raw_obp0 >> 4) & 0x3];
        self.obp0[3] = self.colors[(raw_obp0 >> 6) & 0x3];

        const raw_obp1 = self.cpu.ram.get(Constants.Mem.OBP1);
        self.obp1[0] = self.colors[(raw_obp1 >> 0) & 0x3];
        self.obp1[1] = self.colors[(raw_obp1 >> 2) & 0x3];
        self.obp1[2] = self.colors[(raw_obp1 >> 4) & 0x3];
        self.obp1[3] = self.colors[(raw_obp1 >> 6) & 0x3];
    }

    fn draw_debug(self: *GPU) !void {
        const lcdc = self.cpu.ram.get(Constants.Mem.LCDC);

        // Tile data - FIXME
        const tile_display_width: u8 = 32;
        var tile_id: u15 = 0;
        while (tile_id < 384) {
            var xy: c.SDL_Point = undefined;
            xy.x = 160 + (tile_id % tile_display_width) * 8;
            xy.y = (tile_id / tile_display_width) * 8;
            // var xy = SDL_Point{
            //     .x = 160 + (tile_id % tile_display_width) * 8,
            //     .y = (tile_id / tile_display_width) * 8,
            // };
            try self.paint_tile(@as(i16, @intCast(tile_id)), &xy, self.bgp, false, false);
            tile_id += 1;
        }

        // Background scroll border
        if (lcdc & LCDC.BG_WIN_ENABLED != 0) {
            const rect = c.SDL_FRect{ .x = 0, .y = 0, .w = 160, .h = 144 };
            //var rect = SDL.Rectangle{ .x = 0, .y = 0, .width = 160, .height = 144 };

            _ = c.SDL_SetRenderDrawColor(self.renderer, 255, 0, 0, 255);
            _ = c.SDL_RenderRect(self.renderer, &rect);

            // try self.renderer.setColorRGB(255, 0, 0);
            // try self.renderer.drawRect(rect);
        }

        // Window tiles
        if (lcdc & LCDC.WINDOW_ENABLED != 0) {
            const wnd_y = self.cpu.ram.get(Constants.Mem.WY);
            const wnd_x = self.cpu.ram.get(Constants.Mem.WX);
            const rect = c.SDL_FRect{ .x = @floatFromInt(wnd_x), .y = @floatFromInt(wnd_y), .w = 160, .h = 144 };
            //var rect = SDL.Rectangle{ .x = wnd_x - 7, .y = wnd_y, .width = 160, .height = 144 };

            _ = c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 255, 255);
            _ = c.SDL_RenderRect(self.renderer, &rect);

            // try self.renderer.setColorRGB(0, 0, 255);
            // try self.renderer.drawRect(rect);
        }
    }

    fn draw_line(self: *GPU, ly: u16) !void {
        const lcdc = self.cpu.ram.get(Constants.Mem.LCDC);

        // Background tiles
        if (lcdc & LCDC.BG_WIN_ENABLED != 0) {
            const scroll_y = self.cpu.ram.get(Constants.Mem.SCY);
            const scroll_x = self.cpu.ram.get(Constants.Mem.SCX);
            const tile_offset = !(lcdc & LCDC.DATA_SRC != 0);
            const tile_map = if (lcdc & LCDC.BG_MAP != 0) Constants.Mem.Map1 else Constants.Mem.Map0;

            if (self.debug) {
                var xy: c.SDL_Point = undefined;
                xy.x = 256 - @as(i16, scroll_x);
                xy.y = ly;
                //var xy = SDL.Point{ .x = 256 - @as(i16, @intCast(scroll_x)), .y = @as(c_int, @intCast(ly)) };
                _ = c.SDL_SetRenderDrawColor(self.renderer, 255, 0, 0, 255);
                _ = c.SDL_RenderPoint(self.renderer, @as(f32, @floatFromInt(xy.x)), @as(f32, @floatFromInt(xy.y)));
            }

            const y_in_bgmap = (ly + scroll_y) % 256;
            const tile_y = y_in_bgmap / 8;
            const tile_sub_y: u3 = @as(u3, @intCast(y_in_bgmap % 8));

            var lx: u16 = 0;
            while (lx <= 160) {
                const x_in_bgmap = (lx + scroll_x) % 256;
                const tile_x = x_in_bgmap / 8;
                const tile_sub_x = x_in_bgmap % 8;

                var tile_id: i16 = self.cpu.ram.get(tile_map + tile_y * 32 + tile_x);
                if (tile_offset and tile_id < 0x80) {
                    tile_id += 0x100;
                }
                var xy: c.SDL_Point = undefined;
                xy.x = @as(i32, @intCast(lx)) - @as(i32, @intCast(tile_sub_x));
                xy.y = @as(i32, @intCast(ly)) - @as(i32, @intCast(tile_sub_y));
                // var xy = SDL.Point{
                //     .x = @as(i32, @intCast(lx)) - @as(i32, @intCast(tile_sub_x)),
                //     .y = @as(i32, @intCast(ly)) - @as(i32, @intCast(tile_sub_y)),
                // };
                try self.paint_tile_line(tile_id, &xy, self.bgp, false, false, tile_sub_y);

                lx += 8;
            }
        }
    }

    fn paint_tile(self: *GPU, tile_id: i16, offset: *c.SDL_Point, palette: [4]c.SDL_Color, flip_x: bool, flip_y: bool) !void {
        var y: u3 = 0;
        while (true) {
            try self.paint_tile_line(tile_id, offset, palette, flip_x, flip_y, y);
            if (y == 7) break;
            y += 1;
        }

        if (self.debug) {
            const rect: c.SDL_FRect = c.SDL_FRect{ .x = @floatFromInt(offset.x), .y = @floatFromInt(offset.y), .w = 8, .h = 8 };

            const color = gen_hue(@as(u8, @intCast(tile_id & 0xFF)));

            _ = c.SDL_SetRenderDrawColor(self.renderer, color.r, color.g, color.b, color.a);
            _ = c.SDL_RenderRect(self.renderer, &rect);

            // try self.renderer.setColor(gen_hue(@as(u8, @intCast(tile_id & 0xFF))));
            // try self.renderer.drawRect(rect);
        }
    }

    fn paint_tile_line(
        self: *GPU,
        tile_id: i16,
        offset: *c.SDL_Point,
        palette: [4]c.SDL_Color,
        flip_x: bool,
        flip_y: bool,
        y: u3,
    ) !void {
        const addr: u16 = @as(u16, @intCast(@as(i32, @intCast(Constants.Mem.TileData)) + tile_id * 16 + @as(u8, @intCast(y)) * 2));
        const low_byte = self.cpu.ram.get(addr);
        const high_byte = self.cpu.ram.get(addr + 1);
        var x: u3 = 0;
        while (true) {
            const low_bit = (low_byte >> (7 - x)) & 0x01;
            const high_bit = (high_byte >> (7 - x)) & 0x01;
            const px = (high_bit << 1) | low_bit;
            // pallette #0 = transparent, so don't draw anything
            if (px > 0) {
                const xy = c.SDL_Point{
                    .x = offset.x + (if (flip_x) 7 - x else x),
                    .y = offset.y + (if (flip_y) 7 - y else y),
                };

                _ = c.SDL_SetRenderDrawColor(self.renderer, palette[px].r, palette[px].g, palette[px].b, palette[px].a);
                _ = c.SDL_RenderPoint(self.renderer, @as(f32, @floatFromInt(xy.x)), @as(f32, @floatFromInt(xy.y)));

                // try self.renderer.setColor(palette[px]);
                // try self.renderer.drawPoint(xy.x, xy.y);
            }
            if (x == 7) break;
            x += 1;
        }
    }

    pub fn deinit(self: *GPU) void {
        if (self.debug) {
            std.debug.print("GPU deinit has been called, closing sdl window if not headless\n", .{});
        }

        if (!self.headless) {
            c.SDL_DestroyTexture(self.framebuffer);
            c.SDL_DestroyRenderer(self.renderer);
            c.SDL_DestroyWindow(self.window);
            c.SDL_Quit();
        }
    }
};

pub const Sprite = packed struct {
    y: u8,
    x: u8,
    tile_id: u8,
    flags: Flags,

    pub const Flags = packed struct {
        _empty: u4,
        palette: bool,
        x_flip: bool,
        y_flip: bool,
        behind: bool,
    };

    fn is_live(self: *Sprite) bool {
        return self.x > 0 and self.x < 168 and self.y > 0 and self.y < 160;
    }
};

pub fn gen_hue(n: u8) c.SDL_Color {
    const region: u8 = n / 43;
    const remainder: u8 = (n - (region * 43)) * 6;

    const q: u8 = 255 - remainder;
    const t: u8 = remainder;

    return switch (region) {
        0 => c.SDL_Color{ .r = 255, .g = t, .b = 0, .a = 0xFF },
        1 => c.SDL_Color{ .r = q, .g = 255, .b = 0, .a = 0xFF },
        2 => c.SDL_Color{ .r = 0, .g = 255, .b = t, .a = 0xFF },
        3 => c.SDL_Color{ .r = 0, .g = q, .b = 255, .a = 0xFF },
        4 => c.SDL_Color{ .r = t, .g = 0, .b = 255, .a = 0xFF },
        else => c.SDL_Color{ .r = 255, .g = 0, .b = q, .a = 0xFF },
    };
}
