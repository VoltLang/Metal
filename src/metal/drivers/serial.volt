// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.drivers.serial;

import arch.x86.ioports;


global Serial com1;

struct Serial
{
public:
	ushort port;

public:
	ushort off(ushort off)
	{
		return cast(ushort)(port + off);
	}

	void setup(ushort port)
	{
		this.port = port;
		outb(off(1), 0x00);    // Disable all interrupts
		outb(off(3), 0x80);    // Enable DLAB (set baud rate divisor)
		outb(off(0), 0x01);    // Set divisor to 1 (lo byte) 115200 baud
		outb(off(1), 0x00);    //                  (hi byte)
		outb(off(3), 0x03);    // 8 bits, no parity, one stop bit
		outb(off(2), 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
		outb(off(4), 0x0B);    // IRQs enabled, RTS/DSR set
	}

	bool writeEmpty()
	{
		return (inb(off(5)) & 0x20) != 0;
	}

	void sink(scope const(char)[] str)
	{
		foreach (char c; str) {
			while (!writeEmpty()) {}
			outb(port, c);
		}
	}

	void write(char a)
	{
		while (!writeEmpty()) {}
		outb(port, a);
	}

	alias write = sink;

	void writeln()
	{
		write("\n");
	}

	void writeln(scope const(char)[] str)
	{
		write(str);
		write("\n");
	}
}
