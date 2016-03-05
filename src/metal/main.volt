// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.main;

import metal.vga;
import e820 = metal.e820;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;


extern(C) void metal_main(uint magic, void* multibootInfo)
{
	parseMultiboot(magic, multibootInfo);

	terminal_initialize();
	terminal_writestring("Volt Metal");
	terminal_newline();

	e820.dumpMap();
}

/**
 * Setup various devices and memory from multiboot information.
 */
void parseMultiboot(uint magic, void* ptr)
{
	if (magic == mb1.Magic) {
		return parseMultiboot1(cast(mb1.Info*)ptr);
	} else if (magic == mb2.Magic) {
		return parseMultiboot2(cast(mb2.Info*)ptr);
	}
}

void parseMultiboot1(mb1.Info* info)
{
	if (info.flags & mb1.Info.Flags.Mmap) {
		e820.fromMultiboot1(info);
	}
}

void parseMultiboot2(mb2.Info* info)
{
	mb2.TagMmap* mmap;

	// Frist search the tags for the mmap tag.
	auto tag = cast(mb2.Tag*)&info[1];
	while (tag.type != mb2.TagType.END) {
		switch (tag.type) with (mb2.TagType) {
		case MMAP:
			mmap = cast(typeof(mmap))tag;
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

	if (mmap !is null) {
		e820.fromMultiboot2(mmap);
	}
}
