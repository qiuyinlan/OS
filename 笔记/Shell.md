# Shell

**Shell** 是一种特殊的[[应用程序]]，它为用户提供了一个与[[操作系统]][[内核]]进行交互的接口。用户通过这个接口输入的命令，由Shell进行解释并传递给[[内核]]执行。

## Shell的分类

1.  **命令行接口 (CLI - Command-Line Interface)**:
    -   以纯文本的形式与用户交互。
    -   用户输入命令，Shell解释并执行。
    -   常见的CLI Shell有：
        -   **Bash (Bourne-Again Shell)**: [[Linux]]和macOS中最常用的默认Shell。
        -   **Sh (Bourne Shell)**: 早期的[[UNIX]]标准Shell。
        -   **Zsh (Z Shell)**: Bash的扩展，功能更强大。
        -   **PowerShell**: Windows下的命令行工具。

2.  **图形用户界面 (GUI - Graphical User Interface)**:
    -   以窗口、图标、菜单等图形元素为用户提供交互界面。
    -   用户通过[[鼠标]]和[[键盘]]等[[输入设备]]操作这些图形元素。
    -   常见的GUI Shell有：
        -   Windows的“文件资源管理器”。
        -   macOS的“访达”（Finder）。
        -   [[Linux]]中的GNOME Shell、KDE Plasma等。

## 在本项目中的意义
在我们的[[操作系统]]项目中，我们将实现一个简单的CLI Shell。这个Shell将具备以下基本功能：
-   接收用户从[[键盘]]输入的命令。
-   解释命令并调用相应的[[系统调用]]。
-   在屏幕上显示结果。
-   为将来的[[用户进程]]提供一个交互入口。

## 关联知识
- [[操作系统]]
- [[内核]]
- [[系统调用]]
- [[用户进程]]
- [[应用程序]]
- [[Linux]]
- [[UNIX]]
- [[键盘]]
- [[鼠标]]
- [[输入设备]]
- [[输出设备]]
