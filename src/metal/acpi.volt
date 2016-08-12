// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.acpi;

import l = metal.printer;
import metal.stdc : memcmp;


struct RSDPDescriptor
{
	signature: char[8];
	checksum: u8;
	OEMID: char[6];
	revision: u8;
	rsdtAddress: u32;
}

struct RSDPDescriptor20
{
	v1: RSDPDescriptor;

	length: u32;
	xsdtAddress: u64;
	extendedChecksum: u8;
	reserved: u8[3];
}

struct Header
{
	signature: char[4];
	length: u32;
	revision: u8;
	checksum: u8;
	OEMID: char[6];
	OEMTableID: char[6];
	OEMRevision: u32;
	creatorID: u32;
	creatorRevision: u32;
}

struct RSDT
{
	h: Header;

	@property fn length() size_t
	{
		return (h.length - typeid(h).size) / 4;
	}

	@property fn ptr() u32*
	{
		return cast(u32*)&(&h)[1];
	}

	@property fn array() u32[]
	{
		return ptr[0 .. length];
	}
}

struct XSDT
{
	h: Header;

	@property fn length() size_t
	{
		return (h.length - typeid(h).size) / 8;
	}

	@property fn ptr() u64*
	{
		return cast(u64*)&(&h)[1];
	}

	@property fn array() u64[]
	{
		return ptr[0 .. length];
	}
}

fn findX86(out rsdt: RSDT*, out xsdt: XSDT*)
{
	for (ptr: size_t; ptr < 0x100000; ptr += 16) {
		if (memcmp(cast(void*)ptr, cast(void*)("RSD PTR ".ptr), 8) != 0) {
			continue;
		}

		t := cast(RSDPDescriptor20*)ptr;
		if (t.v1.revision >= 0) {
			rsdt = cast(RSDT*) t.v1.rsdtAddress;
		}

		if (t.v1.revision >= 2) {
			xsdt = cast(XSDT*) t.xsdtAddress;
		}
	}
}

fn dump(h: Header*)
{
	l.write("acpi: "); l.write(h.signature); l.write(" ");
	l.writeHex(h.length); l.write(" ");
	l.writeHex(cast(size_t)h); l.writeln("");
}
