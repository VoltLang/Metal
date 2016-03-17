; Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
; See copyright notice in LICENSE.txt (BOOST ver. 1.0).
[BITS 64]
[global outb]
[global outw]
[global outl]
[global inb]
[global inw]
[global inl]


align 4
inb:
	push rbp
	mov rbp,rsp
	mov dx,di
	in al,dx
	movzx eax,al
	pop rbp
	ret

inw:
	push rbp
	mov rbp,rsp
	mov dx,di
	in ax,dx
	movzx eax,ax
	pop rbp
	ret

inl:
	push rbp
	mov rbp,rsp
	mov dx,di
	in eax,dx
	pop rbp
	ret

outb:
	push rbp
	mov rbp,rsp
	mov al,sil
	mov dx,di
	out dx,al
	pop rbp
	ret

outw:
	push rbp
	mov rbp,rsp
	mov ax,si
	mov dx,di
	out dx,ax
	pop rbp
	ret

outl:
	push rbp
	mov rbp,rsp
	mov eax,esi
	mov dx,di
	out dx,eax
	pop rbp
	ret
