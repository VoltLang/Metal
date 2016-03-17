
CSRC = \
	src/boot/boot.c

ASMSRC = \
	src/arch/x86_64/ioports.asm \
	src/boot/switch.asm \
	src/boot/multiboot.asm

VOLTSRC = \
	src/arch/x86/ioports.volt \
	src/metal/drivers/serial.volt \
	src/metal/drivers/bochs.volt \
	src/metal/boot/multiboot1.volt \
	src/metal/boot/multiboot2.volt \
	src/metal/printer.volt \
	src/metal/pci.volt \
	src/metal/gfx.volt \
	src/metal/e820.volt \
	src/metal/stdc.volt \
	src/metal/vrt.volt \
	src/metal/main.volt
