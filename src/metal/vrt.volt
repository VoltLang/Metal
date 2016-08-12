// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Hacky functions needed for the runtime,
 * will change with time.
 */
module metal.vrt;


extern(C) fn exit(int)
{
	*cast(int*)null = 0;
}

extern(C) fn printf() int
{
	return 0;
}

extern(C) fn calloc(n: size_t, size: size_t) void*
{
	return null;
}
