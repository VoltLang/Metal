// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.acpi;

import l = metal.printer;
import metal.stdc : memcmp;


struct RSDPDescriptor
{
	char[8] signature;
	ubyte checksum;
	char[6] OEMID;
	ubyte revision;
	uint rsdtAddress;
}

struct RSDPDescriptor20
{
	RSDPDescriptor v1;

	uint length;
	ulong xsdtAddress;
	ubyte extendedChecksum;
	ubyte[3] reserved;
}

struct Header
{
	char[4] signature;
	uint length;
	ubyte revision;
	ubyte checksum;
	char[6] OEMID;
	char[6] OEMTableID;
	uint OEMRevision;
	uint creatorID;
	uint creatorRevision;
}

struct RSDT
{
	Header h;

	@property size_t length()
	{
		return (h.length - typeid(h).size) / 4;
	}

	@property uint* ptr()
	{
		return cast(uint*)&(&h)[1];
	}

	@property uint[] array()
	{
		return ptr[0 .. length];
	}
}

struct XSDT
{
	Header h;

	@property size_t length()
	{
		return (h.length - typeid(h).size) / 8;
	}

	@property ulong* ptr()
	{
		return cast(ulong*)&(&h)[1];
	}

	@property ulong[] array()
	{
		return ptr[0 .. length];
	}
}

void findX86(out RSDT* rsdt, out XSDT* xsdt)
{
	for (size_t ptr = 0; ptr < 0x100000; ptr += 16) {
		if (memcmp(cast(void*)ptr, cast(void*)("RSD PTR ".ptr), 8) != 0) {
			continue;
		}

		auto t = cast(RSDPDescriptor20*)ptr;
		if (t.v1.revision >= 0) {
			rsdt = cast(RSDT*) t.v1.rsdtAddress;
		}

		if (t.v1.revision >= 2) {
			xsdt = cast(XSDT*) t.xsdtAddress;
		}
	}
}

void dump(Header* h)
{
	l.write("acpi: "); l.write(h.signature); l.write(" ");
	l.writeHex(h.length); l.write(" ");
	l.writeHex(cast(size_t)h); l.writeln("");
}
