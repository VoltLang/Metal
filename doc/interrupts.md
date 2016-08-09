
# Interrupts

This page is ment to detail setting up interup thandling use "modern"
devices on x86 64bit. For that we are using ACPI tables the IO-APIC
and the local APIC.

### Definitions

`APIC` Advanced Configuration and Power Interface  
`GIS` Global System Interrupt  
`local APIC`  
`IOAPIC`  
`MDAT`  

### Prerequisite

The knowlage of what a IRQ is. A way to run code in 64bit. Able
to find ACPI tables, a AML interpreter is not required right now.

### Legacy ISA interrupts

The 16 legacy ISA interupts are mapped to first 16 GIS. By default
these are level triggered[^1][1].

### GIS Global System Interrupts

Global System Interrupts are virtual interupt numbers, verious ACPI
tables refere to these numbers. IOAPIC's are mapped into these,
the information for that can be found in the MDAT table.

### Futher reading

[1]: https://en.wikipedia.org/wiki/Intel_8259#Edge_and_level_triggered_modes
http://forum.osdev.org/viewtopic.php?t=11379
https://en.wikipedia.org/wiki/Intel_8259#Spurious_Interrupts
