
# Graphics

The goal of this documentation is doing `linear` graphics without having to
talk the `BIOS` via the `VBE` interface. Preferedly with as few as possible
mode switches (switchless boot).

### Definitions

`GRUB` = Bootloader on x86-x86_64  
`EFI`= Extensible Firmware Interface  
`VESA` = Video Electronics Standards Association  
`VGA` = Video graphics adaptor  
`VBE` = `VESA` `BIOS` Extensions.  
`stdvga` = QEMU standard vga device  
`BGA` = Bochs Graphics Adaptor  
`QXL` = Paravirtualized framebuffer device, used with spice protocol.  

### Asking GRUB

The easist is if you are using `GRUB` you can just ask it for a linear mode. Setting width and height to `0` will leave the `EFI`/`BIOS` mode in place (if it is linear), giving you switchless.

### Virtual graphics

There are several virtual grahpics card, none exhaustive list: `VMware SVGA`,
`stdvga`, `BGA`, `QXL`. Qemu supports all of these tho the VMware SVGA
support is very limited.

Luckily for us `stdvga` is backwards compatible with `BGA`.

### Real hardware

This is hard :(

### More reading

[QEMU stdandard vga spec](https://github.com/qemu/qemu/blob/master/docs/specs/standard-vga.txt)  
[How to talk to the `BGA`](http://wiki.osdev.org/Bochs_Graphics_Adaptor)  
