// Copyright © 2014, Bernard Helyer.  All rights reserved.
// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Hacky functions needed for the runtime,
 * will change with time.
 */
module metal.vrt;


/**
 * Generate a hash.
 * djb2 algorithm stolen from http://www.cse.yorku.ca/~oz/hash.html
 *
 * This needs to correspond with the implementation
 * in volt.util.string in the compiler.
 */
extern(C) fn vrt_hash(ptr: void*, length: size_t) u32
{
	h: u32 = 5381;

	uptr: u8* = cast(u8*) ptr;

	foreach (i; 0 .. length) {
		h = ((h << 5) + h) + uptr[i];
	}

	return h;
}
