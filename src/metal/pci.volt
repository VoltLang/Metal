// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
module metal.pci;

import metal.drivers.serial;
import metal.printer;
import arch.x86_64.ioports;
import bochs = metal.drivers.bochs;


enum Offset : u8 {
	VENDOR   = 0x00,
	DEVICE   = 0x02,
	CLASS    = 0x0B,
	SUBCLASS = 0x0A,
	HEADER   = 0x0E,

	SECONDARY_BUS = 0x19,

	CAPABILITY_LIST = 0x34,
}

enum CapId : u8 {
	PM		= 0x01,	/* Power Management */
	AGP		= 0x02,	/* Accelerated Graphics Port */
	VPD		= 0x03,	/* Vital Product Data */
	SLOT_ID		= 0x04,	/* Slot Identification */
	MSI		= 0x05,	/* Message Signalled Interrupts */
	CHSWP		= 0x06,	/* CompactPCI HotSwap */
	PCIX		= 0x07,	/* PCI-X */
	HT		= 0x08,	/* HyperTransport */
	VNDR		= 0x09,	/* Vendor-Specific */
	DBG		= 0x0A,	/* Debug port */
	CCRC		= 0x0B,	/* CompactPCI Central Resource Control */
	SHPC		= 0x0C,	/* PCI Standard Hot-Plug Controller */
	SSVID		= 0x0D,	/* Bridge subsystem vendor/device ID */
	AGP3		= 0x0E,	/* AGP Target PCI-PCI bridge */
	SECDEV		= 0x0F,	/* Secure Device */
	EXP		= 0x10,	/* PCI Express */
	MSIX		= 0x11,	/* MSI-X */
	SATA		= 0x12,	/* SATA Data/Index Conf. */
	AF		= 0x13,	/* PCI Advanced Features */
	EA		= 0x14,	/* PCI Enhanced Allocation */
}

enum CapOffset : u8 {
	LIST_ID		= 0,	/* Capability ID */
	LIST_NEXT	= 1,	/* Next capability in the list */
	FLAGS		= 2,	/* Capability defined flags (16 bits) */
	SIZEOF		= 4,
}

enum CapNames = [
	"N/A",
	"PM",
	"AGP",
	"VPD",
	"SLOT_ID",
	"MSI",
	"CHSWP",
	"PCIX",
	"HT",
	"VNDR",
	"DBG",
	"CCRC",
	"SHPC",
	"SSVID",
	"AGP3",
	"SECDEV",
	"EXP",
	"MSIX",
	"SATA",
	"AF",
	"EA",
];

struct Header
{
	vendor: u16;
	device: u16;

	command: u16;
	status: u16;

	rev: u8;
	progIF: u8;
	subClass: u8;
	baseClass: u8;

	cacheLineSize: u8;
	latencyTimer: u8;
	headerType: u8;
	BIST: u8;
}

struct Device
{
	bus, slot, func, headerType: u8;
	vendor, device: u16;
	rev, progIF, subClass, baseClass: u8;

	cap: u32;
}

struct Info {
	devs: Device[256];
	num: u32;
}

global info: Info;

/**
 * Load a given device.
 */
fn loadDevice(dev: Device*)
{
	if (dev.vendor == 0x1234 && dev.device == 0x1111) {
		bochs.loadFromPCI(dev);
	}
}

/**
 * Is there a device there?
 */
fn isValidDevice(bus: u8, slot: u8, func: u8) bool
{
	return readU16(bus, slot, func, Offset.VENDOR) != 0xFFFF;
}

/**
 * We have detected a device (down to the function).
 * If it is a pci-to-pci bridge we scan that as well. 
 */
fn checkFunction(bus: u8, slot: u8, func: u8)
{
	h: Header;
	readHeader(bus, slot, func, ref h);

	dev := &info.devs[info.num++];
	dev.bus = bus;
	dev.slot = slot;
	dev.func = func;
	dev.headerType = h.headerType;
	dev.vendor = h.vendor;
	dev.device = h.device;
	dev.rev = h.rev;
	dev.progIF = h.progIF;
	dev.subClass = h.subClass;
	dev.baseClass = h.baseClass;

	capPos := readU8(bus, slot, func, 0x34);
	while (capPos != 0) {
		readPos := cast(u8)(capPos + CapOffset.LIST_ID);
		id := readU8(bus, slot, func, readPos);
		readPos = cast(u8)(capPos + CapOffset.LIST_NEXT);
		capPos = readU8(bus, slot, func, readPos);
		if (id <= 31) {
			dev.cap |= 1u << id;
		}
	}

	if ((h.baseClass == 0x06) && (h.subClass == 0x04)) {
		secondaryBus := readU8(bus, slot, func, Offset.SECONDARY_BUS);
		checkBus(secondaryBus);
	}
}

fn checkDevice(bus: u8, slot: u8)
{
	func: u8;

	if (!isValidDevice(bus, slot, 0)) {
		return;
	}
	checkFunction(bus, slot, 0);

	headerType := readU16(bus, slot, func, Offset.HEADER);
	if ((headerType & 0x80) != 0) {
		for (func = 1; func < 8; func++) {
			if (!isValidDevice(bus, slot, func)) {
				continue;
			}
			checkFunction(bus, slot, func);
		}
	}
}

fn checkBus(bus: u8)
{
	foreach (slot; 0 .. 32) {
		checkDevice(bus, cast(u8)slot);
	}
}

fn checkAllBuses()
{
	h: Header;

	if (!isValidDevice(0, 0, 0)) {
		return;
	}

	readHeader(0, 0, 0, ref h);
	if ((h.headerType & 0x80) == 0) {
		checkBus(0);
	} else {
		foreach (i; 0 .. 8) {
			func := cast(u8) i;

			if (!isValidDevice(0, 0, func)) {
				break;
			}
			checkBus(func);
		}
	}

	foreach (ref dev; info.devs[0 .. info.num]) {
		loadDevice(&dev);
	}
}


/*
 *
 * Reader functions.
 *
 */

fn readHeader(bus: u8, slot: u8, func: u8, ref h: Header)
{
	ptr := cast(u32*) &h;
	foreach (i; 0 .. 4) {
		ptr[i] = readU32(bus, slot, func, cast(u8) (i * 4));
	}
}

fn readU32(bus: u8, slot: u8, func: u8, offset: u8) u32
{
	address := cast(u32) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000_i32);
	outl(0xCF8, address);
	return inl(0xCFC);
}

fn readU16(bus: u8, slot: u8, func: u8, offset: u8) u16
{
	address := cast(u32) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000_i32);

	outl(0xCF8, address);
	shift: i32 = (offset & 2) * 8;
	read: i32 = cast(i32) inl(0xCFC);
	return cast(u16) (read >> shift);
}

fn readU8(bus: u8, slot: u8, func: u8, offset: u8) u8
{
	address := cast(u32) (
		(bus << 16) |
		(slot << 11) |
		(func << 8) |
		(offset & 0xfc) |
		0x80000000_i32);

	outl(0xCF8, address);
	shift: i32 = (offset & 3) * 8;
	read: i32 = cast(i32) inl(0xCFC);
	return cast(u8) (read >> shift);
}

fn dumpDevices()
{
	foreach (ref dev; info.devs[0 .. info.num]) {
		buf: char[8];
		buf[0] = valToHex(dev.bus >> 8u);
		buf[1] = valToHex(dev.bus      );
		buf[2] = ':';
		buf[3] = valToHex(dev.slot >> 8u);
		buf[4] = valToHex(dev.slot      );
		buf[5] = '.';
		buf[6] = valToHex(dev.func);
		buf[7] = ' ';

		write("pci: ");
		write(buf);
		writeHex(dev.vendor); write(" ");
		writeHex(dev.device); write(" class: ");
		writeHex(dev.baseClass); write(", sub: ");
		writeHex(dev.subClass); write(", header: ");
		writeHex(dev.headerType);

		cap := dev.cap;
		if (cap == 0) {
			writeln();
			continue;
		}

		write(", caps: ");
		foreach (i, name; CapNames) {
			bit := 1u << cast(u32)i;

			if (!(dev.cap & (1u << i))) {
				continue;
			}
			write(name);
			cap = cap & ~bit;
			if (cap) {
				write(" ");
			}
		}

		writeln();
	}
}
