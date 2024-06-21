const std = @import("std");
const Util = @import("util.zig");
const GBcpu = @import("cpu.zig").GBcpu;
const GBbus = @import("bus.zig").GBbus;

pub fn main() !void {
    //stdout
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();

    //allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    //bboy
    const ram = try allocator.alloc(u8, 0xFFFF);
    defer allocator.free(ram);

    //boot rom
    const rom_file = try std.fs.cwd().openFile("boot.gb", .{});
    _ = try rom_file.readAll(ram);
    rom_file.close();

    //game rom
    const game_file = try std.fs.cwd().openFile("tetris.gb", .{});
    try game_file.seekTo(0x100);

    //write rom to ram
    _ = try game_file.readAll(ram[0x100..]);
    game_file.close();

    const gbbus = GBbus.init(ram);
    var gbcpu = GBcpu.init(&gbbus);

    const game_title = ram[0x134..0x143];
    const nintendo_logo_cart = ram[0x104..0x134];
    const nintendo_logo_rom = ram[0xA8..0xD8];
    std.debug.print("title: {s}\n\n", .{game_title});
    std.debug.print("nintendo_logo_rom: {x}\n\n", .{nintendo_logo_rom});
    std.debug.print("nintendo_logo_cart: {x}\n\n", .{nintendo_logo_cart});

    //FIX ME:: This is a work around while we don't have a PPU
    //this is the scan line register. Puttin 90 means "we are in a
    //new frame"
    ram[0xFF44] = 0x90;

    //main loop
    while (true) {
        std.debug.print("PC: {x}\n", .{gbcpu.PC});
        try gbcpu.execute();

        if (gbcpu.PC > 0x00FE) {
            std.debug.print("Boot rom end\n", .{});
            break;
        }
    }
}
