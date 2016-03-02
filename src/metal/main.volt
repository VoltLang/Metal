// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/volt/license.d (BOOST ver. 1.0).
module metal.main;

import metal.vga;


extern(C) void metal_main(int magic, void* meminfo)
{
	terminal_initialize();

	terminal_writestring("Volt Metal");
	terminal_newline();

	terminal_writestring("Magic: ");
	terminal_hex(magic);
	terminal_newline();

	terminal_writestring("Meninfo: ");
	terminal_hex(cast(int)meminfo);
	terminal_newline();
}
