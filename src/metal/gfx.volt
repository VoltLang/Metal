// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.gfx;


struct Info
{
	uint w;
	uint h;
	uint pitch;

	void* ptr;
}

global Info info;


void scribble()
{
	foreach (y; 0u .. 8u) {
		clearLine(y, 0xFFFFFFFFu);
	}
	foreach (y; info.h - 8 .. info.h) {
		clearLine(y, 0xFFFFFFFFu);
	}
}

void clearLine(size_t y, uint color)
{
	auto ptr = cast(uint*)info.ptr + (info.pitch * y / 4);
	foreach (x; 0 .. info.w) {
		ptr[x] = color;
	}
}
