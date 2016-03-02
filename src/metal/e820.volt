// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.e820;

import metal.vga;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;


/**
 * Static allocation that holds the memory map.
 */
global Map map;

/**
 *
 */
struct Map
{
	Entry[128] entries;
	size_t num;
}

/**
 *
 */
struct Entry
{
	ulong address;
	ulong size;
	ulong type;
}


/**
 * Setup the memory map from multiboot information.
 *
 * Can parse both multiboot1 and multiboot2.
 */
void fromMultiboot(uint magic, void* ptr)
{
	if (magic == mb1.Magic) {
		return fromMultiboot1(cast(mb1.Info*)ptr);
	} else if (magic == mb2.Magic) {
		return fromMultiboot2(cast(mb2.Info*)ptr);
	}

	terminal_writestring("No multiboot header");
	terminal_newline();
}

void fromMultiboot1(mb1.Info* info)
{
	if ((info.flags & mb1.Info.Flags.Mmap) == 0) {
		terminal_writestring("No mmap in Multiboot1 info");
		terminal_newline();
		return;
	}

	uint addr = info.mmap_addr;
	uint end = addr + info.mmap_length;

	foreach (ref e; map.entries[]) {
		if (addr >= end) {
			break;
		}

		uint size = *cast(uint*)(addr);
		e.address = *cast(ulong*)(addr + 4);
		e.size = *cast(ulong*)(addr + 12);
		e.type = *cast(uint*)(addr + 20);

		addr += size + 4;
		map.num++;
	}
}

void fromMultiboot2(mb2.Info* info)
{
	mb2.TagMmap* mmap;

	// Frist search the tags for the mmap tag.
	auto tag = cast(mb2.Tag*)&info[1];
	while (tag.type != mb2.TagType.END) {
		if (tag.type == mb2.TagType.MMAP) {
			mmap = cast(typeof(mmap))tag;
			break;
		}

		// Get new address and align.
		auto addr = cast(size_t)tag + tag.size;
		if (addr % 8) {
			addr += 8 - addr % 8;
		}
		tag = cast(mb2.Tag*)addr;
	}

	if (mmap is null) {
		terminal_writestring("No mmap in Multiboot2 info");
		terminal_newline();
		return;
	}

	// Info: mmap.entry_version is guaranteed to be
	// backwards compatible so no need to check it here.
	// This code is written against version 0.

	// The entries lies just after the mmap tag.
	uint addr = cast(uint)&mmap[1];
	// The stride/size is included.
	uint size = mmap.entry_size;
	uint end = cast(uint)tag + tag.size;

	foreach (ref e; map.entries[]) {
		if (addr >= end) {
			break;
		}

		auto entry = cast(mb2.MmapEntry*)addr;
		e.address = entry.base_addr;
		e.size = entry.length;
		e.type = entry.type;

		map.num++;
		addr += size;
	}
}

void dumpMap()
{
	foreach (ref e; map.entries[0 .. map.num]) {
		terminal_hex(e.address); terminal_writestring(" ");
		terminal_hex(e.size); terminal_writestring(" ");
		terminal_hex(cast(uint)e.type);
		terminal_newline();
	}
}
