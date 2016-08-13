// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Functions and variables for the interrupt assembly file.
 */
module arch.x86_64.interrupts;


alias IrqFn = fn!C (state: IrqState*, vector: u64, void*);

struct IrqState
{
	ds: u64;
	r15: u64;
	r14: u64;
	r13: u64;
	r12: u64;
	r11: u64;
	r10: u64;
	r9: u64;
	r8: u64;
	rsi: u64;
	rdi: u64;
	rbp: u64;
	rdx: u64;
	rcx: u64;
	rbx: u64;
	rax: u64;
	errorCode: u64;
	rip: u64;
	cs: u64;
	rflags: u64;
	rsp: u64;
	ss: u64;
}

extern(C) fn idt_init();
extern(C) fn idt_enable();
extern(C) fn idt_disable();
extern(C) fn idt_get(vector: u64) u64*;
extern(C) fn idt_set(offset: void*, vector: u64);
extern(C) fn isr_stub_set(irqFunc: IrqFn, vec: u64);
