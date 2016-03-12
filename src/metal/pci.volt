// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.pci;

import metal.drivers.serial;
import metal.printer;
import arch.x86.ioports;


enum Offset : ubyte {
	VENDOR   = 0x00,
	DEVICE   = 0x02,
	CLASS    = 0x0B,
	SUBCLASS = 0x0A,
	HEADER   = 0x0E,

	SECONDARY_BUS = 0x19,
}

struct Header
{
	ushort vendor;
	ushort device;

	ushort command;
	ushort status;

	ubyte rev;
	ubyte progIF;
	ubyte subClass;
	ubyte baseClass;

	ubyte cacheLineSize;
	ubyte latencyTimer;
	ubyte headerType;
	ubyte BIST;
}

/**
 * Is there a device there?
 */
bool isValidDevice(ubyte bus, ubyte slot, ubyte func)
{
	return readUshort(bus, slot, func, Offset.VENDOR) != 0xFFFF;
}

/**
 * We have detected a device (down to the function).
 * If it is a pci-to-pci bridge we scan that as well. 
 */
void checkFunction(ubyte bus, ubyte slot, ubyte func)
{
	dumpDevice(bus, slot, func);

	Header h;
	readHeader(bus, slot, func, ref h);

	if ((h.baseClass == 0x06) && (h.subClass == 0x04)) {
		ubyte secondaryBus = readUbyte(bus, slot, func, Offset.SECONDARY_BUS);
		checkBus(secondaryBus);
	}
}

void checkDevice(ubyte bus, ubyte slot)
{
	ubyte func;

	if (!isValidDevice(bus, slot, 0)) {
		return;
	}
	checkFunction(bus, slot, 0);

	auto headerType = readUshort(bus, slot, func, Offset.HEADER);
	if ((headerType & 0x80) != 0) {
		for (func = 1; func < 8; func++) {
			if (!isValidDevice(bus, slot, func)) {
				continue;
			}
			checkFunction(bus, slot, func);
		}
	}
}

void checkBus(ubyte bus)
{
	foreach (slot; 0 .. 32) {
		checkDevice(bus, cast(ubyte)slot);
	}
}

void checkAllBuses()
{
	Header h;

	if (!isValidDevice(0, 0, 0)) {
		return;
	}

	readHeader(0, 0, 0, ref h);
	if ((h.headerType & 0x80) == 0) {
		checkBus(0);
	} else {
		foreach (i; 0 .. 8) {
			auto func = cast(ubyte) i;

			if (!isValidDevice(0, 0, func)) {
				break;
			}
			checkBus(func);
		}
	}
}


/*
 *
 * Reader functions.
 *
 */

void readHeader(ubyte bus, ubyte slot, ubyte func, ref Header h)
{
	uint* ptr = cast(uint*) &h;
	foreach (i; 0 .. 4) {
		ptr[i] = readUint(bus, slot, func, cast(ubyte) (i * 4));
	}
}

uint readUint(ubyte bus, ubyte slot, ubyte func, ubyte offset)
{
	uint address = cast(uint) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000);
	outl(0xCF8, address);
	return inl(0xCFC);
}

ushort readUshort(ubyte bus, ubyte slot, ubyte func, ubyte offset)
{
	uint address  = cast(uint) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000);

	outl(0xCF8, address);
	int shift = (offset & 2) * 8;
	int read = cast(int) inl(0xCFC);
	return cast(ushort) (read >> shift);
}

ubyte readUbyte(ubyte bus, ubyte slot, ubyte func, ubyte offset)
{
	uint address  = cast(uint) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000);

	outl(0xCF8, address);
	int shift = (offset & 3) * 8;
	int read = cast(int) inl(0xCFC);
	return cast(ubyte) (read >> shift);
}


/*
 *
 * Temporary dump functions.
 *
 */

void dumpDevice(ubyte bus, ubyte slot, ubyte func)
{
	char[8] buf;
	buf[0] = valToHex(bus >> 8);
	buf[1] = valToHex(bus     );
	buf[2] = ':';
	buf[3] = valToHex(slot >> 8);
	buf[4] = valToHex(slot     );
	buf[5] = '.';
	buf[6] = valToHex(func);
	buf[7] = ' ';

	Header h;
	readHeader(bus, slot, func, ref h);

	com1.sink(buf);
	com1.sink.writeHex(h.vendor); com1.write(" ");
	com1.sink.writeHex(h.device); com1.write(" class: ");
	com1.sink.writeHex(h.baseClass); com1.write(", sub: ");
	com1.sink.writeHex(h.subClass); com1.write(", header: ");
	com1.sink.writeHex(h.headerType); com1.writeln();
}