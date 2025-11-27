# Makefile for chapter-7 OS

BUILD_DIR = ./build
BOOT_DIR = ./boot
KERNEL_DIR = ./kernel
LIB_DIR = ./lib
DEVICE_DIR = ./device

# 硬盘镜像（指向 bochs 运行目录）
HD_IMG = /home/xuzichun/真象还原/bochs/hd60M.img

# 编译器和汇编器
AS = nasm
CC = gcc
LD = ld

# 编译选项
ASFLAGS = -f elf32
CFLAGS = -m32 -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes -Wsystem-headers -I . -I $(LIB_DIR) -I $(LIB_DIR)/kernel -I $(KERNEL_DIR)
LDFLAGS = -m elf_i386 -Ttext 0xc0001500 -e main

# 目标文件
OBJS = $(BUILD_DIR)/main.o \
       $(BUILD_DIR)/init.o \
       $(BUILD_DIR)/interrupt.o \
       $(BUILD_DIR)/timer.o \
       $(BUILD_DIR)/kernel.o \
       $(BUILD_DIR)/print.o

.PHONY: all clean install run

all: $(BUILD_DIR)/mbr.bin $(BUILD_DIR)/loader.bin $(BUILD_DIR)/kernel.bin

# 编译 MBR
$(BUILD_DIR)/mbr.bin: $(BOOT_DIR)/mbr.s
	@echo "Compiling MBR..."
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

# 编译 Loader
$(BUILD_DIR)/loader.bin: $(BOOT_DIR)/loader.s
	@echo "Compiling Loader..."
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

# 编译 kernel C 文件
$(BUILD_DIR)/main.o: $(KERNEL_DIR)/main.c
	@echo "Compiling main.c..."
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/init.o: $(KERNEL_DIR)/init.c
	@echo "Compiling init.c..."
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/interrupt.o: $(KERNEL_DIR)/interrupt.c
	@echo "Compiling interrupt.c..."
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/timer.o: $(DEVICE_DIR)/timer.c
	@echo "Compiling timer.c..."
	$(CC) $(CFLAGS) -I $(KERNEL_DIR) -o $@ $<

# 编译 kernel 汇编文件
$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.s
	@echo "Compiling kernel.s..."
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/print.o: $(LIB_DIR)/kernel/print.s
	@echo "Compiling print.s..."
	$(AS) $(ASFLAGS) -o $@ $<

# 链接 kernel
$(BUILD_DIR)/kernel.bin: $(OBJS)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -o $@ $^

# 安装到硬盘镜像
install: all
	@echo "Installing to disk image..."
	@if [ ! -f $(HD_IMG) ]; then \
		echo "Creating disk image..."; \
		dd if=/dev/zero of=$(HD_IMG) bs=1M count=60; \
	fi
	dd if=$(BUILD_DIR)/mbr.bin of=$(HD_IMG) bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/loader.bin of=$(HD_IMG) bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$(HD_IMG) bs=512 count=200 seek=9 conv=notrunc
	@echo "Installation complete!"

# 运行 bochs
run: install
	@echo "Starting bochs..."
	cd /home/xuzichun/真象还原/bochs && bin/bochs -f bochsrc.disk

# 清理
clean:
	@echo "Cleaning build files..."
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.bin
	@echo "Clean complete!"
