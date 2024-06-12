pub const GBbus = struct {
    memory: []u8,

    pub fn init(memory: []u8) GBbus {
        return .{
            .memory = memory,
        };
    }

    pub fn write(self: GBbus, addr: u16, data: u8) void {
        self.memory[addr] = data;
    }

    pub fn writeWord(self: GBbus, addr: u16, data: u16) void {
        self.memory[addr] = @as(u8, @truncate(data));
        self.memory[addr + 1] = @as(u8, @truncate(data >> 4));
    }

    pub fn read(self: GBbus, addr: u16) u8 {
        return self.memory[addr];
    }

    pub fn readWord(self: GBbus, addr: u16) u16 {
        return (@as(u16, self.memory[addr]) | @as(u16, self.memory[addr + 1]) << 8);
    }
};
