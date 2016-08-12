; Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
; See copyright notice in LICENSE.txt (BOOST ver. 1.0).
[global idt_set]
[global isr_set]
[global isr_functions]
bits 64

section .data
align 16
idt64:
.size:
	dw 0
.pointer:
	dq 0


section .text
align 16
idt_set:
	mov	[idt64.pointer], rdi
	mov	[idt64.size], si
	lidt	[idt64]
	ret


align 16
isr_set:
	mov	rax, isr_functions
	mov	[rax + rdi * 8], rsi
	ret


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



section .bss

align 8
isr_functions:
	resb 8 * 256
