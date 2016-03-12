// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.printer;


alias Sink = scope void delegate(scope const(char)[]);

char valToHex(int v)
{
	v = v & 0x0f;
	v = v + '0';
	if (v > '9') {
		v += 'A' - '9';
	}
	return cast(char)v;
}

void writeHex(Sink s, ubyte v)
{
	char[2] buf;

	buf[0] = valToHex(v >>  4);
	buf[1] = valToHex(v >>  0);

	s(buf);
}

void writeHex(Sink s, ushort v)
{
	char[4] buf;

	buf[0] = valToHex(v >> 12);
	buf[1] = valToHex(v >>  8);
	buf[2] = valToHex(v >>  4);
	buf[3] = valToHex(v >>  0);

	s(buf);
}

void writeHex(Sink s, uint hex)
{
	char[8] buf;	

	foreach (i, ref c; buf) {
		auto v = hex >> 28;

		c = valToHex(cast(int) v);
		hex = hex << 4;
	}

	s(buf);
}
