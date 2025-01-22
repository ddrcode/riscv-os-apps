#!make


TOOL := riscv64-none-elf
AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := emzicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
ASFLAGS := -march=$(ARCH) -mabi=$(ABI) -I headers
CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static -I headers -T platforms/virt.ld

ifneq ($(filter release, $(MAKECMDGOALS)),)
CFLAGS += -Os
LDFLAGS += --gc-sections
else
ASFLAGS += -g
CFLAGS += -g -O0
LDFLAGS += -g --no-gc-sections
endif

OUT := build

#----------------------------------------
# Project files

VPATH = apps/hello

default: build-all

$(OUT):
	mkdir -p $(OUT)


$(OUT)/hello-asm: $(OUT) apps/hello-asm/hello.s
	$(CC) $(CFLAGS) -o $(OUT)/hello-asm.elf apps/hello-asm/hello.s
	$(TOOL)-objcopy -O binary $(OUT)/hello-asm.elf $(OUT)/hello-asm
	rm $(OUT)/hello-asm.elf


$(OUT)/hello-c: $(OUT) apps/hello-c/hello.c
	$(CC) $(CFLAGS) -o $(OUT)/hello-c.elf common/startup.s apps/hello-c/hello.c common/stdlib.s
	$(TOOL)-objcopy -O binary $(OUT)/hello-c.elf $(OUT)/hello-c
	rm $(OUT)/hello-c.elf


build-all: $(OUT)/hello-asm $(OUT)/hello-c


disc: build-all
	rm disc.tar
	ls $(OUT) | xargs tar -cvf disc.tar -C $(OUT)
	truncate -s 33554432 disc.tar


clean:
	rm -rf build/*


.PHONY: clean disc build-all
