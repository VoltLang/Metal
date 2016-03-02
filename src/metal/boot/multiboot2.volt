// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.boot.multiboot2;


enum Magic = 0x36d76289;

enum TagType : uint
{
	END              = 0,
	CMDLINE          = 1,
	BOOT_LOADER_NAME = 2,
	MODULE           = 3,
	BASIC_MEMINFO    = 4,
	BOOTDEV          = 5,
	MMAP             = 6,
	VBE              = 7,
	FRAMEBUFFER      = 8,
	ELF_SECTIONS     = 9,
	APM              = 10,
	EFI32            = 11,
	EFI64            = 12,
	SMBIOS           = 13,
	ACPI_OLD         = 14,
	ACPI_NEW         = 15,
	NETWORK          = 16,
}


struct Info
{
	uint total_size;
	uint reserved;
}

struct Tag
{
	TagType type;
	uint size;
}

struct TagMmap
{
	TagType type;
	uint size;
	uint entry_size;
	uint entry_version;
}

enum Memory : uint
{
	AVAILABLE          = 1,
	RESERVED           = 2,
	ACPI_RECLAIMABLE   = 3,
	NVS                = 4,
	BADRAM             = 5,
}

struct MmapEntry
{
	ulong base_addr;
	ulong length;
	Memory type;
	uint zero;
}
