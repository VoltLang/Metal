
CSRC = \
	src/boot/boot.c

ASMSRC = \
	src/arch/x86_64/ioports.asm \
	src/arch/x86_64/interrupts.asm \
	src/boot/switch.asm \
	src/boot/multiboot.asm

VOLTSRC = \
	src/arch/x86/*.volt \
	src/metal/drivers/*.volt \
	src/metal/boot/*.volt \
	src/metal/hal/*.volt \
	src/metal/*.volt
