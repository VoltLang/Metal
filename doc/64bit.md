---
layout: page
title: 64bit
---

# 64bit

### Definitions

`LMA` = Load address  
`VMA` = Virtual address  
`elf-binary` = Binary in elf format, with reallocations not applied  
`bin-binary` = Raw binary, with all reallocations applied


### Directives

`AT` = Set LMA  
`ADDR` = Return VMA of given section  
`SIZEOF` = Size of given section  


### LVM, VMA and AT

Understanding LMA and VMA, and the AT directive. In short AT allows us to disconnect where in the bin-binary or physical memory they end up and where in memory the code think it is.

https://sourceware.org/binutils/docs/ld/Output-Section-LMA.html  
https://sourceware.org/binutils/docs/ld/Overlay-Description.html


### Futher reading

http://wiki.osdev.org/Creating_a_64-bit_kernel

