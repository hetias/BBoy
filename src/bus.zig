const std = @import("std");

//this is the memory map of the Gameboy
//https://gbdev.io/pandocs/Memory_Map.html
const address_space = struct {
    rom: []u8 = undefined,
    romx: []u8 = undefined,
    vram: []u8 = undefined,
    eram: []u8 = undefined,
    wram0: []u8 = undefined,
    wramx: []u8 = undefined,
    echo: []u8 = undefined,
    OAM: []u8 = undefined,
    empty: []u8 = undefined,
    IO: []u8 = undefined,
    hram: []u8 = undefined,
    IE: []u8 = undefined,

    joysflags: *u8 = undefined,
    intsflags: *u8 = undefined,
};

pub const GBbus = struct {
    bios: []u8 = undefined, //TODO::This probably shouldn't be inside the "bus" but it being a place in memory makes me put it on here...
    bios_disabled: ?*u8 = null,

    memory: []u8 = undefined,
    memory_map: address_space = undefined,

    pub fn init(memory: []u8, bios: []u8) GBbus {
        memory[0xFF50] = 0x0;
        return GBbus{
            .memory = memory,
            .bios = bios,
            .bios_disabled = &memory[0xFF50],
            .memory_map = address_space{
                .rom = memory[0x00..0x3FFF],
                .romx = memory[0x4000..0x7FFF],
                .vram = memory[0x8000..0x9FFF],
                .eram = memory[0xA000..0xBFFF],
                .wram0 = memory[0xC000..0xCFFF],
                .wramx = memory[0xD000..0xDFFF],
                .echo = memory[0xC000..0xDDFF],
                .OAM = memory[0xFE00..0xFE9F],
                .empty = memory[0xFE00..0xFE9F],
                .IO = memory[0xFF00..0xFF7F],
                .hram = memory[0xFF80..0xFFFE],
                .IE = memory[0xFFFF..],
            },
        };
    }

    pub fn write(self: GBbus, addr: u16, data: u8) void {
        //writing to bios? no!
        if (self.bios_disabled.?.* == 0 and (addr >= 0x00 and addr <= 0xFF)) {
            return;
        }

        //writing to actual memory? yes!
        self.memory[addr] = data;
    }

    //TODO::Right now not taking much care about the write calls..
    pub fn writeWord(self: GBbus, addr: u16, data: u16) void {
        if (self.bios_disabled.?.* == 0 and (addr >= 0x00 and addr <= 0xFF)) {
            return;
        }

        self.memory[addr] = @as(u8, @truncate(data));
        self.memory[addr + 1] = @as(u8, @truncate(data >> 4));
    }

    pub fn read(self: GBbus, addr: u16) u8 {
        if (self.bios_disabled.?.* == 0 and (addr >= 0x00 and addr <= 0xFF)) {
            //std.debug.print("Reading from bios\n", .{});
            return self.bios[addr];
        }

        //std.debug.print("Reading from ram\n", .{});
        return self.memory[addr];
    }

    pub fn readWord(self: GBbus, addr: u16) u16 {
        if (self.bios_disabled.?.* == 0 and addr >= 0x00 and addr <= 0xFF) {
            return (@as(u16, self.bios[addr]) | @as(u16, self.bios[addr + 1]) << 8);
        }

        return (@as(u16, self.memory[addr]) | @as(u16, self.memory[addr + 1]) << 8);
    }

    pub fn show_stack(self: GBbus, top: u16) void {
        for (self.memory[top..0xFFFE]) |byte| {
            std.debug.print("{x} ", .{byte});
        }
        std.debug.print("\n", .{});
    }
};
