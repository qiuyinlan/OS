#ifndef GLOBAL_H
#define GLOBAL_H
#include "stdint.h"

//选择子
//  15              3  2  1  0
// +------------------+--+--+--+
// |   描述符索引      | TI | RPL |
// +------------------+--+--+--+
#define RPL0 0
#define RPL1 1
#define RPL2 2
#define RPL3 3

#define TI_GDT 0
#define TI_LDT 1

//定义不同的内核用的段描述符选择子
#define SELECTOR_K_CODE ((1<<3)+TI_GDT+RPL0)
#define SELECTOR_K_DATA ((2<<3)+TI_GDT+RPL0)
// 权限一致性
// 内核的数据段和栈段通常需要：
// 相同的特权级（Ring 0）
// 相同的内存访问范围（整个内核空间）
// 相同的权限（可读可写)
#define SELECTOR_K_STACK SELECTOR_K_DATA   //表示内核栈段使用与内核数据段相同的段选择子
#define SELECTOR_K_GS   ((3<<3)+TI_GDT+RPL0)


//定义模块化的中断门描述符attr（属性）字段
// 63                       47 46   45     40 39       32
// +-------------------------+------+--------+-----------+
// |       Offset 31..16     |  P   |  DPL  |  Type     |
// +-------------------------+------+--------+-----------+
// |       Segment Selector  |       Offset 15..0       |
// +-------------------------+---------------------------+
//  31                     16 15                         0

//7     6 5    4   3 2 1 0
//P   |  DPL | S | Type

#define IDT_DESC_P    1
#define IDT_DESC_DPL0 0
#define IDT_DESC_DPL3 3
#define IDT_DESC_32_TYPE 0xE  //32位中断门类型  1110
#define IDT_DESC_16_TYPE 0x6  //16位中断门类型

#define IDT_DESC_ATTR_DPL0 ((IDT_DESC_P << 7) + (IDT_DESC_DPL0 << 5) + IDT_DESC_32_TYPE)
#define IDT_DESC_ATTR_DPL3 ((IDT_DESC_P << 7) + (IDT_DESC_DPL3 << 5) + IDT_DESC_32_TYPE)





#endif