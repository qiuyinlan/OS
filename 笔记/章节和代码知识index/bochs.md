## 1. Bochs 的配置文件语法

Bochs 软件在启动时会**读取并解析**配置文件，它认识特定的关键字和格式。

### 语法规则：

```
关键字: 值
```

让我给你看几个例子：

Read [bochsrc.disk](vscode-webview://0jr9jcn3fo4cbv76t25prprgpvopkaf58pdhc92s5mqrgk729d8a/index.html?id=c9373d54-e741-4788-a8f9-6b6569a7a69c&parentId=1&origin=5f7ad470-91d7-40e8-bcb2-82f15eb531ec&swVersion=4&extensionId=Anthropic.claude-code&platform=electron&vscode-resource-base-authority=vscode-resource.vscode-cdn.net&parentOrigin=vscode-file%3A%2F%2Fvscode-app&session=a811b5c1-84f1-4c2a-b491-cee35f9d7cb8#)

## 2. Bochs 怎么"读懂"这个文件的？

当你运行 `bochs -f bochsrc.disk` 时，Bochs 软件内部会：

```
伪代码（Bochs 内部处理逻辑）：

1. 打开文件 "bochsrc.disk"
2. 逐行读取：
   
   读到："megs: 32"
   → 解析：关键字是 "megs"，值是 "32"
   → 执行：设置虚拟机内存为 32MB
   
   读到："boot: disk"
   → 解析：关键字是 "boot"，值是 "disk"
   → 执行：设置启动方式为"从硬盘启动"
   
   读到："ata0-master: type=disk, path="hd60M.img", ..."
   → 解析：关键字是 "ata0-master"
   → 参数：type=disk（类型是硬盘）
   →       path="hd60M.img"（文件路径）
   →       cylinders=121（柱面数）
   → 执行：加载 hd60M.img 作为主硬盘
   
   读到："# 这是注释"
   → 忽略（# 开头的是注释）

3. 配置完成，启动虚拟机
```

## 3. 类比：其他软件也有自己的配置语法

### 例子1：Nginx 配置文件

```nginx
# nginx.conf
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
}
```

Nginx 软件认识 `server`, `listen`, `server_name` 这些关键字。

### 例子2：SSH 配置文件

```
# ~/.ssh/config
Host myserver
    HostName 192.168.1.100
    User root
    Port 22
```

SSH 认识 `Host`, `HostName`, `User` 这些关键字。

### 例子3：Git 配置文件

```
# ~/.gitconfig
[user]
    name = John Doe
    email = john@example.com
```

Git 认识 `[user]`, `name`, `email` 这些关键字。

### 例子4：Bochs 配置文件（你的）

```
# bochsrc.disk
megs: 32
boot: disk
ata0-master: type=disk, path="hd60M.img"
```

Bochs 认识 `megs`, `boot`, `ata0-master` 这些关键字。

## 4. Bochs 认识哪些关键字？

## Bochs 支持的常见配置项

| 关键字            | 作用           | 你的配置中的值                            |
| -------------- | ------------ | ---------------------------------- |
| `megs:`        | 内存大小（MB）     | `32`                               |
| `memory:`      | 内存大小（更详细的写法） | 没用这个                               |
| `cpu:`         | CPU型号和参数     | 没配置（用默认）                           |
| `romimage:`    | BIOS文件       | `/home/.../BIOS-bochs-latest`      |
| `vgaromimage:` | 显卡BIOS       | `/home/.../VGABIOS-lgpl-latest`    |
| `boot:`        | 启动设备         | `disk`（硬盘）                         |
| `ata0:`        | IDE控制器0      | `enabled=1, ioaddr1=0x1f0, ...`    |
| `ata0-master:` | 主硬盘          | `type=disk, path="hd60M.img", ...` |
| `mouse:`       | 鼠标           | `enabled=0`（禁用）                    |
| `log:`         | 日志文件         | `bochs.out`                        |
| `floppya:`     | 软盘A          | 没用（因为从硬盘启动）                        |
| `pci:`         | PCI总线        | 没配置                                |


# 启动命令

-f bochsrc.disk
`-f` 参数 = **告诉 Bochs 读取某个配置文件**  - file

Bochs 启动时必须知道：

- 内存多大？
    
- 加载哪个磁盘镜像？
    
- BIOS 在哪里？
    
- VGA 在哪里？
    
- 日志写在哪里？