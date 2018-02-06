// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.boot.multiboot2;

import l = metal.printer;
import metal.acpi;


enum MAGIC = 0x36d76289;

enum TagType : u32
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

global tagNames: immutable string[20] = [
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
	total_size: u32;
	reserved: u32;
}

struct Tag
{
	type: TagType;
	size: u32;
}

struct TagMmap
{
	type: TagType;
	size: u32;
	entry_size: u32;
	entry_version: u32;
}

enum Memory : u32
{
	AVAILABLE          = 1,
	RESERVED           = 2,
	ACPI_RECLAIMABLE   = 3,
	NVS                = 4,
	BADRAM             = 5,
}

struct MmapEntry
{
	base_addr: u64;
	length: u64;
	type: Memory;
	zero: u32;
}

enum FramebufferType : u32
{
	INDEXED = 0x00,
	RGB     = 0x01,
	VGA     = 0x02,
}

struct TagFramebuffer
{
	type: TagType;
	size: u32;
	framebuffer_addr: u64;
	framebuffer_pitch: u32;
	framebuffer_width: u32;
	framebuffer_height: u32;
	framebuffer_bpp: u8;
	framebuffer_type: u8;
	reserved: u8;
}

struct TagEFI32
{
	type: TagType;
	size: u32;
	pointer: u32;
}

struct TagEFI64
{
	type: TagType;
	size: u32;
	pointer: u64;
}

struct TagOldACPI
{
	type: TagType;
	size: u32;

	@property fn rsdp() RSDPDescriptor*
	{
		return cast(RSDPDescriptor*)&(&this)[1];
	}
}

struct TagNewACPI
{
	type: TagType;
	size: u32;

	@property fn rsdp() RSDPDescriptor20*
	{
		return cast(RSDPDescriptor20*)&(&this)[1];
	}
}

struct TagEFIMMAP
{
	type: TagType;
	size: u32;
	descr_size: u32;
	descr_vers: u32;

	@property fn mmap() void*
	{
		return cast(void*)&(&this)[1];
	}
}

fn dump(magic: u32, info: Info*)
{
	// Turns out that info might be null but still be valid
	// because grub might put it there (it does on EFI macs).
	if (magic != MAGIC) {
		return;
	}

	tag := cast(Tag*)&info[1];
	while (tag.type != TagType.END) {
		l.write("mb: ");
		l.writeHex(cast(u8)tag.type); l.write(" ");
		l.writeHex(tag.size); l.write(" ");
		i: size_t = tag.type;
		if (i >= tagNames.length) {
			i = tagNames.length - 1;
		}
		l.writeln(cast(string)tagNames[i]);

		// Get new address and align.
		addr := cast(size_t)tag + tag.size;
		if (addr % 8) {
			addr += 8 - addr % 8;
		}
		tag = cast(Tag*)addr;
	}
}
