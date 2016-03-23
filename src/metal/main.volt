// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.main;

import e820 = metal.e820;
import bochs = metal.drivers.bochs;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;
import hal = metal.hal;
import gfx = metal.gfx;
import pci = metal.pci;
import acpi = metal.acpi;
import metal.drivers.serial;
import metal.printer;
import metal.stdc;


extern(C) void metal_main(uint magic, void* multibootInfo)
{
	writeln("Volt Metal");
	hal.init(magic, multibootInfo);

	if (bochs.dev.loaded) {
		gfx.info.ptr = bochs.dev.ptr;
		gfx.info.w = bochs.dev.w;
		gfx.info.h = bochs.dev.h;
		gfx.info.pitch = bochs.dev.pitch;
		gfx.info.pixelOffX = 8;
		gfx.info.pixelOffY = 8;
		gfx.info.installSink();
	}

	mb2.dump(hal.hal.multibootMagic, hal.hal.multibootInfo);
	hal.dumpACPI();
	e820.dumpMap();
	pci.dumpDevices();
}
