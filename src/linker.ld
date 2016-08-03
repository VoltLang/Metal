/* Both are needed, because elf32-i386 means x86_64 on a 64bit machine */
OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH("i386:x86-64")
ENTRY(_start)

SECTIONS
{
	. = 1048576;
	.text : {
		*(.boot_header)
		*(.boot_text)
		*(.text)
	}
	. = ALIGN(4096);
	.data : {
		*(.data)
		*(.data.*)
	}
	.rodata : {
		*(.rodata)
		*(.rodata.*)
	}
	PROVIDE(__data_end = .);
	. = ALIGN(4096);
	.bss : {
		*(.bss)
	}
	PROVIDE(__bss_end = .);
}
