// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module arch.x86.ioports;


extern(C) ubyte inb(ushort port);
extern(C) uint inl(ushort port);
extern(C) void outb(ushort port, ubyte val);
extern(C) void outl(ushort port, uint val);
