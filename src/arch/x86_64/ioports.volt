// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module arch.x86.ioports;


extern(C) fn inb(port: u16) u8;
extern(C) fn inw(port: u16) u16;
extern(C) fn inl(port: u16) u32;
extern(C) fn outb(port: u16, val: u8) void;
extern(C) fn outw(port: u16, val: u16) void;
extern(C) fn outl(port: u16, val: u32) void;
