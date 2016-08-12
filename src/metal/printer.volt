// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.printer;


alias Sink = void delegate(scope const(char)[]);

fn valToHex(v: u64) char
{
	v = v & 0x0f;
	v = v + '0';
	if (v > '9') {
		v += cast(u64)('A' - '9' - 1);
	}
	return cast(char)v;
}

fn write(a: scope const(char)[])
{
	ring.put(a);
}

fn writeln()
{
	ring.put("\n");
}

fn writeln(a: scope const(char)[])
{
	ring.put(a);
	ring.put("\n");
}

fn writeHex(v: u8)
{
	buf: char[2];

	buf[0] = valToHex(v >>  4u);
	buf[1] = valToHex(v >>  0u);

	ring.put(buf);
}

fn writeHex(v: u16)
{
	buf: char[4];

	buf[0] = valToHex(v >> 12u);
	buf[1] = valToHex(v >>  8u);
	buf[2] = valToHex(v >>  4u);
	buf[3] = valToHex(v >>  0u);

	ring.put(buf);
}

fn writeHex(hex: u32)
{
	buf: char[8];

	foreach (i, ref c; buf) {
		v := hex >> 28;

		c = valToHex(v);
		hex = hex << 4;
	}

	ring.put(buf);
}

fn writeHex(hex: u64)
{
	buf: char[16];

	foreach (i, ref c; buf) {
		v := hex >> 60;

		c = valToHex(v);
		hex = hex << 4;
	}

	ring.put(buf);
}

struct Ring
{
	buf: char[10258];
	sinks: Sink[4];
	writePos: u32;
	numSinks: u32;

	fn put(str: scope const(char)[])
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

	fn addSink(sink: Sink)
	{
		sinks[numSinks++] = sink;
		print(sink);
	}

	fn print(sink: Sink)
	{
		t := buf[writePos .. buf.length];
		if (t.length != 0 && t[0] != '\0') {
			sink(t);
		}

		t = buf[0 .. writePos];
		if (t.length != 0) {
			sink(t);
		}
	}
}

global ring: Ring;
