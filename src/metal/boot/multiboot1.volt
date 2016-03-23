// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.boot.multiboot1;


enum MAGIC = 0x2BADB002;

struct Info
{
	enum Flags : int {
		Mem        = 1 << 0,
		BootDevice = 1 << 1,
		CmdLine    = 1 << 2,
		Mmap       = 1 << 6,
	}

	Flags flags;

	uint mem_lower;
	uint mem_upper;

	uint boot_device;

	uint cmdline;

	uint mods_count;
	uint mods_addr;

	uint syms0;
	uint syms1;
	uint syms2;
	uint syms3;

	uint mmap_length;	
	uint mmap_addr;

	uint drivers_lengtH;
	uint drivers_addr;

	uint config_table;

	uint boot_loder_name;

	uint apm_table;

	uint vbe_control_info;
	uint vbe_mode_info;
	uint vbe_mode;
	uint vbe_interface_seg;
	uint vbe_interace_len;
}
