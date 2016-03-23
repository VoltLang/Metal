// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.hal;

import metal.drivers.serial;
import l = metal.printer;
import acpi = metal.acpi;
import e820 = metal.e820;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;
import gfx = metal.gfx;
import pci = metal.pci;


struct Hal
{
	acpi.RSDT* rsdt;
	acpi.XSDT* xsdt;

	uint multibootMagic;
	mb2.Info* multibootInfo;
}

global Hal hal;

void init(uint magic, void* ptr)
{
	l.writeln("serial: Setting up 0x03F8");
	com1.setup(0x03F8);
	l.ring.addSink(com1.sink);

	parseMultiboot(magic, ptr);

	pci.checkAllBuses();
}

/**
 * Setup various devices and memory from multiboot information.
 */
void parseMultiboot(uint magic, void* ptr)
{
	l.write("mb: ");
	l.writeHex(magic);
	l.write(" ");
	l.writeHex(cast(size_t)ptr);
	l.writeln("");

	hal.multibootMagic = magic;
	if (magic == mb1.MAGIC) {
		return parseMultiboot1(cast(mb1.Info*)ptr);
	} else if (magic == mb2.MAGIC) {
		hal.multibootInfo = cast(mb2.Info*)ptr;
		return parseMultiboot2(hal.multibootInfo);
	}
}

void parseMultiboot1(mb1.Info* info)
{
	acpi.findX86(out hal.rsdt, out hal.xsdt);

	if (info.flags & mb1.Info.Flags.Mmap) {
		e820.fromMultiboot1(info);
	}
}

void parseMultiboot2(mb2.Info* info)
{
	mb2.TagMmap* mmap;
	mb2.TagFramebuffer* fb;
	mb2.TagOldACPI* oldACPI;
	mb2.TagNewACPI* newACPI;

	// Frist search the tags for the mmap tag.
	auto tag = cast(mb2.Tag*)&info[1];
	while (tag.type != mb2.TagType.END) {
		switch (tag.type) with (mb2.TagType) {
		case MMAP:
			mmap = cast(typeof(mmap))tag;
			break;
		case FRAMEBUFFER:
			fb = cast(typeof(fb))tag;
			break;
		case ACPI_OLD:
			oldACPI = cast(typeof(oldACPI))tag;
			break;
		case ACPI_NEW:
			newACPI = cast(typeof(newACPI))tag;
			break;
		default:
		}

		// Get new address and align.
		auto addr = cast(size_t)tag + tag.size;
		if (addr % 8) {
			addr += 8 - addr % 8;
		}
		tag = cast(mb2.Tag*)addr;
	}

	if (oldACPI !is null && newACPI is null) {
		hal.rsdt = cast(typeof(hal.rsdt)) oldACPI.rsdp.rsdtAddress;
	} else if (newACPI !is null) {
		hal.rsdt = cast(typeof(hal.rsdt)) newACPI.rsdp.v1.rsdtAddress;
		hal.xsdt = cast(typeof(hal.xsdt)) newACPI.rsdp.xsdtAddress;
	} else {
		acpi.findX86(out hal.rsdt, out hal.xsdt);
	}

	if (mmap !is null) {
		e820.fromMultiboot2(mmap);
	}

	if (fb !is null) {
		gfx.info.ptr = cast(void*)fb.framebuffer_addr;
		gfx.info.pitch = fb.framebuffer_pitch;
		gfx.info.w = fb.framebuffer_width;
		gfx.info.h = fb.framebuffer_height;
		gfx.info.pixelOffX = 8;
		gfx.info.pixelOffY = 8;
		gfx.info.installSink();
	}
}

void dumpACPI()
{
	acpi.RSDT* rsdt = hal.rsdt;
	acpi.XSDT* xsdt = hal.xsdt;

	if (rsdt !is null && xsdt is null) {
		acpi.dump(&rsdt.h);
		foreach (a; rsdt.array) {
			acpi.dump(cast(acpi.Header*) a);
		}
	} else if (rsdt !is null) {
		l.writeln("acpi: Selecting XSDT over RDST");
		acpi.dump(&rsdt.h);
	}


	if (xsdt !is null) {
		acpi.dump(&xsdt.h);
		foreach (a; xsdt.array) {
			acpi.dump(cast(acpi.Header*) a);
		}
	}
}
