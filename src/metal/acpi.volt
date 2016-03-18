// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.acpi;


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
	ulong xsdtAdress;
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
