【递推与递归 + DFS | 手把手带你画出递归搜索树】 https://www.bilibili.com/video/BV1S24y1p7iH/?share_source=copy_web&vd_source=92aa874d5e931eaa0fccbbc36aa0e872
一直会code的小金鱼

斐波那契:
先确定了前两项,才能往下递归

数据范围小:scanf p 和cin cout效果差不多,但是大的时候inout比sp慢了一倍
c++执行顺序是从右到左

> 递归的时候,会碰到重复的情况,树的不同分支会有一样的东西--->后续可以用数组,记忆化搜索

分解到最底下,得到值之后,再往回推
![[Pasted image 20241205131059.png]]
递归搜索树
先往深的搜,eg最左边那一条
>深度优先搜索
>对于根结点,最长的路,就是树高

递归/dfs最重要的是顺序
![[Pasted image 20241222133602.png]]


![[Pasted image 20241222135821.png]]
改成longlong就对了,我服了
![[pictures/picture1/Pasted image 20241222140151.png]]
因为是函数,所以直接return更好着呢
![[pictures/picture1/Pasted image 20241222140222.png]]*result = 'Y'; 为什么这个可以存啊,不应该指针要移动位置存吗,每次都存一个地方不会覆盖吗

###### ChatGPT 说：

ChatGPT

你的疑问很棒！其实这里的关键在于传入的指针是如何使用的。

在 `*result = 'Y';` 这行代码中，每次传入的指针地址是不同的，所以不会覆盖之前的值。我们来详细拆解一下：

### 指针的本质和传递过程

#### 1. **`&results[i]` 的作用**：

- `&results[i]` 是数组 `results` 中第 `i` 个元素的地址。
- 传入的是一个具体位置的地址，而不是数组的起始地址，也不是一个固定位置的指针。
- 所以，每次调用 `panduan(arr[i], &results[i]);` 时，`results[i]` 的地址会不同。

#### 2. **`*result = 'Y';` 的作用**：

- `*result` 表示对指针 `result` 所指向的内存地址的内容进行操作。
- 每次函数 `panduan` 被调用时，`result` 指向的是 `&results[i]`，也就是数组中不同的元素。
- 这意味着每次操作的实际上是 `results` 数组中的不同位置，而不是同一个地址。
```c
#include<stdio.h>
#include<math.h>
void panduan(long a){
    int j,i;
    for(j=2;j<=sqrt(a);j++){
            if(a%j==0)
            {
                  printf("No\n");
                return;
            }
            
        }
        
            printf("Yes\n");
        
    
          
}
int main(){
    int n,i,j;
    scanf("%d",&n);
    long arr[n];
    for(i=0;i<n;i++){
    scanf("%ld",&arr[i]);
        panduan(arr[i]);
    }
}
```

破案了,我没有考虑<=1 不是素数!!!!!!!
```c
#include <stdio.h>
#include <math.h>

void panduan(long a, char *result) {
    if (a <= 1) {
        *result = 'N';
        return;
    }
    long limit = sqrt(a);
    for (long j = 2; j <= limit; j++) {
        if (a % j == 0) {
            *result = 'N';
            return;
        }
    }
    *result = 'Y';
}

int main() {
    int n;
    scanf("%d", &n);

    long arr[n];
    char results[n];

    for (int i = 0; i < n; i++) {
        scanf("%ld", &arr[i]);
    }

    for (int i = 0; i < n; i++) {
        panduan(arr[i], &results[i]);
    }

    for (int i = 0; i < n; i++) {
        if (results[i] == 'Y') {
            printf("Yes\n");
        } else {
            printf("No\n");
        }
    }

    return 0;
}

```