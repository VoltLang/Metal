// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.drivers.bochs;

import arch.x86.ioports;
import l = metal.printer;
import pci = metal.pci;


enum ushort BGA_DISPI_IOPORT_INDEX          = 0x01CE;
enum ushort BGA_DISPI_IOPORT_DATA           = 0x01CF;

enum ubyte BGA_DISPI_INDEX_ID               = 0x0;
enum ubyte BGA_DISPI_INDEX_XRES             = 0x1;
enum ubyte BGA_DISPI_INDEX_YRES             = 0x2;
enum ubyte BGA_DISPI_INDEX_BPP              = 0x3;
enum ubyte BGA_DISPI_INDEX_ENABLE           = 0x4;
enum ubyte BGA_DISPI_INDEX_BANK             = 0x5;
enum ubyte BGA_DISPI_INDEX_VIRT_WIDTH       = 0x6;
enum ubyte BGA_DISPI_INDEX_VIRT_HEIGHT      = 0x7;
enum ubyte BGA_DISPI_INDEX_X_OFFSET         = 0x8;
enum ubyte BGA_DISPI_INDEX_Y_OFFSET         = 0x9;
enum ubyte BGA_DISPI_INDEX_VIDEO_MEMORY_64K = 0xa;

enum ushort BGA_DISPI_ID0                   = 0xB0C0;
enum ushort BGA_DISPI_ID1                   = 0xB0C1;
enum ushort BGA_DISPI_ID2                   = 0xB0C2;
enum ushort BGA_DISPI_ID3                   = 0xB0C3;
enum ushort BGA_DISPI_ID4                   = 0xB0C4;
enum ushort BGA_DISPI_ID5                   = 0xB0C5;

enum ubyte BGA_DISPI_DISABLED               = 0x00;
enum ubyte BGA_DISPI_ENABLED                = 0x01;
enum ubyte BGA_DISPI_GETCAPS                = 0x02;
enum ubyte BGA_DISPI_8BIT_DAC               = 0x20;
enum ubyte BGA_DISPI_LFB_ENABLED            = 0x40;
enum ubyte BGA_DISPI_NOCLEARMEM             = 0x80;


struct Bochs
{
	void* ptr;
	ushort w;
	ushort h;
	ushort pitch;
	ushort bpp;

	bool loaded;

	.pci.Device* pci;
}

global Bochs dev;

void loadFromPCI(pci.Device* pciDev)
{
	dev.pci = pciDev;
	auto bar1 = pci.readUint(pciDev.bus, pciDev.slot, pciDev.func, 0x10);

	dev.ptr = cast(void*)(bar1 & 0xFFFFFFF0u);
	readLayout(&dev);
	if (dev.pitch == 0 || dev.bpp != 32) {
		setLayout(&dev, 800, 600, 32);
	}

	dev.loaded = true;
}

void readLayout(Bochs* dev)
{
	dev.w = read(BGA_DISPI_INDEX_XRES);
	dev.h = read(BGA_DISPI_INDEX_YRES);
	dev.bpp = read(BGA_DISPI_INDEX_BPP);
	dev.pitch = cast(ushort)(read(BGA_DISPI_INDEX_VIRT_WIDTH) * (dev.bpp / 8));
}

void setLayout(Bochs* dev, ushort w, ushort h, ushort bpp)
{
	dev.pitch = cast(ushort)(w * (bpp / 8));
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
		cast(ushort)(BGA_DISPI_ENABLED | BGA_DISPI_LFB_ENABLED));
}


/*
 *
 * Access functions.
 *
 */

ushort read(ushort reg)
{
	outw(BGA_DISPI_IOPORT_INDEX, reg);
	return inw(BGA_DISPI_IOPORT_DATA);
}

void write(ushort reg, ushort val)
{
	outw(BGA_DISPI_IOPORT_INDEX, reg);
	outw(BGA_DISPI_IOPORT_DATA, val);
}
