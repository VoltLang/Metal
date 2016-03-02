// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Hacky functions needed for the runtime,
 * will change with time.
 */
module metal.vrt;


extern(C) void exit(int)
{
	*cast(int*)null = 0;
}

extern(C) int printf()
{
	return 0;
}

extern(C) void* calloc(size_t n, size_t size)
{
	return null;
}
