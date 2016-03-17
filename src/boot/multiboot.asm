[BITS 32]
[global _start]

extern __data_end
extern __bss_end

; We put this in its own section so that along with a linker script we are
; certain that it ends up at the start of the binary.
section .boot_header
_start:
	xor eax, eax
	xor ebx, ebx
	jmp multiboot_entry



; What follows here is a complete multiboot1 header.
; This header uses AOUT aka binary flags.

%define FLAG_ALIGN 		1<<0
%define FLAG_MEMINFO		1<<1
%define FLAG_AOUT_KLUDGE	1<<16

%define MULTIBOOT1_MAGIC	0x1BADB002
%define MULTIBOOT1_FLAGS	(FLAG_AOUT_KLUDGE | FLAG_ALIGN | FLAG_MEMINFO)
%define MULTIBOOT1_CHECKSUM	-(MULTIBOOT1_MAGIC + MULTIBOOT1_FLAGS)

align 4
multiboot1_header:
	dd MULTIBOOT1_MAGIC
	dd MULTIBOOT1_FLAGS
	dd MULTIBOOT1_CHECKSUM
	dd multiboot1_header
	dd _start
	dd __data_end
	dd __bss_end
	dd multiboot_entry
multiboot1_end:


; What follows here is a complete multiboot2 header.
; This header like the one above it use binary form.
; We define two headers in order for both qemu -kernel
; argument and grub2 with multiboot2 directive to work.

%define MULTIBOOT2_MAGIC	0xe85250d6
%define MULTIBOOT2_ARCH		0x00
%define MULTIBOOT2_LENGTH	(multiboot2_end - multiboot2_header)
%define MULTIBOOT2_CHECKSUM	(0x100000000 - (MULTIBOOT2_MAGIC + MULTIBOOT2_ARCH + MULTIBOOT2_LENGTH))

align 64
multiboot2_header:
	dd MULTIBOOT2_MAGIC
	dd MULTIBOOT2_ARCH
	dd MULTIBOOT2_LENGTH
	dd MULTIBOOT2_CHECKSUM

; address tag
	align 8
	dw 2
	dw 0x00
	dd (8 + 4 + 4 + 4 + 4)
	dd multiboot2_header
	dd _start
	dd __data_end
	dd __bss_end

; entry tag
	align 8
	dw 3
	dw 0x00
	dd (8 + 4)
	dd multiboot_entry

; framebuffer tag
	align 8
	dw 5
	dw 0x00
	dd (8 + 4 + 4 + 4)
	dd 0
	dd 0
	dd 32

; end tag
	align 8
	dw 0x00
	dw 0x00
	dd 8
multiboot2_end:



; Short bootstrap code to setup the stack and jump to metal_main function.

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
