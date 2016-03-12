// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.e820;

import metal.vga;
import metal.printer;
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


void fromMultiboot1(mb1.Info* info)
{
	uint addr = info.mmap_addr;
	uint end = addr + info.mmap_length;

	foreach (ref e; map.entries) {
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

void fromMultiboot2(mb2.TagMmap* mmap)
{
	// Info: mmap.entry_version is guaranteed to be
	// backwards compatible so no need to check it here.
	// This code is written against version 0.

	// The entries lies just after the mmap tag.
	uint addr = cast(uint)&mmap[1];
	// The stride/size is included.
	uint size = mmap.entry_size;
	uint end = cast(uint)mmap + mmap.size;

	foreach (ref e; map.entries) {
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
		writeHex(e.address); write(" ");
		writeHex(e.size); write(" ");
		writeHex(cast(uint)e.type);
		writeln();
	}
}
