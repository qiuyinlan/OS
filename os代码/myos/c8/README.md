# Chapter 8 使用说明 / Build Instructions

## 目录结构 / Directory Structure

Chapter 8 包含 5 个子目录: `a`, `b`, `c`, `d`, `e`

每个子目录代表操作系统内核的不同阶段或版本。

## 快速开始 / Quick Start

### 完整流程

1. **编译并安装** (例如子目录 c):
```bash
docker run --rm -v /home/xuzichun/boch/bochs:/home/xuzichun/boch bochs-dev bash -c "cd /home/xuzichun/boch/chapter_8 && make SUBDIR=c all && make SUBDIR=c install"
```

2. **运行 Bochs**:
```bash
cd /home/xuzichun/boch/bochs/chapter_8
./run.sh
```

3. **在 Bochs 中输入 `c` 继续运行**

## Build Commands

### Using Docker (Recommended)

Build default subdirectory (a):
```bash
docker run --rm -v /home/xuzichun/boch/bochs:/home/xuzichun/boch bochs-dev bash -c "cd /home/xuzichun/boch/chapter_8 && make all && make install"
```

Build a specific subdirectory (e.g., subdirectory `b`):
```bash
docker run --rm -v /home/xuzichun/boch/bochs:/home/xuzichun/boch bochs-dev bash -c "cd /home/xuzichun/boch/chapter_8 && make SUBDIR=b all && make SUBDIR=b install"
```

### Direct Make Commands

```bash
# Build default subdirectory (a)
make all
make install

# Build a specific subdirectory
make SUBDIR=b all
make SUBDIR=b install

# Or use direct subdirectory target
make b

# Clean a subdirectory
make SUBDIR=b clean

# Clean all subdirectories
make clean-all

# Show help
make help
```

## Available Targets

- `all` - Build the specified subdirectory (default: a)
- `install` - Build and install to disk image
- `clean` - Clean the specified subdirectory
- `clean-all` - Clean all subdirectories
- `a`, `b`, `c`, `d`, `e` - Build a specific subdirectory directly
- `help` - Show help message

## Examples

```bash
# Build and install subdirectory 'c' using Docker
docker run --rm -v /home/xuzichun/boch/bochs:/home/xuzichun/boch bochs-dev bash -c "cd /home/xuzichun/boch/chapter_8 && make SUBDIR=c all && make SUBDIR=c install"

# Build subdirectory 'd' directly
make d

# Clean all build artifacts
make clean-all
```

## Running with Bochs

编译安装完成后，运行操作系统:

### 方法 1: 使用便捷脚本 (推荐)
```bash
cd /home/xuzichun/boch/bochs/chapter_8
./run.sh
```

### 方法 2: 直接运行 Bochs
```bash
cd /home/xuzichun/boch/bochs/chapter_8
/home/xuzichun/下载/bochs-2.6.8/bochs -f bochsrc.disk -q
```

或使用简短命令:
```bash
~/下载/bochs-2.6.8/bochs -f bochsrc.disk -q
```

### Bochs 常用命令

在 Bochs 调试界面中:
- `c` 或 `cont` - 继续运行
- `s` 或 `step` - 单步执行
- `q` 或 `quit` - 退出
- `info r` - 显示寄存器状态
- `info break` - 显示断点
- `b 0x7c00` - 在地址 0x7c00 设置断点

## Notes

- The disk image is located at `../hd60M.img` relative to chapter_8
- Each subdirectory has its own `build/` directory for output files
- The makefiles have been updated to use the correct path for the disk image
- The `bochsrc.disk` configuration file is in the chapter_8 root directory
