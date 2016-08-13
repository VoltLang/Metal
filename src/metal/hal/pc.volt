// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Main module holding the hal for AMD64 PCs.
 */
module metal.hal.pc;

import arch.x86_64.ioports;
import arch.x86_64.interrupts;
import metal.drivers.serial;
import metal.hal.apic;

import l = metal.printer;
import acpi = metal.acpi;
import e820 = metal.e820;
import mb1 = metal.boot.multiboot1;
import mb2 = metal.boot.multiboot2;
import gfx = metal.gfx;
import pci = metal.pci;


/**
 * Main instance of the hal, defined as a variable so we can
 * store info here without having a working memory allocator.
 */
global hal: Hal;

/**
 * Holds all of the needed abstractions and information
 * for interfacing to a modern AMD64 PC.
 */
struct Hal
{
	rsdt: acpi.RSDT*;
	xsdt: acpi.XSDT*;

	multibootMagic: u32;
	multibootInfo: mb2.Info*;

	lAPIC: lAPICInfo;
	ioAPICnum: u32;
	ioAPIC: ioAPICInfo[4];
}

/**
 * Init the HAL.
 */
fn init(magic: u32, ptr: void*)
{
	l.writeln("serial: Setting up 0x03F8");
	com1.setup(0x03F8);

	l.ring.addSink(com1.sink);

	parseMultiboot(magic, ptr);
	parseACPI();

	initAPIC();

	pci.checkAllBuses();
}

/*
 *
 * APIC functions
 *
 */

/**
 * Inits and tests the local APIC.
 */
fn initAPIC()
{
	l.write("apic: Local APIC 0x");
	l.writeHex(hal.lAPIC.address);
	l.writeln();

	// Disable master and slave PICs.
	if (hal.lAPIC.hasPCAT) {
		l.writeln("apic: Disabling PC-AT PICs");

		outb(0xA1, 0xFF);
		outb(0x21, 0xFF);
	}

	// Set test handler.
	foreach (i; 0 .. 256u) {
		isr_stub_set(testAPIC, i);
	}

	// Load the IDT.
	idt_init();

	foreach (i; 0 .. hal.ioAPICnum) {
		maskIOAPIC(ref hal.ioAPIC[i]);
	}

	// Helper address
	lAPIC := cast(u8*)hal.lAPIC.address;

	l.writeln("apic: Enabling interrupts");

	// Enable us to receive interrupts
	svrPtr := cast(u32*)(lAPIC + 0x0F0);
	*svrPtr |= 0x100;

	idt_enable();

	// Send a IPI
	*cast(u32*)(lAPIC + 0x310) = 0x0000_0000;
	*cast(u32*)(lAPIC + 0x300) = 0x0004_4030;
}

/**
 * Mask a given IOAPIC.
 */
fn maskIOAPIC(ref ioAPIC: ioAPICInfo)
{
	addr := hal.ioAPIC[0].address;
	data := ioAPICRead(addr, 0x01);
	ver := 0xFF & data;
	max := (0xFF & (data >> 16)) + 1;

	l.write("apic: Masking IOAPIC, max: 0x");
	l.writeHex(cast(u8)max);
	l.writeln();

	foreach (i; 0 .. max) {
		low  := cast(u8)(0x10 + i * 2);
		high := cast(u8)(low + 1);
		ioAPICWrite(addr,  low, 0x00010000);
		ioAPICWrite(addr, high, 0x00000000);
	}
}

/**
 * Function to test of the Local APIC works.
 */
extern(C) fn testAPIC(state: IrqState*, vector: u64, void*)
{
	l.write("apic: IRQ 0x");
	l.writeHex(cast(u8)vector);
	l.writeln();

	if (vector == 0x30) {
		return;
	}

	l.write("       ds: "); l.writeHex(state.ds); l.writeln();
	l.write("      r15: "); l.writeHex(state.r15); l.writeln();
	l.write("      r14: "); l.writeHex(state.r14); l.writeln();
	l.write("      r13: "); l.writeHex(state.r13); l.writeln();
	l.write("      r12: "); l.writeHex(state.r12); l.writeln();
	l.write("      r11: "); l.writeHex(state.r11); l.writeln();
	l.write("      r10: "); l.writeHex(state.r10); l.writeln();
	l.write("       r9: "); l.writeHex(state.r9); l.writeln();
	l.write("       r8: "); l.writeHex(state.r8); l.writeln();
	l.write("      rsi: "); l.writeHex(state.rsi); l.writeln();
	l.write("      rdi: "); l.writeHex(state.rdi); l.writeln();
	l.write("      rbp: "); l.writeHex(state.rbp); l.writeln();
	l.write("      rdx: "); l.writeHex(state.rdx); l.writeln();
	l.write("      rcx: "); l.writeHex(state.rcx); l.writeln();
	l.write("      rbx: "); l.writeHex(state.rbx); l.writeln();
	l.write("      rax: "); l.writeHex(state.rax); l.writeln();
	l.write("errorCode: "); l.writeHex(state.errorCode); l.writeln();
	l.write("      rip: "); l.writeHex(state.rip); l.writeln();
	l.write("       cs: "); l.writeHex(state.cs); l.writeln();
	l.write("   rflags: "); l.writeHex(state.rflags); l.writeln();
	l.write("      rsp: "); l.writeHex(state.rsp); l.writeln();
	l.write("       ss: "); l.writeHex(state.ss); l.writeln();

	lAPIC := cast(u8*)hal.lAPIC.address;
	*cast(u32*)(lAPIC + 0x0B0) = 0x0;
}


/*
 *
 * Parsing functions.
 *
 */

/**
 * Setup various devices and memory from multiboot information.
 */
fn parseMultiboot(magic: u32, ptr: void*)
{
	l.write("mb: ");
	l.writeHex(magic);
	l.write(" ");
	l.writeHex(cast(size_t)ptr);
	l.writeln("");

	hal.multibootMagic = magic;
	if (magic == mb1.MAGIC) {
		return parseMultiboot1(cast(mb1.Info*)ptr);
	} else if (magic == mb2.MAGIC) {
		hal.multibootInfo = cast(mb2.Info*)ptr;
		return parseMultiboot2(hal.multibootInfo);
	}
}

fn parseMultiboot1(info: mb1.Info*)
{
	acpi.findX86(out hal.rsdt, out hal.xsdt);

	if (info.flags & mb1.Info.Flags.Mmap) {
		e820.fromMultiboot1(info);
	}
}

fn parseMultiboot2(info: mb2.Info*)
{
	mmap: mb2.TagMmap*;
	fb: mb2.TagFramebuffer*;
	oldACPI: mb2.TagOldACPI*;
	newACPI: mb2.TagNewACPI*;

	// Frist search the tags for the mmap tag.
	tag := cast(mb2.Tag*)&info[1];
	while (tag.type != mb2.TagType.END) {
		switch (tag.type) with (mb2.TagType) {
		case MMAP:
			mmap = cast(typeof(mmap))tag;
			break;
		case FRAMEBUFFER:
			fb = cast(typeof(fb))tag;
			break;
		case ACPI_OLD:
			oldACPI = cast(typeof(oldACPI))tag;
			break;
		case ACPI_NEW:
			newACPI = cast(typeof(newACPI))tag;
			break;
		default:
		}

		// Get new address and align.
		addr := cast(size_t)tag + tag.size;
		if (addr % 8) {
			addr += 8 - addr % 8;
		}
		tag = cast(mb2.Tag*)addr;
	}

	if (oldACPI !is null && newACPI is null) {
		hal.rsdt = cast(typeof(hal.rsdt)) oldACPI.rsdp.rsdtAddress;
	} else if (newACPI !is null) {
		hal.rsdt = cast(typeof(hal.rsdt)) newACPI.rsdp.v1.rsdtAddress;
		hal.xsdt = cast(typeof(hal.xsdt)) newACPI.rsdp.xsdtAddress;
	} else {
		acpi.findX86(out hal.rsdt, out hal.xsdt);
	}

	if (mmap !is null) {
		e820.fromMultiboot2(mmap);
	}

	if (fb !is null) {
		gfx.info.ptr = cast(void*)fb.framebuffer_addr;
		gfx.info.pitch = fb.framebuffer_pitch;
		gfx.info.w = fb.framebuffer_width;
		gfx.info.h = fb.framebuffer_height;
		gfx.info.pixelOffX = 8;
		gfx.info.pixelOffY = 8;
		gfx.info.installSink();
	}
}

/**
 * Prase the needed info from the ACPI tables
 * and save the information on the hal struct.
 */
fn parseACPI()
{
	rsdt := hal.rsdt;
	xsdt := hal.xsdt;

	if (xsdt !is null) {
		acpi.dump(&xsdt.h);
		foreach (a; xsdt.array) {
			h := cast(acpi.Header*)a;
			switch (h.signature[..]) {
			case "APIC": parseMADT(h); break;
			default: acpi.dump(h); break;
			}
		}
	} else if (rsdt !is null) {
		acpi.dump(&rsdt.h);
		foreach (a; rsdt.array) {
			h := cast(acpi.Header*)a;
			switch (h.signature[..]) {
			case "APIC": parseMADT(h); break;
			default: acpi.dump(h); break;
			}
		}
	}
}

/**
 * Parse the APIC information from the MADT and
 * save the info in the hal struct.
 */
fn parseMADT(mdat: acpi.Header*)
{
	acpi.dump(mdat);

	ptr := cast(u8*)(mdat);
	end := cast(u8*)(ptr + mdat.length);

	{
		// Local Interrupt Controller Address.
		address := *cast(u32*)(ptr + 0x24);
		// Flags.
		flags := *cast(u32*)(ptr + 0x28);
		// Extracted flags.
		hasPCAT := (1 & flags) != 0;

		l.write("acpi: APIC lAPIC addr: ");
		l.writeHex(address);
		l.write(hasPCAT ? ", PCAT_COMPAT" : "");
		l.writeln();

		hal.lAPIC.address = address;
		hal.lAPIC.hasPCAT = hasPCAT;
	}

	ptr += 0x2C;
	while (cast(size_t)ptr < cast(size_t)end) {
		type := ptr[0];
		len := ptr[1];

		switch (type) {
		// Processor Local APIC
		case 0:
			// ACPI Processor ID.
			acpiID := *(ptr + 2);
			// Processor's local APIC ID.
			apicID := *(ptr + 3);
			// Flags
			flags := *cast(u32*)(ptr + 4);
			// Extracted
			enabled := (1 & flags) != 0;

			l.write("acpi: APIC 0x00  acpiID: ");
			l.writeHex(acpiID);
			l.write(", apicID: ");
			l.writeHex(apicID);
			l.write(enabled ? ", enabled" : ", disabled");
			l.writeln();
			break;

		// I/O APIC Structure
		case 1:
			// I/O APIC's ID.
			apicID := *(ptr + 2);
			// I/O APIC adress
			address := *cast(u32*)(ptr + 4);
			// Global System Interrupt Base.
			gsiBase := *cast(u32*)(ptr + 8);

			l.write("acpi: APIC 0x01  apicID: ");
			l.writeHex(apicID);
			l.write(", address: ");
			l.writeHex(address);
			l.write(", gsiBase: ");
			l.writeHex(gsiBase);
			l.writeln();

			ioAPIC := &hal.ioAPIC[hal.ioAPICnum++];
			ioAPIC.address = address;
			ioAPIC.gsiBase = gsiBase;

			break;

		// Interrupt Source Override Structure
		case 2:
			// Bus
			bus := *(ptr + 2);
			// Bus-relative interrupt source
			source := *(ptr + 3);
			// Global System Interrupt
			gis := *cast(u32*)(ptr + 4);
			// Flags
			flags := *cast(u16*)(ptr + 8);
			// Polarity of the APIC I/O input signal
			polarity := cast(u8)(flags & 0x03);
			// Trigger mode of the AIC I/O Unput signal
			triggerMode := cast(u8)((flags >> 2) & 0x03);

			l.write("acpi: APIC 0x02  bus: ");
			l.writeHex(bus);
			l.write(", source: ");
			l.writeHex(source);
			l.write(", gis: ");
			l.writeHex(gis);
			l.write(", polarity: ");
			l.writeHex(polarity);
			l.write(", triggerMode: ");
			l.writeHex(triggerMode);
			l.writeln();
			break;

		// Local APIC NMI Structure
		case 4:
			// ACPI Processor ID.
			acpiID := *(ptr + 2);
			// Flags.
			flags := *cast(u16*)(ptr + 3);
			// Local APIC interrupt input LINTn to which NMI is connected.
			lint := *(ptr + 5);
			// Polarity of the APIC I/O input signal
			polarity := cast(u8)(flags & 0x03);
			// Trigger mode of the AIC I/O Unput signal
			triggerMode := cast(u8)((flags >> 2) & 0x03);

			l.write("acpi: APIC 0x04  acpiID: ");
			l.writeHex(acpiID);
			l.write(", lLINT#: ");
			l.writeHex(lint);
			l.write(", polarity: ");
			l.writeHex(polarity);
			l.write(", triggerMode: ");
			l.writeHex(triggerMode);
			l.writeln();
			break;

		default:
			l.write("acpi: APIC 0x");
			l.writeHex(type);
			l.write("  unknown");
			l.writeln();
			break;
		}

		ptr += len;
	}
}
