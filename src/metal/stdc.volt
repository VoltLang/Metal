// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Standard C lib functions that the compilers use.
 * GCC, Clang, Volt all uses these functions from code.
 */
module metal.stdc;


extern(C) fn memcpy(dst: void*, src: const(void)*, n: size_t) void*
{
	d := cast(u8*)dst;
	s := cast(u8*)src;
	while (n--) {
		*d++ = *s++;
	}
	return dst;
}

extern(C) fn memmove(dst: void*, src: const(void)*, n: size_t) void*
{
	d := cast(u8*)dst;
	s := cast(const(u8)*)src;

	if (cast(size_t)src < cast(size_t)dst &&
	    cast(size_t)dst < cast(size_t)src + n) {
		s += n;
		d += n;

		while (n--) {
			*--d = *--s;
		}
	} else {
		while (n--) {
			*d++ = *s++;
		}
	}

	return dst;
}

extern(C) fn memcmp(ptr1: const(void)*, ptr2: const(void)*, n: size_t) int
{
	p1 := cast(const(u8)*) ptr1;
	p2 := cast(const(u8)*) ptr2;
	while (n--) {
		ret := *p1++ - *p2++;
		if (ret) {
			return ret;
		}
	}
	return 0;
}

extern(C) fn memset(ptr: void*, val: const int, n: size_t) void*
{
	p := cast(u8*) ptr;
	while (n--) {
		*p++ = cast(u8)val;
	}
	return ptr;
}
