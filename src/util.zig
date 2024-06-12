pub const Byte = struct {
    pub fn make_word(high: u8, low: u8) u16 {
        return (@as(u16, low) | @as(u16, high) << 8);
    }
    pub fn get_high(byte: u16) u8 {
        return (@truncate(byte >> 8));
    }

    pub fn get_low(byte: u16) u8 {
        return (@truncate(byte));
    }

    pub fn check_bit(byte: u8, bit: u3) bool {
        return ((byte >> bit) & 1) > 0;
    }
};
