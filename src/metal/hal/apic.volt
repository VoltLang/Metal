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
