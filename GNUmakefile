
LD ?= ld
LLD ?= ld.lld
VOLT ?= volt
NASM ?= nasm
CLANG ?= clang
QEMU ?= qemu-system-x86_64
OUTDIR ?= .obj
NASMFLAGS ?= -f elf64 -g3 -F dwarf
CFLAGS ?= -g --target=x86_64-pc-none-elf
VFLAGS ?= --no-stdlib -w -d --platform metal --arch x86_64
LDFLAGS ?= -T src/linker.ld --gc-sections -z max-page-size=0x1000
LLDFLAGS ?= $(LDFLAGS) -O3 --lto-O3

METAL_QEMU_ARGS ?= -M q35 -serial stdio

METAL_ELF ?= metal.elf
METAL_BIN ?= metal.bin
METAL_ISO ?= metal.iso

all: $(METAL_BIN)

include sources.mk
VOLTBC = $(OUTDIR)/volt.bc
COBJ = $(patsubst src/%.c, $(OUTDIR)/%.c.o, $(CSRC))
ASMOBJ = $(patsubst src/%.asm, $(OUTDIR)/%.asm.o, $(ASMSRC))
VOLTOBJ = $(OUTDIR)/volt.o
LD_INPUT = $(COBJ) $(ASMOBJ) $(VOLTOBJ)
LLD_INPUT = $(COBJ) $(ASMOBJ) $(VOLTBC)


$(OUTDIR)/%.asm.o: src/%.asm
	@mkdir -p $(dir $@)
	@echo "  NASM     $@"
	@$(NASM) -o $@ $(NASMFLAGS) $^

$(OUTDIR)/%.c.o: src/%.c
	@mkdir -p $(dir $@)
	@echo "  CLANG    $@"
	@$(CLANG) -o $@ -c $(CFLAGS) $^

$(VOLTBC): $(VOLTSRC)
	@echo "  VOLTA    $@"
	@mkdir -p $(dir $@)
	@$(VOLT) --emit-bitcode -o $@ $(VFLAGS) $(VOLTSRC)

$(VOLTOBJ): $(VOLTBC)
	@echo "  VOLTA    $@"
	@$(VOLT) -c -o $@ $<

ifeq ($(shell which $(LLD)),)
$(METAL_ELF): $(LD_INPUT) src/linker.ld
	@echo "  LD       $@"
	@$(LD) -o $@ $(LDFLAGS) $(LD_INPUT)
else
$(METAL_ELF): $(LLD_INPUT) src/linker.ld
	@echo "  LLD      $@"
	@$(LLD) -o $@ $(LLDFLAGS) $(LLD_INPUT)
endif

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
	@qemu-system-x86_64 -kernel $^ $(METAL_QEMU_ARGS)

debug: $(METAL_BIN)
	@echo "  QEMU     $^"
	@qemu-system-x86_64 -kernel $^ $(METAL_QEMU_ARGS) -S -s &
	@gdb $(METAL_ELF) -batch -ex 'target remote localhost:1234' -ex 'b boot_main' -ex 'c' -ex 'disconnect'
	@gdb $(METAL_ELF) -ex 'set arch i386:x86-64' -ex 'target remote localhost:1234'

clean:
	@echo "  RM       "
	@rm -rf $(OUTDIR)
	@rm -f $(METAL_ELF) $(METAL_BIN) $(METAL_ISO)

.PHONY: all iso run debug clean
