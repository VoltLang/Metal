[BITS 32]
[global _start]

FLAG_ALIGN		equ 1<<0
FLAG_MEMINFO		equ 1<<1
FLAG_AOUT_KLUDGE	equ 1<<16

MAGIC			equ 0x1BADB002

FLAGS			equ FLAG_AOUT_KLUDGE | FLAG_ALIGN | FLAG_MEMINFO
CHECKSUM		equ -(MAGIC + FLAGS)

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
