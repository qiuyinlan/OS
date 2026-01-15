#!/bin/bash
# 第三章 c3/b 一键编译运行脚本

# 设置颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 硬盘镜像路径
HD_PATH="/home/xuzichun/真象还原/bochs/hd60M.img"
BOCHS_DIR="/home/xuzichun/真象还原/bochs"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  第三章 c3/b 编译与运行脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. 创建 build 目录
echo -e "${GREEN}[1/6]${NC} 创建 build 目录..."
mkdir -p build

# 2. 编译 MBR
echo -e "${GREEN}[2/6]${NC} 编译 mbr.S..."
nasm -o build/mbr -I ./boot/include/ boot/mbr.S
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：mbr.S 编译失败！${NC}"
    exit 1
fi
echo "  ✓ mbr.S 编译成功 ($(ls -lh build/mbr | awk '{print $5}'))"

# 3. 写入 MBR 到扇区0
echo -e "${GREEN}[3/6]${NC} 写入 MBR 到硬盘扇区0..."
dd if=build/mbr of="$HD_PATH" bs=512 count=1 conv=notrunc 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：MBR 写入失败！${NC}"
    exit 1
fi
echo "  ✓ MBR 已写入扇区0"

# 4. 编译 Loader
echo -e "${GREEN}[4/6]${NC} 编译 loader.S..."
nasm -o build/loader -I ./boot/include/ boot/loader.S
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：loader.S 编译失败！${NC}"
    exit 1
fi
echo "  ✓ loader.S 编译成功 ($(ls -lh build/loader | awk '{print $5}'))"

# 5. 写入 Loader 到扇区2
echo -e "${GREEN}[5/6]${NC} 写入 Loader 到硬盘扇区2..."
dd if=build/loader of="$HD_PATH" bs=512 count=1 conv=notrunc seek=2 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：Loader 写入失败！${NC}"
    exit 1
fi
echo "  ✓ Loader 已写入扇区2"

# 6. 运行 Bochs
echo -e "${GREEN}[6/6]${NC} 启动 Bochs 模拟器..."
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}预期结果：${NC}"
echo -e "  屏幕应显示："
echo -e "    ${GREEN}1 MBR${NC}    (绿色闪烁背景，红色字体)"
echo -e "    ${GREEN}2 LOADER${NC} (紧接着显示)"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$BOCHS_DIR" && bin/bochs -f bochsrc.disk
