; Copyright © 2015-2016, Alexandru-Mihai Maftei for ISR_STUB_* code, rights reserved;
; Relicensed as the rest to BOOST ver. 1.0 (in LICENSE.txt)
; Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
; See copyright notice in LICENSE.txt (BOOST ver. 1.0).
[global idt_init]
[global idt_init]
[global idt_enable]
[global idt_disable]
[global idt_get]
[global idt_set]
[global isr_stub_set]
bits 64
section .text

; Enables interrupts
; Ret. N/A - Nothing.
align 16
idt_enable:
	sti
	ret


; Disables interrupts
; Ret. N/A - Nothing.
align 16
idt_disable:
	cli
	ret


; Sets the idt to the inbuilt table and enables interrupts.
; Ret. N/A - Nothing.
align 16
idt_init:
	mov	qword [idt64.pointer], idt_table
	mov	word [idt64.size], 256*16-1
	lidt	[idt64]
	ret


; Returns a pointer to the idt_entry at the given vector.
;   1. RSI - The vector to return.
; Ret. RAX - A pointer to the entry.
align 16
idt_get:
	shl	rdi, 0x4
	mov	rax, idt_table
	add	rax, rdi
	ret


; Sets the offset, segment and type_attr fields on a vector in the IDT.
; By default sets type_attr to 0x8f00 and segment to 0x0010.
;   1. RSI - The offset to set.
;   2. RDI - The vector to set.
; Ret. N/A - Nothing.
align 16
idt_set:
	shl	rsi, 0x4
	mov	word [rsi+idt_table], di
	mov	word [rsi+idt_table+0x2], 0x0008
	and	rdi, 0xffffffffffff0000
	or	rdi, 0x8e00
	mov	qword [rsi+idt_table+0x4], rdi
	ret


; Sets up a stub and the idt entry for vector.
; By default sets type_attr to 0x8f00 and segment to 0x1000
;   1. RSI - The function which the stub should call.
;   2. RDI - The vector to set.
; Ret. N/A - Nothing.
align 16
isr_stub_set:
	mov	rax, isr_functions
	mov	[rax + rsi * 8], rdi
	mov	rdi, isr_stub_0
	mov	rax, rsi
	shl	rax, 0x4
	add	rdi, rax
	jmp	idt_set


; Stub that saves all of registers and calls the correct function.
align 16
isr_stub:
	; Store general-purpose registers, except RAX as
	; it was pushed by the initial stub.
	push	rbx
	push	rcx
	push	rdx
	push	rbp
	push	rdi
	push	rsi
	push	r8
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15

	; Make the stack pointer the first parameter.
	mov     rdi, rsp

	; The base pointer has to be 0, so the interrupt handler's
	; stack frames do not link to the userland frames.
	mov	ebp, 0

	; Make the vector number the second parameter.
	mov	rsi, rax

	; Get the handler and set it as the third parameter.
	mov	rdx, isr_functions
	mov	rdx, [rdx + rax * 8]

	; At this point, the arguments given are the following:
	; 1. RDI = State pointer
	; 2. RSI = Vector
	; 3. RDX = Handler function pointer
	; Call handler. Preserves RBP by convention.
	call	rdx

	; Restore the same general-purpose registers.
	; Including RAX as it was pushed by the initial stub.
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rsi
	pop	rdi
	pop	rbp
	pop	rdx
	pop	rcx
	pop	rbx
	pop     rax

	; "Pop" error code.
	add     rsp, 8

	; Interrupt is now done.
	iretq


%macro ISR_STUB 1
	isr_stub_%1:
		push	qword 0
		push	rax
		mov	eax, %1
        	jmp	isr_stub
	align 16
%endmacro

%macro ISR_STUB_ERR 1
	isr_stub_%1:
		push	rax
		mov	eax, %1
		jmp	isr_stub
	align 16
%endmacro


align 16
isr_stubs_start:

	ISR_STUB       0
	ISR_STUB       1
	ISR_STUB       2
	ISR_STUB       3
	ISR_STUB       4
	ISR_STUB       5
	ISR_STUB       6
	ISR_STUB       7
	ISR_STUB_ERR   8
	ISR_STUB       9
	ISR_STUB_ERR   10
	ISR_STUB_ERR   11
	ISR_STUB_ERR   12
	ISR_STUB_ERR   13
	ISR_STUB_ERR   14
	ISR_STUB       15
	ISR_STUB       16
	ISR_STUB       17
	ISR_STUB       18
	ISR_STUB       19
	ISR_STUB       20
	ISR_STUB       21
	ISR_STUB       22
	ISR_STUB       23
	ISR_STUB       24
	ISR_STUB       25
	ISR_STUB       26
	ISR_STUB       27
	ISR_STUB       28
	ISR_STUB       29
	ISR_STUB       30
	ISR_STUB       31

	%assign i 32
	%rep (256-32)
		ISR_STUB i
		%assign i i+1
	%endrep

isr_stubs_end:



section .data

align 16
idt64:
.size:
	dw 0
.pointer:
	dq 0



section .bss

align 16
isr_functions:
	resb 8 * 256

align 16
idt_table:
	resb 16 * 256
