; Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
; See copyright notice in LICENSE.txt (BOOST ver. 1.0).
[BITS 32]
[global outb]
[global outl]
[global inb]
[global inl]


align 4
inb:
	push ebp
	mov ebp, esp
	movzx edx, word [ebp+0x8]
	in al, dx
	movzx eax, al
	pop ebp
	ret

inl:
	push ebp
	mov ebp, esp
	movzx edx, word [ebp+0x8]
	in eax, dx
	pop ebp
	ret

outb:
	push ebp
	mov ebp, esp
	movzx edx, word [ebp+0x8]
	mov al, [ebp+0xc]
	out dx, al
	pop ebp
	ret

outl:
	push ebp
	mov ebp, esp
	movzx edx, word [ebp+0x8]
	mov eax, [ebp+0xc]
	out dx, eax
	pop ebp
	ret
