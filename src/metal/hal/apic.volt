// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Main module holding the hal for AMD64 PCs.
 */
module metal.hal.apic;

/**
 * Holds info about the processor local APIC.
 */
struct lAPICInfo
{
	address: u32;
	hasPCAT: bool;
}

/**
 * Holds information about a signle I/O APIC.
 */
struct ioAPICInfo
{
	address: u32;
	gsiBase: u32;
}

fn ioAPICWrite(apic_base: const size_t, offset: const u8, val: const u32)
{
	/* tell IOREGSEL where we want to write to */
	*cast(u32*)(apic_base) = offset;
	/* write the value to IOWIN */
	*cast(u32*)(apic_base + 0x10) = val;
}

fn ioAPICRead(apic_base: const size_t, offset: const u8) u32
{
	/* tell IOREGSEL where we want to read from */
	*cast(u32*)(apic_base) = offset;
	/* return the data from IOWIN */
	return *cast(u32*)(apic_base + 0x10);
}
