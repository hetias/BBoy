const std = @import("std");
const GBcpu = @import("cpu.zig").GBcpu;
const GBbus = @import("bus.zig").GBbus;

pub fn main() !void {
    //stdout
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

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

    const gbbus = GBbus.init(ram);
    var gbcpu = GBcpu.init(&gbbus);

    //main loop
    while (true) {
        std.log.info("PC: {x} HL: {x}", .{ gbcpu.getPC(), gbcpu.getHL() });
        try gbcpu.execute();
    }

    try stdout.print("damn\n", .{});
    //stdout.flush();
}
