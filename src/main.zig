const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const clap = @import("clap");
const Args = @import("data_structures/Args.zig").Args;
//const GameBoy = @import("gb/GameBoy.zig").GameBoy;
const errors = @import("gb/Errors.zig");

const debug = std.debug;
const io = std.io;
const process = std.process;

pub fn main() !void {
    
}

// pub fn main() !void {
//     // Get allocator
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const allocator = gpa.allocator();
//     defer _ = gpa.deinit();

//     // Parse args into string array (error union needs 'try')
//     const args = try std.process.argsAlloc(allocator);
//     defer std.process.argsFree(allocator, args);

//     // Get and print them!
//     std.debug.print("There are {d} args:\n", .{args.len});

//     var list = std.ArrayList([]const u8).init(gpa.allocator());
//     defer list.deinit();

//     for(args) |arg| {
//         try list.append(arg);
//     }

//     for(list) |arg| {
//         std.debug.print("Arg: {s}\n", .{arg});
//     }
// }

// pub fn main() !void {
//     const stdout = std.io.getStdOut().writer();

//     const args = try std.process.argsAlloc(std.heap.page_allocator);
//     defer std.process.argsFree(std.heap.page_allocator, args);

//     if (args.len < 2) return error.ExpectedArgument;

//     const far = try std.fmt.parseFloat(f32, args[1]);
//     const cel = (far - 32) * (5.0 / 9.0);
//     try stdout.print("{d:.1}c\n", .{cel});

//     for(args) |arg| {
//         try stdout.print("Arg : {s}\n", .{arg});
//     } 
// }

// pub fn main() !void {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();

//     // First we specify what parameters our program can take.
//     // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
//     const params = comptime clap.parseParamsComptime(
//         \\-h, --help             Display this help and exit.
//         \\-n, --number <INT>     An option parameter, which takes a value.
//         \\-a, --answer <ANSWER>  An option parameter which takes an enum.
//         \\-s, --string <STR>...  An option parameter which can be specified multiple times.
//         \\<FILE>...
//         \\
//     );

//     // Declare our own parsers which are used to map the argument strings to other
//     // types.
//     const YesNo = enum { yes, no };
//     const parsers = comptime .{
//         .STR = clap.parsers.string,
//         .FILE = clap.parsers.string,
//         .INT = clap.parsers.int(usize, 10),
//         .ANSWER = clap.parsers.enumeration(YesNo),
//     };

//     var diag = clap.Diagnostic{};
//     var res = clap.parse(clap.Help, &params, parsers, .{
//         .diagnostic = &diag,
//         .allocator = gpa.allocator(),
//     }) catch |err| {
//         diag.report(io.getStdErr().writer(), err) catch {};
//         return err;
//     };
//     defer res.deinit();

//     if (res.args.help != 0)
//         debug.print("--help\n", .{});
//     if (res.args.number) |n|
//         debug.print("--number = {}\n", .{n});
//     if (res.args.answer) |a|
//         debug.print("--answer = {s}\n", .{@tagName(a)});
//     for (res.args.string) |s|
//         debug.print("--string = {s}\n", .{s});
//     for (res.positionals) |pos|
//         debug.print("{s}\n", .{pos});
// }

// pub fn main() anyerror!void {
//     // const args = try Args.parseArgs();
//     // _ = args;

//     var args: Args.Args = undefined;
//     args = try Args.parseArgs();

//     std.debug.print("\n", .{});
//     std.debug.print("args : {any}\n", .{args});

//     try Args.printArgs();

//     //std.debug.print("args : {any}\n", .{args});
//     // var gameBoy: GameBoy = undefined;
//     // try gameBoy.init(args);

//     // const res = try Args.getArgs();
//     // std.debug.print("args : {any}\n", .{res});
// }
