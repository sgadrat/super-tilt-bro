; PPU registers
;  http://wiki.nesdev.com/w/index.php/PPU_registers

PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
OAMDATA = $2004
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
OAMDMA = $4014

; APU registers
;  http://wiki.nesdev.com/w/index.php/APU

APU_DMC_FLAGS = $2010
APU_FRAMECNT = $2017

; Controller ports

CONTROLLER_A = $4016
CONTROLLER_B = $4017
