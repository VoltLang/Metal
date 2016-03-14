// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.printer;


alias Sink = void delegate(scope const(char)[]);

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
	ring.put(a);
}

void writeln()
{
	ring.put("\n");
}

void writeln(scope const(char)[] a)
{
	ring.put(a);
	ring.put("\n");
}

void writeHex(ubyte v)
{
	char[2] buf;

	buf[0] = valToHex(v >>  4);
	buf[1] = valToHex(v >>  0);

	ring.put(buf);
}

void writeHex(ushort v)
{
	char[4] buf;

	buf[0] = valToHex(v >> 12);
	buf[1] = valToHex(v >>  8);
	buf[2] = valToHex(v >>  4);
	buf[3] = valToHex(v >>  0);

	ring.put(buf);
}

void writeHex(uint hex)
{
	char[8] buf;

	foreach (i, ref c; buf) {
		auto v = hex >> 28;

		c = valToHex(cast(int) v);
		hex = hex << 4;
	}

	ring.put(buf);
}

void writeHex(ulong hex)
{
	char[16] buf;

	foreach (i, ref c; buf) {
		auto v = hex >> 60;

		c = valToHex(cast(int) v);
		hex = hex << 4;
	}

	ring.put(buf);
}

struct Ring
{
	char[10258] buf;
	Sink[4] sinks;
	uint writePos;
	uint numSinks;

	void put(scope const(char)[] str)
	{
		foreach (s; sinks[0 .. numSinks]) {
			s(str);
		}

		foreach (char c; str) {
			buf[writePos++] = c;
			if (writePos > buf.length) {
				writePos = 0;
			}
		}
	}

	void addSink(Sink sink)
	{
		sinks[numSinks++] = sink;
		print(sink);
	}

	void print(Sink sink)
	{
		auto t = buf[writePos .. buf.length];
		if (t.length != 0 && t[0] != '\0') {
			sink(t);
		}

		t = buf[0 .. writePos];
		if (t.length != 0) {
			sink(t);
		}
	}
}

global Ring ring;
