#!/bin/bash
# 运行 Bochs 的便捷脚本
# 支持使用本地配置文件或共享配置文件

BOCHS_PATH="/home/xuzichun/下载/bochs-2.6.8/bochs"

# 优先使用本地配置，如果不存在则使用上级目录的共享配置
if [ -f "bochsrc.disk" ]; then
    BOCHSRC="bochsrc.disk"
    HD_IMG="../hd60M.img"
    echo "使用本地配置文件"
elif [ -f "../bochsrc.disk" ]; then
    BOCHSRC="../bochsrc.disk"
    HD_IMG="../hd60M.img"
    echo "使用共享配置文件"
else
    echo "错误: 找不到配置文件 bochsrc.disk"
    echo "请检查当前目录或上级目录"
    exit 1
fi

# 检查硬盘镜像是否存在
if [ ! -f "$HD_IMG" ]; then
    echo "错误: 找不到硬盘镜像 $HD_IMG"
    exit 1
fi

# 检查 Bochs 是否存在
if [ ! -f "$BOCHS_PATH" ]; then
    echo "错误: 找不到 Bochs 可执行文件: $BOCHS_PATH"
    exit 1
fi

echo "启动 Bochs..."
echo "配置文件: $BOCHSRC"
echo "硬盘镜像: $HD_IMG"
echo ""

# 运行 Bochs
$BOCHS_PATH -f $BOCHSRC -q
