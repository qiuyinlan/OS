#include "print.h"
#include "init.h"
int main(void){
    
    

    put_str("interrupt init\n");
    init_all();

    asm volatile
    (
        "sti"   //为了演示中断，这里先临时开启中断
    );


    while(1);
    return 0;
}