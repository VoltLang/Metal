/* Both are needed, because elf32-i386 means x86_64 on a 64bit machine */
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH("i386")
ENTRY(_start)

SECTIONS
{
	. = 1M;
	.text : {
		*(.multiboot)
		*(.text)
		. = ALIGN(4K);
	}
	.data : {
		*(.data)
		. = ALIGN(4K);
		*(.rodata)
		. = ALIGN(4K);
		__data_end = .;
	}
	.bss : {
		*(.bss);
		__bss_end = .;
	}
}
