// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).

#define DEBUG_SERIAL

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

#define SECTION __attribute__ ((section (".boot_text")))

extern u8 inb(u16);
extern u8 inw(u16);
extern u8 inl(u16);
extern void outb(u16, u8);
extern void outw(u16, u16);
extern void outl(u16, u32);

#ifdef DEBUG_SERIAL
static SECTION void boot_serial_init();
static SECTION void boot_serial_print(const char* str);
static SECTION char hello[] = "Boot Metal\n";
#else
#define boot_serial_init() do { } while(0) 
#define boot_serial_print(x) do { } while(0)
#endif


SECTION void boot_main()
{
	boot_serial_init();
	boot_serial_print(hello);
}


#ifdef DEBUG_SERIAL

#define OFF(x) (x + 0x03F8)
#define SERIAL_EMPTY ((inb(OFF(5)) & 0x20) != 0)

void boot_serial_print(const char* str)
{
	while (*str) {
		while (!SERIAL_EMPTY) {}
		outb(OFF(0), *str);
		str++;
	}
}

void boot_serial_init()
{
	outb(OFF(1), 0x00);    // Disable all interrupts
	outb(OFF(3), 0x80);    // Enable DLAB (set baud rate divisor)
	outb(OFF(0), 0x01);    // Set divisor to 1 (lo byte) 115200 baud
	outb(OFF(1), 0x00);    //                  (hi byte)
	outb(OFF(3), 0x03);    // 8 bits, no parity, one stop bit
	outb(OFF(2), 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
	outb(OFF(4), 0x0B);    // IRQs enabled, RTS/DSR set
}
#endif
