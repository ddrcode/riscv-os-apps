#!make


TOOL := riscv64-none-elf
AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

export ROOT := ../..

RISC_V_EXTENSIONS := emzicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
export ASFLAGS := -march=$(ARCH) -mabi=$(ABI) -I headers
export CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static -I $(ROOT)/headers -T $(ROOT)/platforms/virt.ld

CARGO_FLAGS := -Zbuild-std=core --target ./riscv32im-unknown-none-elf.json --release

ifneq ($(filter release, $(MAKECMDGOALS)),)
CFLAGS += -Os
LDFLAGS += --gc-sections
else
ASFLAGS += -g
CFLAGS += -g -O0
LDFLAGS += -g --no-gc-sections
endif

VPATH := common
OUT := build
RELEASE = $(OUT)/release

export COMMON := $(ROOT)/$(OUT)/common.o

MAKE := OUT=$(ROOT)/$(OUT) make --warn-undefined-variables --no-print-directory

#----------------------------------------
# Project files


default: build-all

$(OUT):
	mkdir -p $(OUT)

$(RELEASE):
	mkdir -p $(RELEASE)

$(OUT)/common.o: $(OUT) common/*.s
	$(AS) $(ASFLAGS) -o $(OUT)/common.o common/*.s


$(OUT)/%.elf: $(OUT)/common.o apps/%/Makefile
	$(MAKE) -C ./apps/hello-c -f Makefile $(ROOT)/$@

# $(OUT)/hello-asm.elf: $(OUT) apps/hello-asm/hello.s
# 	$(CC) $(CFLAGS) -o $(OUT)/hello-asm.elf apps/hello-asm/hello.s

# $(OUT)/hello-c.elf: $(OUT)/common.o apps/hello-c/hello.c
# 	$(CC) $(CFLAGS) -o $(OUT)/hello-c.elf build/common.o apps/hello-c/hello.c

build-rust: $(OUT)
	cargo build -Zbuild-std=core --target platforms/riscv32im-unknown-none-elf.json --release
	cp target/riscv32im-unknown-none-elf/release/hello-rust $(OUT)/hello-rust.elf

build-all: build-rust $(OUT)/hello-asm.elf $(OUT)/hello-c.elf

$(RELEASE)/%: $(OUT)/%.elf | $(RELEASE)
	$(TOOL)-objcopy -O binary $< $@

release-all: build-rust $(RELEASE)/hello-asm $(RELEASE)/hello-c $(RELEASE)/hello-rust

disc: release-all
	rm -f disc.tar
	touch $(OUT)/release/.system
	ls -A $(OUT)/release | xargs tar -cvf disc.tar -C $(OUT)/release
	truncate -s 33554432 disc.tar


clean:
	$(MAKE) -C ./apps/hello-c -f Makefile clean
	rm -rf $(OUT)
	cargo clean


.PHONY: clean disc build-all build-rust
