// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.boot.multiboot1;


enum MAGIC = 0x2BADB002;

struct Info
{
	enum Flags : i32 {
		Mem        = 1 << 0,
		BootDevice = 1 << 1,
		CmdLine    = 1 << 2,
		Mmap       = 1 << 6,
	}

	flags: Flags;

	mem_lower: u32;
	mem_upper: u32;

	boot_device: u32;

	cmdline: u32;

	mods_count: u32;
	mods_addr: u32;

	syms0: u32;
	syms1: u32;
	syms2: u32;
	syms3: u32;

	mmap_length: u32;
	mmap_addr: u32;

	drivers_length: u32;
	drivers_addr: u32;

	config_table: u32;

	boot_loder_name: u32;

	apm_table: u32;

	vbe_control_info: u32;
	vbe_mode_info: u32;
	vbe_mode: u32;
	vbe_interface_seg: u32;
	vbe_interace_len: u32;
}
