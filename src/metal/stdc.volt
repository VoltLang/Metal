// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Standard C lib functions that the compilers use.
 * GCC, Clang, Volt all uses these functions from code.
 */
module metal.stdc;


extern(C) void* memcpy(void* dst, const(void)* src, size_t n)
{
	void* old = dst;
	while (n--) {
		*dst++ = *src++;
	}
	return old;
}

extern(C) void* memmove(void* dst, const(void)* src, size_t n)
{
	char* d = cast(char*)dst;
	const(char)* s = cast(const(char)*)src;

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

extern(C) int memcmp(const(void)* ptr1, const(void)* ptr2, size_t n)
{
	const(char)* p1 = cast(const(char)*) ptr1;
	const(char)* p2 = cast(const(char)*) ptr2;
	while (n--) {
		int ret = *p1++ - *p2++;
		if (ret) {
			return ret;
		}
	}
	return 0;
}

extern(C) void* memset(void* ptr, const int val, size_t n)
{
	char* p = cast(char*) ptr;
	while (n--) {
		*p++ = cast(char)val;
	}
	return ptr;
}
