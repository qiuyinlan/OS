%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
                                                        ;=================================
                                                        ;设置GDT（全局描述符表）
                                                        ;=================================

GDT_BASE:
    dd 0x00000000
    dd 0x00000000

CODE_DESC:
    dd 0x0000FFFF
    dd DESC_CODE_HIGH4

DATA_STACK_DESC:
    dd 0x0000FFFF
    dd DESC_DATA_HIGH4

VIDEO_DESC:
    dd 0x80000007                                       ;limit=(0xbffff-0xb8000)/4k=0x7
    dd DESC_VIDEO_HIGH4

    GDT_SIZE equ $-GDT_BASE                             ;gdt_ptr中需要的变量
    GDT_LIMIT equ GDT_SIZE-1

    times 60 dq 0                                       ;初始化60个描述符

    SELECTOR_CODE equ (0x0001<<3)+TI_GDT+RPL0           ;初始化段选择子
    SELECTOR_DATA equ (0x0002<<3)+TI_GDT+RPL0
    SELECTOR_VIDEO equ (0x0003<<3)+TI_GDT+RPL0          ;修正：应该是0x0003

total_mem_bytes dd 0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

ards_buf times 244 db 0                                 ;ARDS 是 地址范围描述符结构
ards_nr dw 0                                            ;ARDS 的数量

                                                        ;===============================================
                                                        ;检测内存 BIOS中断 int 15h  E820h     获得总内存大小
                                                        ;===============================================

loader_start:
    xor ebx,ebx                                         ;第一次调用时，ebx值要为0
    mov edx,0x534d4150                                  ;设置为魔术字 `'SMAP'`
    mov di,ards_buf
.e820_mem_get_loop:
    mov eax,0x0000e820                                  ;修正：子功能号应该是0xe820
    mov ecx,20
    int 0x15                                            ;ARDS地址范围描述符结构大小是20字节
    jc .error_hlt                                       ;如果出错则跳转
    add di,cx
    inc word [ards_nr]                                  ;记录ARDS数量
    cmp ebx,0
    jnz .e820_mem_get_loop

    ; 查找最大的内存块
    mov cx,[ards_nr]                                    ;修正：应该是ards_nr，不是ards_buf
    mov ebx,ards_buf
    xor edx,edx                                         ;edx存储最大内存地址
.find_max_mem_area:
    mov eax,[ebx]                                       ;基地址低32位
    add eax,[ebx+8]                                     ;基地址+长度=结束地址
    add ebx,20                                          ;指向下一个ARDS
    cmp edx,eax
    jge .next_ards
    mov edx,eax                                         ;更新最大内存地址
.next_ards:
    loop .find_max_mem_area

    mov [total_mem_bytes],edx

    mov byte [gs:160], 'P'


                                                        ;====================
                                                        ;准备进入保护模式
                                                        ;1 打开A20
                                                        ;2 加载gdt
                                                        ;3 将cr0的pe位置1
                                                        ;4 远跳转清空流水线
                                                        ;====================
    in al,0x92
    or al,0000_0010B
    out 0x92,al

    lgdt [gdt_ptr]

    mov eax,cr0
    or eax,0x00000001
    mov cr0,eax

    jmp SELECTOR_CODE:p_mode_start                      ;跳转到保护模式代码

.error_hlt:
    hlt

[bits 32]
p_mode_start:                                           ;==================================
                                                        ;保护模式开始     初始化保护模式
                                                        ;==================================
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,LOADER_STACK_TOP
    mov ax,SELECTOR_VIDEO
    mov gs,ax

                                                        ;===============================
                                                        ;加载内核：从磁盘中读取到内存
                                                        ;===============================
    mov eax,KERNEL_START_SECTOR
    mov ebx,KERNEL_BIN_BASE_ADDR
    mov ecx,20
    call rd_disk_m_32

                                                        ;=====================
                                                        ;设置页表
                                                        ;=====================
    call setup_page  

    ; 修正GDT的基地址以适应分页
    mov ebx,[gdt_ptr+2]
    or dword [ebx+0x18+4],0xc0000000                    ;视频段描述符

    add dword [gdt_ptr+2],0xc0000000                    ;GDT基地址

    add esp,0xc0000000                                  ;栈指针

    ; 设置CR3寄存器指向页目录
    mov eax,PAGE_DIR_TABLE_POS                          ;修正：需要先设置eax  
    mov cr3,eax

                                                    ; 打开cr0的pg位(第31位)
    mov eax,cr0
    or eax,0x80000000
    mov cr0,eax

    lgdt [gdt_ptr]
                                          ;重新加载GDT
    mov byte [gs:320],'v'

    

enter_kernel:    
    call kernel_init
    mov esp, 0xc009f000
    jmp KERNEL_ENTRY_POINT                              ; 用地址0x1500访问测试，结果ok

                                                        ;-----------------   将kernel.bin中的segment拷贝到编译的地址   -----------
kernel_init:
    xor eax, eax                                        ;清空eax
    xor ebx, ebx		                                ;清空ebx, ebx记录程序头表地址
    xor ecx, ecx		                                ;清空ecx, cx记录程序头表中的program header数量
    xor edx, edx		                                ;清空edx, dx 记录program header尺寸

    mov dx, [KERNEL_BIN_BASE_ADDR + 42]	                ; 偏移文件42字节处的属性是e_phentsize,表示program header table中每个program header大小
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28]                ; 偏移文件开始部分28字节的地方是e_phoff,表示program header table的偏移，ebx中是第1 个program header在文件中的偏移量
					                                    ; 其实该值是0x34,不过还是谨慎一点，这里来读取实际值
    add ebx, KERNEL_BIN_BASE_ADDR                       ; 现在ebx中存着第一个program header的内存地址
    mov cx, [KERNEL_BIN_BASE_ADDR + 44]                 ; 偏移文件开始部分44字节的地方是e_phnum,表示有几个program header
.each_segment:
    cmp byte [ebx + 0], PT_NULL		                    ; 若p_type等于 PT_NULL,说明此program header未使用。
    je .PTNULL

                                                        ;为函数memcpy压入参数,参数是从右往左依然压入.函数原型类似于 memcpy(dst,src,size)
    push dword [ebx + 16]		                        ; program header中偏移16字节的地方是p_filesz,压入函数memcpy的第三个参数:size
    mov eax, [ebx + 4]			                        ; 距程序头偏移量为4字节的位置是p_offset，该值是本program header 所表示的段相对于文件的偏移
    add eax, KERNEL_BIN_BASE_ADDR	                    ; 加上kernel.bin被加载到的物理地址,eax为该段的物理地址
    push eax				                            ; 压入函数memcpy的第二个参数:源地址
    push dword [ebx + 8]			                    ; 压入函数memcpy的第一个参数:目的地址,偏移程序头8字节的位置是p_vaddr，这就是目的地址
    call mem_cpy				                        ; 调用mem_cpy完成段复制
    add esp,12				                            ; 清理栈中压入的三个参数
.PTNULL:
   add ebx, edx				                            ; edx为program header大小,即e_phentsize,在此ebx指向下一个program header 
   loop .each_segment
   ret

                                                        ;----------  逐字节拷贝 mem_cpy(dst,src,size) ------------
                                                        ;输入:栈中三个参数(dst,src,size)
                                                        ;输出:无
                                                        ;---------------------------------------------------------
mem_cpy:		      
    cld                                                 ;将FLAG的方向标志位DF清零，rep在执行循环时候si，di就会加1
    push ebp                                            ;这两句指令是在进行栈框架构建
    mov ebp, esp
    push ecx		                                    ; rep指令用到了ecx，但ecx对于外层段的循环还有用，故先入栈备份
    mov edi, [ebp + 8]	                                ; dst，edi与esi作为偏移，没有指定段寄存器的话，默认是ss寄存器进行配合
    mov esi, [ebp + 12]	                                ; src
    mov ecx, [ebp + 16]	                                ; size
    rep movsb		                                    ; 逐字节拷贝

                                                        ;恢复环境
    pop ecx		
    pop ebp
    ret



                                                        ;------------------------------------------
                                                        ;创建页目录及页表
                                                        ;------------------------------------------

setup_page:
                                                        ;清空页目录表
    mov ecx,4096
    mov esi,0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS+esi],0                 ;修正：需要加上esi索引
    inc esi
    loop .clear_page_dir

.create_pde:                                            ;创建页目录项
    mov eax,PAGE_DIR_TABLE_POS
    add eax,0x1000                                      ;第一个页表的地址
    mov ebx,eax                                         ;ebx为页表1的地址
    or eax,PG_P|PG_RW_W|PG_US_U                         ;页目录项属性

    mov [PAGE_DIR_TABLE_POS+0x0],eax                    ;页目录表0号项
    mov [PAGE_DIR_TABLE_POS+0xc00],eax                  ;页目录表768号项

    sub eax,0x1000                                      ;使最后一个目录项指向页目录表自己
    mov [PAGE_DIR_TABLE_POS+4092],eax

                                                        ;创建页表项
    mov ecx,256                                         ;初始化256个页表项（1MB内存）
    mov esi,0
    mov edx,PG_P|PG_RW_W|PG_US_U
.create_pte:
    mov [ebx+esi*4],edx
    add edx,4096                                        ;下一个物理页
    inc esi
    loop .create_pte

                                                        ;创建内核页目录项（769-1022）
    mov eax,PAGE_DIR_TABLE_POS
    add eax,0x2000                                      ;第二个页表的地址
    or eax,PG_P|PG_RW_W|PG_US_U
    mov ebx,PAGE_DIR_TABLE_POS
    mov ecx,254                                         ;254个项
    mov esi,769
.create_kernel_pde:
    mov [ebx+esi*4],eax
    add eax,0x1000                                      ;下一个页表
    inc esi                                             ;修正：需要递增esi
    loop .create_kernel_pde
    ret

                                                        ;-------------------------------------------------------------------------------
                                                        ;功能:读取硬盘n个扇区
rd_disk_m_32:	   
                                                        ;-------------------------------------------------------------------------------
				                                        ; eax=LBA扇区号
				                                        ; ebx=将数据写入的内存地址
				                                        ; ecx=读入的扇区数
    mov esi,eax	                                        ;备份eax
    mov di,cx		                                    ;备份cx
                                                        ;第1步：设置要读取的扇区数
    mov dx,0x1f2
    mov al,cl
    out dx,al

    mov eax,esi	                                        ;恢复ax
                                                        ;第2步：设置LBA地址
    mov dx,0x1f3                       
    out dx,al                          

    mov cl,8
    shr eax,cl
    mov dx,0x1f4
    out dx,al

    shr eax,cl
    mov dx,0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f	                                        ;lba第24~27位
    or al,0xe0	                                        ;LBA模式
    mov dx,0x1f6
    out dx,al

                                                        ;第3步：发送读命令
    mov dx,0x1f7
    mov al,0x20                        
    out dx,al

                                                        ;第4步：检测硬盘状态
.not_ready:
    nop
    in al,dx
    and al,0x88	                                        ;检查就绪位
    cmp al,0x08
    jnz .not_ready	    

                                                        ;第5步：读取数据
    mov ax, di                                          ;扇区数
    mov dx, 256                                         ;每个扇区读取次数
    mul dx                                              
    mov cx, ax	                                        ;总读取次数
    mov dx, 0x1f0
.go_on_read:
    in ax,dx
    mov [ebx],ax
    add ebx,2
    loop .go_on_read
    ret