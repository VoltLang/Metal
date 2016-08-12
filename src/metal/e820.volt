// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.e820;

import metal.printer;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;


/**
 * Static allocation that holds the memory map.
 */
global map: Map;

/**
 *
 */
struct Map
{
	entries: Entry[128];
	num: size_t;
}

/**
 *
 */
struct Entry
{
	address: u64;
	size: u64;
	type: u64;
}


fn fromMultiboot1(info: mb1.Info*)
{
	addr: u32 = info.mmap_addr;
	end: u32 = addr + info.mmap_length;

	foreach (ref e; map.entries) {
		if (addr >= end) {
			break;
		}

		size := *cast(u32*)(addr);
		e.address = *cast(u64*)(addr + 4);
		e.size = *cast(u64*)(addr + 12);
		e.type = *cast(u32*)(addr + 20);

		addr += size + 4;
		map.num++;
	}
}

fn fromMultiboot2(mmap: mb2.TagMmap*)
{
	// Info: mmap.entry_version is guaranteed to be
	// backwards compatible so no need to check it here.
	// This code is written against version 0.

	// The entries lies just after the mmap tag.
	addr: u32 = cast(u32)&mmap[1];
	// The stride/size is included.
	size: u32 = mmap.entry_size;
	end: u32 = cast(u32)mmap + mmap.size;

	foreach (ref e; map.entries) {
		if (addr >= end) {
			break;
		}

		entry := cast(mb2.MmapEntry*)addr;
		e.address = entry.base_addr;
		e.size = entry.length;
		e.type = entry.type;

		map.num++;
		addr += size;
	}
}

fn dumpMap()
{
	foreach (ref e; map.entries[0 .. map.num]) {
		write("e820: ");
		writeHex(e.address); write(" ");
		writeHex(e.address + e.size); write(" ");
		writeHex(cast(u32)e.type);
		writeln();
	}
}
