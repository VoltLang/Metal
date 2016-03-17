; Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
; See copyright notice in LICENSE.txt (BOOST ver. 1.0).
[global start32]

extern boot_main
extern metal_main

%define PAGING_NUM_PD		4
%define PAGING_PML4_FLAGS	((1 << 2) | (1 << 1) | (1 << 0))
%define PAGING_PDP_FLAGS	((1 << 2) | (1 << 1) | (1 << 0))
%define PAGING_PD_FLAGS		((1 << 7) | (1 << 3) | (1 << 2) | (1 << 1) | (1 << 0))


section .boot_text
bits 32
align 16
start32:
; Setup stack and save pointer and magic
	mov esp, stack_top
	push ebx
	push eax
	cld

; Setup PML4
	mov edi, boot_PML4
	mov eax, boot_PDP + PAGING_PML4_FLAGS
	stosd
	xor eax, eax
	stosd

	; Setup PDP
	mov ecx, PAGING_NUM_PD
	mov edi, boot_PDP
	mov ebx, boot_PD + PAGING_PDP_FLAGS
loop_pdp:
	mov eax, ebx
	stosd
	xor eax, eax
	stosd
	add ebx, 0x00001000
	dec ecx
	cmp ecx, 0
	jne loop_pdp

	; Setup DPs
	mov ecx, PAGING_NUM_PD * 512
	mov edi, boot_PD
	mov ebx, 0x00000000 + PAGING_PD_FLAGS
loop_pd:
	mov eax, ebx
	stosd
	xor eax, eax
	stosd
	pop eax
	add ebx, 0x00200000
	dec ecx
	cmp ecx, 0
	jne loop_pd

	; Done building the tables.
	lgdt [gdt64.pointer]

	mov eax, cr4
	or eax, 0x0000000B0
	mov cr4, eax

	mov eax, boot_PML4 + 0x08
	mov cr3, eax

	mov ecx, 0xC0000080
	rdmsr
	or eax, (1 << 8) | (1 << 0);
	wrmsr

	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	jmp gdt64.code:start64

bits 64
start64:
	mov ax, 0x0010
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov gs, ax

	; This code is needed to get us out of compatibility mode.
	mov rax, start64_nocompat
	jmp rax
	nop
start64_nocompat:
	lgdt [gdt64.pointer]

	; Now setup the enviroment to call C and Volt code.
	mov rsp, stack_top - 8 ; Multiboot magic and pointer has been saved.

	; Get the multiboot magic and pointer from stack.
	pop rdi ; magic
	mov rsi, rdi
	mov eax, 0xFFFFFFFF
	and rdi, rax
	shr rsi, byte 0x20

	; Call this function.
	; void boot_main(int magic, void* info)
	push rdi
	push rsi
	call boot_main

	; Call this function.
	; void metal_main(int magic, void* info)
	pop rsi ; ptr
	pop rdi ; magic
	call metal_main

	; Disable interupts and hang
	cli
hang:
	hlt
	jmp hang


; GDT for 64bit mode
align 16
gdt64:
	dw 0                         ; Limit (low).
	dw 0                         ; Base (low).
	db 0                         ; Base (middle)
	db 0                         ; Access (exec/read).
	db 0                         ; Granularity.
	db 0                         ; Base (high).
.code equ $-gdt64
	dw 0                         ; Limit (low).
	dw 0                         ; Base (low).
	db 0                         ; Base (middle)
	db 10011010b                 ; Access (exec/read).
	db 00100000b                 ; Granularity.
	db 0                         ; Base (high).
.data equ $-gdt64
	dw 0                         ; Limit (low).
	dw 0                         ; Base (low).
	db 0                         ; Base (middle)
	db 10010010b                 ; Access (read/write).
	db 00000000b                 ; Granularity.
	db 0                         ; Base (high).
.pointer:
	dw $ - gdt64 - 1
	dq gdt64


section .bss
align 4096
boot_PML4:
resb 4096
boot_PDP:
resb 4096
boot_PD:
resb PAGING_NUM_PD * 4096

stack_bottom:
resb 16384
stack_top:
