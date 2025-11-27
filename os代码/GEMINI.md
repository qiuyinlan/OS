# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 项目概述

这是一个基于《操作系统真象还原》的操作系统学习项目，包含两个主要部分：
- **the_truth_of_operation_system/** - 完整的参考代码（chapter_2 到 chapter_15）
- **我的os/** - 学习者自己的实现代码（目前包含 chapter_7、chapter_8 等）

项目目标：通过学习参考代码，最终在"我的os"目录下独立实现一个完整的操作系统。

---

## 编译与运行

### 环境依赖

- **Docker 镜像**: `myos-gcc:4.4` (用于编译) 或 `bochs-dev` (替代方案)
- **Bochs 模拟器**: 位于 `~/真象还原/bochs/bin/bochs`
- **硬盘镜像**: `~/真象还原/bochs/hd60M.img` (所有编译结果写入此处)

### 运行参考代码 (the_truth_of_operation_system)

#### 方法 1: Docker 一键编译运行

```bash
# 以 chapter_15/k 为例
cd ~/真象还原/os代码/the_truth_of_operation_system/chapter_15/k

# 编译并写入硬盘镜像
docker run --rm \
  -v "$(pwd)":/workspace \
  -v ~/真象还原/bochs:/bochs \
  myos-gcc:4.4 bash -c "cd /workspace && make all"

# 运行 bochs
cd ~/真象还原/bochs && bin/bochs -f bochsrc.disk
```

#### 方法 2: 快捷脚本

项目根目录提供了 `run_chapter15.sh` 脚本：

```bash
# 运行 chapter_15/k
./run_chapter15.sh k

# 运行 chapter_15/a
./run_chapter15.sh a
```

**注意**: chapter_15 包含 11 个子目录 (a-k)，每个代表不同的开发阶段。

### 运行自己的代码 (我的os)

```bash
# 1. 进入章节目录
cd ~/真象还原/os代码/我的os/chapter-7

# 2. 使用 Docker 编译
docker run --rm \
  -v /home/xuzichun/真象还原/os代码/我的os:/workspace \
  bochs-dev bash -c "cd /workspace/chapter-7 && make all"

# 3. 写入硬盘镜像（如果 Makefile 未自动执行）
dd if=build/mbr.bin of=~/真象还原/bochs/hd60M.img bs=512 count=1 conv=notrunc
dd if=build/loader.bin of=~/真象还原/bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc
dd if=build/kernel.bin of=~/真象还原/bochs/hd60M.img bs=512 count=200 seek=9 conv=notrunc

# 4. 运行 bochs
cd ~/真象还原/bochs && bin/bochs -f bochsrc.disk
```

---

## 项目结构

### the_truth_of_operation_system (参考代码)

```
the_truth_of_operation_system/
├── chapter_2/          # MBR 引导程序
├── chapter_3/          # 加载器 (Loader)
├── chapter_4-5/        # 保护模式
├── chapter_6-7/        # 中断处理
├── chapter_8-9/        # 内存管理
├── chapter_10/         # 线程
├── chapter_11/         # 进程
├── chapter_12/         # 文件系统
├── chapter_13/         # Shell
├── chapter_14/         # 系统调用
└── chapter_15/         # 完整操作系统
    ├── a/              # 阶段 a
    ├── b/              # 阶段 b
    ...
    └── k/              # 最终完整版
        ├── boot/       # 引导程序 (mbr.S, loader.S)
        ├── kernel/     # 内核核心代码
        ├── device/     # 设备驱动 (timer, keyboard, ide 等)
        ├── lib/        # 库文件
        ├── thread/     # 线程管理
        ├── userprog/   # 用户进程管理
        ├── fs/         # 文件系统
        ├── shell/      # Shell 和内建命令
        ├── build/      # 编译输出目录
        └── makefile    # 编译脚本
```

### 我的os (学习者代码)

```
我的os/
├── Makefile.template      # 通用 Makefile 模板
├── Makefile使用说明.md    # Makefile 使用文档
├── hd60M.img             # 本地硬盘镜像（可选）
├── bochsrc.disk          # Bochs 配置文件
├── chapter-7/            # 第 7 章实现
│   ├── boot/
│   ├── kernel/
│   ├── device/
│   ├── lib/
│   ├── build/
│   └── Makefile
└── chapter_8/            # 第 8 章实现
    └── (类似结构)
```

---

## Makefile 架构

### the_truth_of_operation_system 的 Makefile

- **类型**: 静态 Makefile（手动列出所有源文件）
- **特点**: 每个 .c/.S 文件都有显式编译规则
- **关键配置**:
  - `HD60M_PATH=/bochs/hd60M.img` - 硬盘镜像路径（Docker 内路径）
  - `ENTRY_POINT=0xc0001500` - 内核入口地址
  - `CC=gcc-4.4` - 编译器版本

**核心命令**:
```bash
make all        # 编译 MBR、Loader、内核，并写入硬盘
make clean      # 清理编译文件
make build      # 只编译内核
make boot       # 只编译引导程序
make hd         # 只写入硬盘
```

### 我的os 的 Makefile.template

- **类型**: 智能通用模板（自动检测源文件）
- **特点**:
  - 自动检测所有 .c 和 .S 文件
  - 新增文件无需修改 Makefile
  - 只需修改一行配置：`HD60M_PATH`

**使用方法**:
```bash
# 学习新章节时
cd ~/真象还原/os代码/我的os
cp -r /path/to/reference/chapter_X chapter-X
cp Makefile.template chapter-X/Makefile
cd chapter-X
make all
```

---

## 开发工作流

### 1. 学习参考代码

```bash
# 步骤 1: 阅读源码
cd the_truth_of_operation_system/chapter_15/k
# 查看 kernel/main.c, boot/mbr.S 等关键文件

# 步骤 2: 运行验证
./run_chapter15.sh k

# 步骤 3: 调试（使用 Bochs 调试命令）
cd ~/真象还原/bochs
bin/bochs -f bochsrc.disk
# 在 Bochs 中: c (继续), s (单步), b 0x7c00 (设置断点)
```

### 2. 实现自己的代码

```bash
# 步骤 1: 复制参考代码框架
cd ~/真象还原/os代码/我的os
cp -r ../the_truth_of_operation_system/chapter_X/a chapter-X

# 步骤 2: 复制 Makefile 模板
cp Makefile.template chapter-X/Makefile

# 步骤 3: 修改代码
# 在 IDE 中编辑 chapter-X/ 下的源码

# 步骤 4: 编译测试
cd chapter-X
docker run --rm \
  -v /home/xuzichun/真象还原/os代码/我的os:/workspace \
  bochs-dev bash -c "cd /workspace/chapter-X && make clean && make all"

# 步骤 5: 运行调试
cd ~/真象还原/bochs && bin/bochs -f bochsrc.disk
```

---

## 关键技术点

### 引导流程

1. **MBR (boot/mbr.S)**: 被 BIOS 加载到 0x7c00，负责加载 Loader
2. **Loader (boot/loader.S)**: 从硬盘读取内核，设置保护模式，跳转到内核
3. **Kernel (kernel/main.c)**: 初始化内核，启动系统

### 内存布局

```
0x00000000 - 0x000007ff  实模式 IVT 中断向量表
0x00007c00 - 0x00007dff  MBR 加载位置 (512 字节)
0x00000900 - 0x00000eff  Loader 加载位置
0xc0001500              内核入口地址 (虚拟地址)
```

### 硬盘布局

```
扇区 0:     MBR (1 扇区, 512 字节)
扇区 1:     保留
扇区 2-5:   Loader (4 扇区, 2048 字节)
扇区 6-8:   保留
扇区 9-208: Kernel (200 扇区, 102400 字节)
```

---

## Bochs 调试命令

```bash
# 启动 Bochs
cd ~/真象还原/bochs
bin/bochs -f bochsrc.disk       # 交互模式
bin/bochs -f bochsrc.disk -q    # 静默模式

# 常用调试命令
c                 # 继续运行
s [n]             # 单步执行 n 条指令
n                 # 执行下一条指令
b 0x7c00          # 在地址 0x7c00 设置断点
info r            # 查看所有寄存器
info cpu          # 查看 CPU 状态
info gdt          # 查看 GDT
info idt          # 查看 IDT
x /10xb 0x7c00    # 查看内存（16 进制字节）
xp /10xw 0xc0000000  # 查看物理内存（字）
q                 # 退出
```

---

## 常见问题与解决

### Docker 相关

**问题**: Docker 找不到镜像
```bash
# 检查镜像
docker images | grep myos

# 如果缺失，可能需要重新构建
cd ~/真象还原/os代码/我的os
docker build -t myos-gcc:4.4 -f Dockerfile .
```

### 编译相关

**问题**: 找不到头文件
- 检查 Makefile 中的 `LIB` 变量，确保包含所有目录
- the_truth_of_operation_system: `-I lib/ -I kernel/ -I device/...`

**问题**: 新增文件未编译
- the_truth_of_operation_system: 需手动在 `OBJS` 变量中添加
- 我的os (使用模板): 运行 `make debug` 检查是否检测到文件

### 运行相关

**问题**: Bochs 启动后黑屏
- 检查硬盘镜像路径是否正确
- 确认 `make all` 成功写入硬盘
- 查看 `bochs.out` 日志文件

**问题**: 硬盘镜像路径问题
- the_truth_of_operation_system: 使用 Docker 内路径 `/bochs/hd60M.img`
- 我的os: 修改 Makefile 中的 `HD60M_PATH` 为实际路径

---

## Docker 镜像说明

项目使用两个 Docker 镜像（功能相同）：

- **myos-gcc:4.4**: 主要使用的编译镜像（包含 gcc-4.4, nasm）
- **bochs-dev**: 备用编译镜像（功能相同）

选择使用哪个镜像取决于具体的编译命令。

---

## 学习建议

1. **按章节顺序学习**: 从 chapter_2 开始，逐步到 chapter_15
2. **先运行再修改**: 先跑通参考代码，理解后再自己实现
3. **使用调试器**: 充分利用 Bochs 调试功能，单步跟踪理解执行流程
4. **对比参考代码**: 遇到问题时，对比 the_truth_of_operation_system 中的实现
5. **善用模板**: 使用 Makefile.template 减少重复工作

---

## 参考资源

- **书籍**: 《操作系统真象还原》
- **视频教程**: https://www.bilibili.com/video/BV15o4y157Wm/
- **博客笔记**: https://blog.csdn.net/kanshanxd/article/details/130689471

---

## 🎓 Claude Code 教学模式（新增）

### 学习者背景

- ✅ C 语言基础（结构体和指针需要时会复习）
- ✅ 操作系统理论知识已学完
- 🎯 学习目标：从 Chapter 2 开始实现到 Chapter 11
- 💡 学习态度：**不仅要知道"怎么做"，更要理解"为什么"**

### 核心教学原则：深度理解模式

#### 三层理解法

**第一层：背景知识（为什么要这样？）**
- 每段代码前问：要解决什么问题？为什么这样做？在系统中什么位置？
- 示例："为什么 vstart=0x7c00？" → 解释 BIOS 加载 → 地址计算 → vstart 作用 → 实验验证

**第二层：原理机制（怎么做到的？）**
- 理解底层：CPU 寄存器、内存布局、BIOS 中断、指令执行
- 准备速查表：寄存器、中断号、内存映射
- 画图说明、对比不同实现

**第三层：动手验证（真的是这样吗？）**
- 写代码验证、用 Bochs 单步执行
- 做对比实验：故意改错观察现象
- 总结规律

#### 每章标准教学流程

```
1. 【原理讲解】15-30分钟
   - 本章要解决什么问题
   - 为什么这样做
   - 涉及哪些底层知识

2. 【参考代码分析】30-60分钟
   - 逐行讲解 the_truth_of_operation_system 代码
   - 重点讲"为什么"不只是"是什么"
   - 画图说明、提供速查表
   - 解答所有"为什么"问题

3. 【动手实践】1-2小时
   - 在"我的os/chapter_X"下编写代码
   - 自己敲代码（不复制粘贴）
   - 随时答疑

4. 【实验验证】30分钟
   - 编译运行、观察效果
   - 对比实验：改参数看变化、故意写错
   - 总结结论

5. 【答疑巩固】15-30分钟
   - 回答遗留问题
   - 总结核心知识点
   - 确保理解透彻再进入下一章
```

### 教学重点

**重视"为什么"类问题**：
- 学习者说"看得懂但不知道为什么"是好事，说明在深入思考
- 任何"为什么"都要详细解答，不敷衍
- 优先解决概念理解，不急于推进度

**讲解示例对比**：
- ❌ 差："vstart=0x7c00 告诉汇编器起始地址"
- ✅ 好："背景→问题→作用→验证→类比"（完整的因果链）

**通过对比和实验加深理解**：
- 有 vstart vs 没有 vstart
- 初始化段寄存器 vs 不初始化
- 鼓励"故意写错"理解正确做法

### 当前学习进度

**正在学习**：Chapter 2（MBR 基础）

**已理解**：
- ✅ 计算机启动流程
- ✅ BIOS、MBR、0x7c00 关系
- ✅ vstart 作用（地址计算）
- ✅ SECTION 作用（编译时 vs 运行时）

**计划路线**：
- ⏳ Chapter 2: MBR（当前）
- ⏳ Chapter 3: Loader
- ⏳ Chapter 4-5: 保护模式
- ⏳ Chapter 6-7: 中断处理
- ⏳ Chapter 8-9: 内存管理
- ⏳ Chapter 10: 线程管理
- ⏳ Chapter 11: 进程管理（目标）

### 重要提醒

1. **理解透彻比速度重要**：宁可慢也要确保理解
2. **多问为什么**：刨根问底每个设计决策
3. **动手验证**：理论+实践才能掌握
4. **做笔记**：用自己的话总结
5. **用调试器**：Bochs 单步功能很强大
6. **做实验**：通过"故意错误"理解"正确必要性"
