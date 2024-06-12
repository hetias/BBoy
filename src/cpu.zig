const std = @import("std");
const GBbus = @import("bus.zig").GBbus;
const Util = @import("util.zig");

const CPUerror = error{
    UnknownOperation,
    IllegalOperation,
};

pub const GBcpu = struct {
    //registers
    A: u8,
    F: u8,
    B: u8,
    C: u8,
    D: u8,
    E: u8,
    H: u8,
    L: u8,
    SP: u16,
    PC: u16,

    //bus
    bus: *const GBbus = undefined,

    pub fn init(bus: *const GBbus) GBcpu {
        return GBcpu{
            .A = 0,
            .F = 0,
            .B = 0,
            .C = 0,
            .D = 0,
            .E = 0,
            .H = 0,
            .L = 0,
            .SP = 0,
            .PC = 0,
            .bus = bus,
        };
    }

    pub fn read(self: *GBcpu, addr: u16) u8 {
        return self.bus.read(addr);
    }

    pub fn readWord(self: GBcpu, addr: u16) u16 {
        return self.bus.readWord(addr);
    }

    pub fn write(self: GBcpu, addr: u16, data: u8) void {
        self.bus.write(addr, data);
    }

    pub fn writeWord(self: GBcpu, addr: u16, data: u16) void {
        self.bus.writeWord(addr, data);
    }

    pub fn execute(self: *GBcpu) CPUerror!void {
        const opcode: u16 = self.read(self.PC);

        switch (opcode) {
            0x00 => {
                self.nop();
            },
            0x05 => {
                self.dec_reg8(&self.B);
            },
            0x06 => {
                self.ld_imm8(&self.B);
            },
            0x11 => {
                self.ld_imm16(&self.D, &self.E);
            },
            0x17 => {
                //RLA
                self.rl(&self.A);
            },
            0x1A => {
                self.ld_reg_mem(self.getDE(), &self.A);
            },
            0x20 => {
                //jp nz, s8
                self.jp_nz();
            },
            0x21 => {
                //ld hl, d16
                self.ld_imm16(&self.H, &self.L);
            },
            0x22 => {
                self.store_hl_inc(self.A);
            },
            0x23 => {
                self.inc_reg16(&self.H, &self.L);
            },
            0x31 => {
                //ld sp, d16
                self.ld_sp_imm();
            },
            0x32 => {
                //ld (hl-), a
                self.store_hl_dec(self.A);
            },
            0x4F => {
                self.mv_reg(&self.C, &self.A);
            },
            0x77 => {
                self.st_reg(self.getHL(), &self.A);
            },
            0xAF => {
                //xor a
                self.xor(&self.A);
            },
            0x0C => {
                self.inc_reg8(&self.C);
            },
            0x0E => {
                self.ld_imm8(&self.C);
            },
            0x3E => {
                self.ld_imm8(&self.A);
            },
            0xE0 => {
                self.st_reg_imm(&self.A);
            },
            0xE2 => {
                self.st_reg_c(&self.A);
            },
            0xC1 => {
                self.pop(&self.B, &self.C);
            },
            0xC5 => {
                self.push(&self.B, &self.C);
            },
            0xCB => {
                self.PC += 1;
                const cb_op = self.read(self.PC);
                switch (cb_op) {
                    0x11 => {
                        self.rl(&self.C);
                    },
                    0x7C => {
                        self.check_bit(self.H, 7);
                    },
                    else => {
                        std.debug.print("unknown CBOP: {x}\n", .{cb_op});
                    },
                }
            },
            0xCD => {
                self.call();
            },
            else => {
                std.debug.print("unknown op: {x}\n", .{opcode});
                return CPUerror.UnknownOperation;
            },
        }
    }

    pub fn getAF(self: *GBcpu) u16 {
        return @as(u16, self.F) | (@as(u16, self.A) << 8);
    }

    pub fn getBC(self: *GBcpu) u16 {
        return @as(u16, self.C) | (@as(u16, self.B) << 8);
    }

    pub fn getDE(self: *GBcpu) u16 {
        return @as(u16, self.D) | (@as(u16, self.E) << 8);
    }

    pub fn getHL(self: *GBcpu) u16 {
        return @as(u16, self.L) | (@as(u16, self.H) << 8);
    }

    pub fn getSP(self: *GBcpu) u16 {
        return self.SP;
    }

    pub fn getPC(self: *GBcpu) u16 {
        return self.PC;
    }

    //internal modifyers
    fn reset_zero(self: *GBcpu) void {
        self.F ^= 0x80;
    }

    fn set_zero(self: *GBcpu) void {
        self.F |= 0x80;
    }

    fn reset_sub(self: *GBcpu) void {
        self.F ^= 0x40;
    }

    fn set_sub(self: *GBcpu) void {
        self.F |= 0x40;
    }

    fn reset_hcarry(self: *GBcpu) void {
        self.F ^= 0x20;
    }

    fn set_hcarry(self: *GBcpu) void {
        self.F |= 0x20;
    }

    fn reset_carry(self: *GBcpu) void {
        self.F &= 0x10;
    }

    fn set_carry(self: *GBcpu) void {
        self.F ^= 0x10;
    }

    fn BIT_CHECK(self: *GBcpu, reg: u8, bit: u3) bool {
        _ = self;
        return ((reg >> bit) & 1) > 0;
    }

    //actual operations
    fn nop(self: *GBcpu) void {
        self.PC += 1;
    }

    fn inc_reg8(self: *GBcpu, reg: *u8) void {
        self.PC += 1;
        reg.* += 1;
    }

    fn dec_reg8(self: *GBcpu, reg: *u8) void {
        self.PC += 1;
        reg.* += 1;
    }

    fn inc_reg16(self: *GBcpu, high: *u8, low: *u8) void {
        self.PC += 1;

        const HL = Util.Byte.make_word(high.*, low.*) + 1;

        self.H = Util.Byte.get_high(HL);
        self.L = Util.Byte.get_low(HL);
    }

    fn dec_reg16(self: *GBcpu, reg: *u16) void {
        self.PC += 1;
        reg.* += 1;
    }

    fn pop(self: *GBcpu, high: *u8, low: *u8) void {
        self.PC += 1;

        low.* = self.read(self.SP);
        self.SP += 1;

        high.* = self.read(self.SP);
        self.SP += 1;
    }

    fn push(self: *GBcpu, high: *u8, low: *u8) void {
        self.PC += 1;

        self.SP -= 1;
        self.write(self.SP, high.*);

        self.SP -= 1;
        self.write(self.SP, low.*);
    }

    //ld (hl-), r
    fn store_hl_dec(self: *GBcpu, reg: u8) void {
        self.PC += 1;
        self.write(self.getHL(), reg);
        const HL = (self.getHL()) - 1;
        self.H = @as(u8, @truncate(HL >> 8));
        self.L = @as(u8, @truncate(HL));
    }

    //ld (hl+), r
    fn store_hl_inc(self: *GBcpu, reg: u8) void {
        self.PC += 1;
        self.write(self.getHL(), reg);

        const HL = self.getHL();
        self.H = @as(u8, @truncate(HL >> 8));
        self.L = @as(u8, @truncate(HL));
    }

    fn mv_reg(self: *GBcpu, reg_a: *u8, reg_b: *u8) void {
        self.PC += 1;
        reg_a.* = reg_b.*;
    }

    fn st_reg(self: *GBcpu, add: u16, reg: *u8) void {
        self.PC += 1;
        self.write(add, reg.*);
    }

    fn st_reg_imm(self: *GBcpu, reg: *u8) void {
        self.PC += 1;
        self.write(0xFF00 + @as(u16, @intCast(self.read(self.PC))), reg.*);
        self.PC += 1;
    }

    fn ld_reg_mem(self: *GBcpu, add: u16, reg: *u8) void {
        self.PC += 1;
        reg.* = self.read(add);
    }

    fn ld_imm8(self: *GBcpu, reg: *u8) void {
        self.PC += 1;
        reg.* = self.read(self.PC);
        self.PC += 1;
    }

    fn st_reg_c(self: *GBcpu, reg: *u8) void {
        self.PC += 1;
        self.write(0xFF00 + @as(u16, @intCast(self.C)), reg.*);
    }

    //ld r16, d16...
    fn ld_imm16(self: *GBcpu, high: *u8, low: *u8) void {
        self.PC += 1;
        low.* = self.read(self.PC);
        high.* = self.read(self.PC + 1);
        self.PC += 2;
    }

    //ld sp, d16
    fn ld_sp_imm(self: *GBcpu) void {
        self.PC += 1;
        self.SP = self.readWord(self.PC);
        self.PC += 2;
    }

    fn xor(self: *GBcpu, reg: *u8) void {
        reg.* ^= reg.*;
        self.PC += 1;
    }

    fn check_bit(self: *GBcpu, reg: u8, bit: u3) void {
        self.PC += 1;
        if (((reg >> bit) & 1) == 0) {
            self.set_zero();
        }
        self.reset_sub();
        self.set_hcarry();
    }

    fn rl(self: *GBcpu, reg: *u8) void {
        self.PC += 1;

        //update carry flag
        if (Util.Byte.check_bit(reg.*, 7)) {
            self.set_carry();
        } else {
            self.reset_carry();
        }

        //shift
        reg.* = @shlWithOverflow(reg.*, 1)[0];

        //update zero flag
        if (reg.* == 0) {
            self.set_zero();
        }
    }

    fn jp_nz(self: *GBcpu) void {
        self.PC += 1;
        if (!self.BIT_CHECK(self.F, 7)) {
            self.PC = @intCast(@as(i16, @intCast(self.PC)) +
                @as(i8, @bitCast(self.read(self.PC))));
        }
        self.PC += 1;
    }

    fn call(self: *GBcpu) void {
        self.PC += 1;
        self.write(self.SP, @as(u8, @truncate(self.PC >> 8)));
        self.SP -= 1;
        self.write(self.SP, @as(u8, @truncate(self.PC)));
        self.SP -= 1;

        self.PC = self.readWord(self.PC);
    }
};
