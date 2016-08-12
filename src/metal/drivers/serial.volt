// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.drivers.serial;

import arch.x86.ioports;


global com1: Serial;

struct Serial
{
public:
	port: u16;

public:
	fn off(off: u16) u16
	{
		return cast(u16)(port + off);
	}

	fn setup(port: u16)
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

	fn writeEmpty() bool
	{
		return (inb(off(5)) & 0x20) != 0;
	}

	fn sink(str: scope const(char)[])
	{
		foreach (c: char; str) {
			while (!writeEmpty()) {}
			outb(port, c);
		}
	}

	fn write(a: char)
	{
		while (!writeEmpty()) {}
		outb(port, a);
	}

	alias write = sink;

	fn writeln()
	{
		write("\n");
	}

	fn writeln(str: scope const(char)[])
	{
		write(str);
		write("\n");
	}
}
