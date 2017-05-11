// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.drivers.bochs;

import arch.x86_64.ioports;
import l = metal.printer;
import pci = metal.pci;


enum u16 BGA_DISPI_IOPORT_INDEX          = 0x01CE;
enum u16 BGA_DISPI_IOPORT_DATA           = 0x01CF;

enum u8 BGA_DISPI_INDEX_ID               = 0x0;
enum u8 BGA_DISPI_INDEX_XRES             = 0x1;
enum u8 BGA_DISPI_INDEX_YRES             = 0x2;
enum u8 BGA_DISPI_INDEX_BPP              = 0x3;
enum u8 BGA_DISPI_INDEX_ENABLE           = 0x4;
enum u8 BGA_DISPI_INDEX_BANK             = 0x5;
enum u8 BGA_DISPI_INDEX_VIRT_WIDTH       = 0x6;
enum u8 BGA_DISPI_INDEX_VIRT_HEIGHT      = 0x7;
enum u8 BGA_DISPI_INDEX_X_OFFSET         = 0x8;
enum u8 BGA_DISPI_INDEX_Y_OFFSET         = 0x9;
enum u8 BGA_DISPI_INDEX_VIDEO_MEMORY_64K = 0xa;

enum u16 BGA_DISPI_ID0                   = 0xB0C0;
enum u16 BGA_DISPI_ID1                   = 0xB0C1;
enum u16 BGA_DISPI_ID2                   = 0xB0C2;
enum u16 BGA_DISPI_ID3                   = 0xB0C3;
enum u16 BGA_DISPI_ID4                   = 0xB0C4;
enum u16 BGA_DISPI_ID5                   = 0xB0C5;

enum u8 BGA_DISPI_DISABLED               = 0x00;
enum u8 BGA_DISPI_ENABLED                = 0x01;
enum u8 BGA_DISPI_GETCAPS                = 0x02;
enum u8 BGA_DISPI_8BIT_DAC               = 0x20;
enum u8 BGA_DISPI_LFB_ENABLED            = 0x40;
enum u8 BGA_DISPI_NOCLEARMEM             = 0x80;


struct Bochs
{
	ptr: void*;
	w: u16;
	h: u16;
	pitch: u16;
	bpp: u16;

	loaded: bool;

	pci: .pci.Device*;
}

global dev: Bochs;

fn loadFromPCI(pciDev: pci.Device*)
{
	dev.pci = pciDev;
	bar1 := pci.readU32(pciDev.bus, pciDev.slot, pciDev.func, 0x10);

	dev.ptr = cast(void*)(bar1 & 0xFFFFFFF0_u32);
	readLayout(&dev);
	if (dev.pitch == 0 || dev.bpp != 32) {
		setLayout(&dev, 800, 600, 32);
	}

	dev.loaded = true;
}

fn readLayout(dev: Bochs*)
{
	dev.w = read(BGA_DISPI_INDEX_XRES);
	dev.h = read(BGA_DISPI_INDEX_YRES);
	dev.bpp = read(BGA_DISPI_INDEX_BPP);
	dev.pitch = cast(u16)(read(BGA_DISPI_INDEX_VIRT_WIDTH) * (dev.bpp / 8));
}

fn setLayout(dev: Bochs*, w: u16, h: u16, bpp: u16)
{
	dev.pitch = cast(u16)(w * (bpp / 8));
	dev.w = w;
	dev.h = h;
	dev.bpp = bpp;

	write(BGA_DISPI_INDEX_BPP,         bpp);
	write(BGA_DISPI_INDEX_XRES,        w);
	write(BGA_DISPI_INDEX_YRES,        h);
	write(BGA_DISPI_INDEX_BANK,        0);
	write(BGA_DISPI_INDEX_VIRT_WIDTH,  w);
	write(BGA_DISPI_INDEX_VIRT_HEIGHT, h);
	write(BGA_DISPI_INDEX_X_OFFSET,    0);
	write(BGA_DISPI_INDEX_Y_OFFSET,    0);
	write(BGA_DISPI_INDEX_ENABLE,
		cast(u16)(BGA_DISPI_ENABLED | BGA_DISPI_LFB_ENABLED));
}


/*
 *
 * Access functions.
 *
 */

fn read(reg: u16) u16
{
	outw(BGA_DISPI_IOPORT_INDEX, reg);
	return inw(BGA_DISPI_IOPORT_DATA);
}

fn write(reg: u16, val: u16)
{
	outw(BGA_DISPI_IOPORT_INDEX, reg);
	outw(BGA_DISPI_IOPORT_DATA, val);
}
