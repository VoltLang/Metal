
LD ?= ld
VOLT ?= volt
NASM ?= nasm
CLANG ?= clang
QEMU ?= qemu-system-x86_64
OUTDIR ?= .obj
NASMFLAGS ?= -f elf32 -g3 -F dwarf
CFLAGS ?= -g --target=i686-pc-none-elf -march=i686
VFLAGS ?= -d --platform metal --arch x86
LDFLAGS ?= -n -T src/linker.ld --gc-sections

METAL_ELF ?= metal.elf
METAL_BIN ?= metal.bin
METAL_ISO ?= metal.iso

all: $(METAL_BIN)

CSRC =
ASMSRC = src/boot/multiboot.asm
VOLTSRC = src/metal/main.volt src/metal/vga.volt
COBJ = $(patsubst src/%.c, $(OUTDIR)/%.c.o, $(CSRC))
ASMOBJ = $(patsubst src/%.asm, $(OUTDIR)/%.asm.o, $(ASMSRC))
VOLTOBJ = $(OUTDIR)/volt.o
OBJ = $(COBJ) $(ASMOBJ) $(VOLTOBJ)


$(OUTDIR)/%.asm.o: src/%.asm
	@mkdir -p $(dir $@)
	@echo "  NASM     $@"
	@$(NASM) -o $@ $(NASMFLAGS) $^

$(OUTDIR)/%.c.o: src/%.c
	@mkdir -p $(dir $@)
	@echo "  CLANG    $@"
	@$(CLANG) -o $@ -c $(CFLAGS) $^

$(VOLTOBJ): $(VOLTSRC)
	@mkdir -p $(dir $@)
	@echo "  VOLT     $@"
	@$(VOLT) -o $@ -c $(VFLAGS) $(VOLTSRC)

$(METAL_ELF): $(OBJ) src/linker.ld
	@echo "  LD       $@"
	@$(LD) -o $@ $(LDFLAGS) $(OBJ)

$(METAL_BIN): $(METAL_ELF)
	@echo "  OBJCOPY  $@"
	@objcopy -O binary $^ $@

$(METAL_ISO): $(METAL_BIN) src/boot/grub.cfg
	@mkdir -p $(OUTDIR)/iso/boot/grub
	@cp src/boot/grub.cfg $(OUTDIR)/iso/boot/grub
	@cp $(METAL_BIN) $(OUTDIR)/iso/boot
	@grub-mkrescue -o $@ $(OUTDIR)/iso -d /usr/lib/grub/i386-pc

iso: $(METAL_ISO)

run: $(METAL_BIN)
	@echo "  QEMU     $^"
	@qemu-system-x86_64 -kernel $^

debug: $(METAL_BIN)
	@echo "  QEMU     $^"
	@qemu-system-x86_64 -kernel $^ -S -s &
	@gdb $(METAL_ELF) -ex 'target remote localhost:1234'

clean:
	@echo "  RM       "
	@rm -rf $(OUTDIR)
	@rm -f $(METAL_ELF) $(METAL_BIN) $(METAL_ISO)

.PHONY: all iso run debug clean
