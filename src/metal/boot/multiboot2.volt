// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.boot.multiboot2;

import l = metal.printer;
import metal.acpi;


enum MAGIC = 0x36d76289;

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
	EFI_MMAP         = 17,
	EFI_BS           = 18,
}

global immutable string[20] tagNames = [
	"END",
	"CMDLINE",
	"BOOT_LOADER_NAME",
	"MODULE",
	"BASIC_MEMINFO",
	"BOOTDEV",
	"MMAP",
	"VBE",
	"FRAMEBUFFER",
	"ELF_SECTIONS",
	"APM",
	"EFI32",
	"EFI64",
	"SMBIOS",
	"ACPI_OLD",
	"ACPI_NEW",
	"NETWORK",
	"EFI_MMAP",
	"EFI_BS",
	"UNKOWN",
];

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

enum FramebufferType : uint
{
	INDEXED = 0x00,
	RGB     = 0x01,
	VGA     = 0x02,
}

struct TagFramebuffer
{
	TagType type;
	uint size;
	ulong framebuffer_addr;
	uint framebuffer_pitch;
	uint framebuffer_width;
	uint framebuffer_height;
	ubyte framebuffer_bpp;
	ubyte framebuffer_type;
	ubyte reserved;
}

struct TagEFI32
{
	TagType type;
	uint size;
	uint pointer;
}

struct TagEFI64
{
	TagType type;
	uint size;
	ulong pointer;
}

struct TagOldACPI
{
	TagType type;
	uint size;

	@property RSDPDescriptor* rsdp()
	{
		return cast(RSDPDescriptor*)&(&this)[1];
	}
}

struct TagNewACPI
{
	TagType type;
	uint size;

	@property RSDPDescriptor20* rsdp()
	{
		return cast(RSDPDescriptor20*)&(&this)[1];
	}
}

struct TagEFIMMAP
{
	TagType type;
	uint size;
	uint descr_size;
	uint descr_vers;
	@property void* mmap()
	{
		return cast(void*)&(&this)[1];
	}
}

void dump(uint magic, Info* info)
{
	// Turns out that info might be null but still be valid
	// because grub might put it there (it does on EFI macs).
	if (magic != MAGIC) {
		return;
	}

	auto tag = cast(Tag*)&info[1];
	while (tag.type != TagType.END) {
		l.write("mb: ");
		l.writeHex(cast(ubyte)tag.type); l.write(" ");
		l.writeHex(tag.size); l.write(" ");
		size_t i = tag.type;
		if (i >= tagNames.length) {
			i = tagNames.length - 1;
		}
		l.writeln(tagNames[i]);

		// Get new address and align.
		auto addr = cast(size_t)tag + tag.size;
		if (addr % 8) {
			addr += 8 - addr % 8;
		}
		tag = cast(Tag*)addr;
	}
}
