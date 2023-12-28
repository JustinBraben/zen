pub const Mem = struct {
    pub const VBlankHandler: u16 = 0x40;
    pub const LcdHandler: u16 = 0x48;
    pub const TimerHandler: u16 = 0x50;
    pub const SerialHandler: u16 = 0x58;
    pub const JoypadHandler: u16 = 0x60;

    pub const TileData: u16 = 0x8000;
    pub const Map0: u16 = 0x9800;
    pub const Map1: u16 = 0x9C00;
    pub const OamBase: u16 = 0x8000;
};
