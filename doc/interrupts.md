
# Interrupts

This page is ment to detail setting up interup thandling use "modern" devices
on x86 64bit. For that we are using ACPI tables the IO-APIC and the local APIC.

### Definitions

`APIC` Advanced Configuration and Power Interface  
`GIS` Global System Interrupt  
`IOAPIC` I/O Advanced Programmable Interrupt Controller  
`local APIC` local Advanced Programmable Interrupt Controller  
`MDAT` Multiple APIC Description Table   

### Prerequisite

The knowlage of what a IRQ is. A way to run code in 64bit. Able to find ACPI
tables, a AML interpreter is not required right now.

### Legacy ISA interrupts

The 16 legacy ISA interupts are mapped to first 16 GIS. By default these are
edge triggered[^1][1]. Inside of the MADT table there can be overrides for
these 16 interrupts. On QEMU some of the remappings are only there to change
the trigger mode from edge to level.

### GIS Global System Interrupts

Global System Interrupts are virtual interrupt numbers, verious ACPI tables
refere to these numbers. IOAPICs are mapped into the GIS, the information for
that can be found in the MDAT table and the IOAPIC.

### Futher reading

http://forum.osdev.org/viewtopic.php?t=11379
https://en.wikipedia.org/wiki/Intel_8259#Spurious_Interrupts

[1]: https://en.wikipedia.org/wiki/Intel_8259#Edge_and_level_triggered_modes
