/* Both are needed, because elf32-i386 means x86_64 on a 64bit machine */
OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH("i386:x86-64")
ENTRY(_start)

SECTIONS
{
	. = 1048576;
	.boot_header : { *(.boot_header) }
	.boot_text : { *(.boot_text) }
	.text : { *(.text) }

	/*
	 * The different data sections might have different alignments so
	 * we need to put them seperatetly in the binary.
	 */
	. = ALIGN(4096);
	.data : { *(.data) }
	.rodata : { *(.rodata) }
	.rodata.str1.16 : { *(.rodata.str1.16) }
	.rodata.str1.1 : { *(.rodata.str1.1) }
	.gcc_except_table : { *(.gcc_except_table) }

	/*
	 * The symbol most be exactly at the end of the data sections
	 * or the symbol might point outside of the final binary.
	 */
	PROVIDE(__data_end = .);

	. = ALIGN(4096);
	.bss : {
		*(.bss)
	}

	PROVIDE(__bss_end = .);

	/*
	 * These sections are not flagged with alloc so
	 * they are ignored objcopy, so put these after the bss.
	 */
	.debug_str : { *(.debug_str) }
	.debug_loc : { *(.debug_loc) }
	.debug_abbrev : { *(.debug_abbrev) }
	.debug_info : { *(.debug_info) }
	.debug_macinfo : { *(.debug_macinfo) }
	.debug_pubnames : { *(.debug_pubnames) }
	.debug_pubtypes : { *(.debug_pubtypes) }
	.debug_line : { *(.debug_line) }
	.debug_aranges : { *(.debug_aranges) }
	.debug_frame : { *(.debug_frame) }
	.comment : { *(.comment) }

	/*
	 * Discard all other senctions.
	 *
	 * Including among other .eh_frame, because right now
	 * we don't use exceptions in metal. So the .eh_frame
	 * section is not needed. LD discards this but not lld
	 * unless we are explicit.
	 */
	/DISCARD/ : { *(*) }
}
