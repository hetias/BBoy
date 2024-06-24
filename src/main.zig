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
    var bios_rom: [0x100]u8 = undefined;
    const rom_file = try std.fs.cwd().openFile("boot.gb", .{});
    _ = try rom_file.readAll(&bios_rom);
    rom_file.close();

    //game rom
    const game_file = try std.fs.cwd().openFile("zelda.gb", .{});
    try game_file.seekTo(0x100);

    //write rom to ram
    _ = try game_file.readAll(ram[0x100..]);
    game_file.close();

    const gbbus = GBbus.init(ram, bios_rom[0..]);
    var gbcpu = GBcpu.init(&gbbus);

    const game_title = ram[0x134..0x143];

    //FIX ME:: This is a work around while we don't have a PPU
    //this is the scan line register. Puttin 90 means "we are in a
    //new frame"
    ram[0xFF44] = 0x90;

    //main loop
    while (true) {
        std.debug.print("PC: {x}\n", .{gbcpu.PC});
        try gbcpu.execute();
        //try gbcpu.check_interrupts();
        //gbcpu.show_state();

        if (gbcpu.PC > 0x00FE) {
            std.debug.print("Boot rom end\n", .{});
            break;
        }
    }
}
