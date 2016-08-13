// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in LICENSE.txt (BOOST ver. 1.0).
/**
 * Functions and variables for the interrupt assembly file.
 */
module arch.x86_64.interrupts;


alias IrqFn = fn!C (void*, vec: u64, void*);

extern(C) fn idt_init();
extern(C) fn idt_enable();
extern(C) fn idt_disable();
extern(C) fn idt_get(vector: u64) u64*;
extern(C) fn idt_set(offset: void*, vector: u64);
extern(C) fn isr_stub_set(irqFunc: IrqFn, vec: u64);
