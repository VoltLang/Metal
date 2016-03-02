// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.main;

import metal.vga;
import e820 = metal.e820;


extern(C) void metal_main(uint magic, void* multibootInfo)
{

	terminal_initialize();

	terminal_writestring("Volt Metal");
	terminal_newline();

	terminal_writestring("Magic: ");
	terminal_hex(magic);
	terminal_newline();

	e820.fromMultiboot(magic, multibootInfo);
	e820.dumpMap();
}
