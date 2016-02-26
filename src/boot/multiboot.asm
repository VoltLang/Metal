[BITS 32]
[global _start]

%define FLAG_ALIGN 		1<<0
%define FLAG_MEMINFO		1<<1
%define FLAG_AOUT_KLUDGE	1<<16

%define MAGIC			0x1BADB002

%define FLAGS			(FLAG_AOUT_KLUDGE | FLAG_ALIGN | FLAG_MEMINFO)
%define CHECKSUM		-(MAGIC + FLAGS)


; We put this in its own section so that along with a linker script
; we are certain that it ends up at the start of the binary.
section .multiboot
_start:
	xor eax, eax
	xor ebx, ebx
	jmp multiboot_entry

align 4

multiboot_header:
	dd MAGIC
	dd FLAGS
	dd CHECKSUM
	dd multiboot_header
	dd _start
	dd 0x00
	dd 0x00
	dd multiboot_entry

align 16

multiboot_entry:
	; Setup this stack
	mov esp, stack_top

	; Call this function.
	; void metal_main(int magic, void* info)
	extern metal_main
	push ebx
	push eax
	call metal_main

	; Disable interupts and hang
	cli
multiboot_hang:
	hlt
	jmp multiboot_hang


section .bss
align 4
stack_bottom:
resb 16384
stack_top:
