// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.printer;


alias Sink = scope void delegate(scope const(char)[]);
global Sink sink;

char valToHex(int v)
{
	v = v & 0x0f;
	v = v + '0';
	if (v > '9') {
		v += 'A' - '9' - 1;
	}
	return cast(char)v;
}

void write(scope const(char)[] a)
{
	sink(a);
}

void writeln()
{
	sink("\n");
}

void writeln(scope const(char)[] a)
{
	sink(a);
	sink("\n");
}

void writeHex(ubyte v)
{
	char[2] buf;

	buf[0] = valToHex(v >>  4);
	buf[1] = valToHex(v >>  0);

	sink(buf);
}

void writeHex(ushort v)
{
	char[4] buf;

	buf[0] = valToHex(v >> 12);
	buf[1] = valToHex(v >>  8);
	buf[2] = valToHex(v >>  4);
	buf[3] = valToHex(v >>  0);

	sink(buf);
}

void writeHex(uint hex)
{
	char[8] buf;

	foreach (i, ref c; buf) {
		auto v = hex >> 28;

		c = valToHex(cast(int) v);
		hex = hex << 4;
	}

	sink(buf);
}

void writeHex(ulong hex)
{
	char[16] buf;

	foreach (i, ref c; buf) {
		auto v = hex >> 60;

		c = valToHex(cast(int) v);
		hex = hex << 4;
	}

	sink(buf);
}
