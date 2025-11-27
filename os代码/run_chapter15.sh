#!/bin/bash
# Chapter 15 快捷运行脚本
# 用法: ./run_chapter15.sh k  (运行 chapter_15/k)

SUBDIR=${1:-k}
BASE_DIR=~/真象还原/os代码/the_truth_of_operation_system/chapter_15

if [ ! -d "$BASE_DIR/$SUBDIR" ]; then
    echo "错误: 子目录 '$SUBDIR' 不存在!"
    echo "可用的子目录: a, b, c, d, e, f, g, h, i, j, k"
    exit 1
fi

cd "$BASE_DIR/$SUBDIR"

echo "========================================="
echo "正在编译 chapter_15/$SUBDIR..."
echo "========================================="

docker run --rm \
  -v "$(pwd)":/workspace \
  -v ~/真象还原/bochs:/bochs \
  myos-gcc:4.4 bash -c "cd /workspace && make all"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "编译完成! 启动 bochs..."
    echo "========================================="
    cd ~/真象还原/bochs && bin/bochs -f bochsrc.disk
else
    echo ""
    echo "编译失败! 请检查错误信息。"
    exit 1
fi
