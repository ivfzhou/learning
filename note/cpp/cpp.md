# 一、C

## 1.1 笔记

1. [Information technology —Programming languages — C ISO/IEC 9899 2018](./ISO_IEC_9899_2018.pdf)
1. [Programming languages — C++ ISO/IEC 14882 2020](./ISO_IEC_14882_2020.pdf)
1. 编译时头文件查找规则：
   - 双引号的头文件查找顺序：
     - 包含该预编译指令的文件所在目录。
     - 选项 `-iquote` 指定的目录。
     - 之后与尖括号的头文件查找顺序相同。
   - 尖括号的头文件查找顺序：
     - 选项 `-I` 先后指定的目录。
     - 环境变量 `CPATH`、`C_INCLUDE_PATH`、`CPLUS_INCLUDE_PATH` 指定的目录。
     - GCC 内置的默认系统目录（如 `/usr/include`、`/usr/local/include`）。
1. 参考网站：cppreference.com。

### 1.1.1 语法

1. 外部链接的 inline 定义中，不能定义可修改的静态/线程储存期的对象，不能引用内部链接的标识符。
1. 逗号运算符表达式取最右边的值。
1. `switch case` 值只能作用于整形常量。
1. 函数返回值不能是数组。
1. 不允许 `main` 函数递归。
1. 内联函数不能递归。
1. 外部变量、静态变量有默认值，为零值。
1. 语句：标号语句、复合语句、表达式语句、选择语句、迭代语句、跳转语句。
1. `E` 表示法的数字都以浮点数存储。
1. 可以安全的 `delete` 一个空指针。
1. 使用 `{}` 初始化数字更严格，它不允许 narrow，`{}` 里面的值要是常量。
   ```c++
   int arr[10] = {} // 数组所有元素初始化为 0。
   ```
1. `const` 表示修饰的变量不能通过这个变量修改值，但可以通过别的变量修改。
1. 不允许数组作为一个单元赋值给另一个数组，除初始化以外不允许使用大括号列表形式赋值。变长数组不能初始化。
   ```c
   char str[2];
   str = {0}; // 无法编译。
   
   struct S {
       int x;
       char str[];
   };
   struct S s = {.x = 1, .str = "hello world"}; // 无法编译。
   ```
1. 使用 `\` 和多对双引号表示字符串断行。
1. 扩展字符：
   - `??=` #
   - `??(` [
   - `??/` \\
   - `??)` ]
   - `??'` ^
   - `??<` {
   - `??!` |
   - `??>` }
   - `??-` ~
   - `<:` [
   - `:>` ]
   - `<%` {
   - `%>` }
   - `%:` #
   - `%:%:` ##
1. 预定义宏：
   - `__DATE__`：预处理的日期（"Mmm dd yyyy" 形式的字符串字面量，如 Nov 23 2013）。
   - `__FILE__`：表示当前源代码文件名的字符串字面量。
   - `__LINE__`：表示当前源代码文件码中行号的整形常量。
   - `__STDC__`：设置为 1 时，表明实现遵循 C 标准。
   - `__STDC_HOSTED__`：本机环境设置为 1，否则设置为 0。
   - `__STDC_VERSION__`：支持 C99 标准设置为 199901L；支持 C11 标准，设置为 201112L。
   - `__TIME__`：编译代码的时间，格式为 "hh:mm:ss"。
1. `fopen` 字符串模式：   
   - `r`：以只读模式打开文件。
   - `w`：以写模式打开文件，把现有文件的长度截断为 0，如果文件不存在，则创建一个新文件。
   - `a`：以写模式打开文件，在现有文件的末尾添加内容，如果文件不存在，则创建一个新文件。
   - `r+`：以更新模式打开文件，即可以读写文件。
   - `w+`：以更新模式打开文件，即读写，如果文件存在，则将文件长度截断为 0；如果不存在，则创建一个新文件。
   - `a+`：以更新模式打开文件，即读写，在现有文件的末尾添加内容，如果文件不存在，则创建一个新文件；可以读整个文件，但只能在末尾添加内容。
   - `rb`、`wb`、`ab`、`a+b`、`w+b`：与上面模式类似，但是以二进制模式而不是文本模式打开文件。
   - `wx`、`wbx`、`w+x`、`w+bx`：（C11）类似非 x 模式，但是如果文件已存在或以独占模式打开文件，则打开文件失败。
1. 输出占位符格式：`%[flags][width][.precision][length]specifier`。
1. 输入占位符格式：`%[*][width][length]specifier`。
1. 变量和标记的名称使用了不同的共享名称空间：
   ```c
   struct rect { double x; double y; };
   int rect; // 在 C 中不会产生冲突。
   ```
1. 复杂的声明：
   ```c
   int* arr[10] // 元素为 int 指针的数组。
   int (*arr)[10] // 指向数组的指针。
   int* arr[3][4] // 元素为 int 指针的数组。
   int (*arr)[3][4] // 指向数组的指针。
   int (*arr[3])[4] // 元素为指针的数组。
   char* func(int) // 函数。
   char (*func)(int) // 指针。
   char (*func[3])(int) // 元素为指针的数组。
   void fn(int arr[static const restrict 20])
   ```
1. 数字字面量：
   ```c
   int binary = 0b111; // 7
   int octal = 0777; // 511
   int hexadecimal = 0xf; // 15
   double exponent = 1e2; // 1 × 10²
   double exponent1 = 0x1p1; // 1 × 2¹
   ```
1. 字符字面量：
   ```
   \a 警报
   \b 退格
   \f 换页
   \n 换行
   \r 回车
   \t 水平制表符
   \v 垂直制表符
   \' 单引号
   \" 双引号
   \\ 反斜杠
   \? 问号
   \0-\[0]177 八进制值
   \x00-\x7f 十六进制值
   ```

## 1.2 C 语言标准

1. K&R
1. ANSI、C89、C90：ISO/IEC 9899:1990
1. C99：ISO/IEC 9899:1999
1. C11：ISO/IEC 9899:2011
1. C18：ISO/IEC 9899:2018

## 1.3 C 关键字

`auto`、`extern`、`short`、`while`、`break`、`float`、`case`、`for`、`sizeof`、`char`、`goto`、`static`、`if`、`struct`、`continue`、`inline`、`switch`、`default`、`int`、`typedef`、`do`、`long`、`union`、`double`、`register`、`unsigned`、`else`、`restrict`、`void`、`return`  
C90 新增：`signed`、`const`、`enum`、`volatile`  
C11 新增：`_Alignas`、`_Alignof`、`_Atomic`、`_Bool`、`_Complex`、`_Generic`、`_Imaginary`、`_Noreturn`、`_Static_assert`、`_Thread_local`

## 1.4 C 整数浮点数尾部表示

1. `U`：unsigned int
1. `UL`：unsigned long
1. `ULL`：unsigned long long
1. `L`：long 长整数或者长双精度浮点数
1. `LL`：long long
1. `F`：float

## 1.5 C 运算符

| 运算符，优先级从高到低                                       | 结合律 |
| :----------------------------------------------------------- | :----: |
| `++` 后缀、`--` 后缀、`()` 函数调用、`[]`、`{}` 复合字面量、`.`、`->` |  L-R   |
| `++` 前缀、`--` 前缀、`-`、`+`、`~` 按位取反、`!`、`*` 解引用、`&`取址、`sizeof`、`_Alignof` 都是一元运算符 |  R-L   |
| `(类型名) ` 强制转换 与上同级                                |  L-R   |
| `*`、`/`、`%`                                                |  L-R   |
| `+`、`-` 都是二元运算符                                      |  L-R   |
| `<<`、`>>`                                                   |  L-R   |
| `<`、`>`、`>=`、`<=`                                         |  L-R   |
| `==`、`!=`                                                   |  L-R   |
| `&`                                                          |  L-R   |
| `^`                                                          |  L-R   |
| <code>&#124;</code>                                          |  L-R   |
| `&&`                                                         |  L-R   |
| <code>&#124;&#124;</code>                                    |  L-R   |
| `?:`                                                         |  R-L   |
| `=`、`*=`、`/=`、`+=`、`-=`、`<<=`、`>>=`、`&=`、`\|=`、`^=` |  R-L   |
| `,`                                                          |  L-R   |
左结合（left-associative）和 右结合（right-associative）指的是当一个表达式中有多个同级运算符时，运算的顺序。  
也就是说，左结合意味着从左到右依次执行运算。如果有多个相同优先级的运算符，它们会从左边开始进行计算，直到最后。

## 1.6 储存类说明符

决定链接性质、存储期和命令类型。

- `typedef`：定义类型别名。无链接无存储期。块/文件作用域均可出现。
- `extern`：声明外部链接，引用别处定义。外部链接，无存储期。块/文件作用域均可出现。
- `static`：文件作用域→内部链接；块作用域→静态存储期。内部链接，静态存储期。块/文件作用域均可出现。
- `auto`：自动存储期（块作用域的默认值）。无链接，自动存储期。仅块作用域出现。
- `register`：建议放寄存器，禁止取地址。无链接，自动存储期。仅块作用域出现。
- `_Thread_local`：每线程一份变量。无链接，线程存储期。块内出现须与 `static`/`extern ` 组合。

## 1.7 类型说明符

### 1.7.1 空类型

`void`：用于函数无返回值 `void f(void);`、无参数 `(void)`、以及通用指针 `void*`。

### 1.7.2 整数类型

`char`、`short`、`int`、`long`、`long long`：可与 `signed`/`unsigned` 组合。

最小宽度：char ≥ 8 位、short ≥ 16、int ≥ 16、long ≥ 32、long long ≥ 64，且按 char ≤ short ≤ int ≤ long ≤ long long 排序。

### 1.7.3 浮点类型

`float`、`double`（浮点常量的默认类型）、`long double`

### 1.7.4 布尔类型

`_Bool`

### 1.7.5 复数类型

`float _Complex`、`double _Complex`、`long double _Complex`

### 1.7.6 原子类型

`_Atomic ( type-name )`

### 1.7.7 派生类型

`struct`、`union`、`enum`、`typedef 名`

## 1.8 类型限定符

- `const`：只读，不能通过左值修改对象。
- `volatile`：每次访问都须真实地读内存，不能读取缓存获取。
- `restrict`：用于指针，指针指向的对象只有通过该指针访问。
- `_Atomic`：原子访问，不能修饰数组和函数类型。

##  1.0 函数说明符

`inline`、`_Noreturn`

##  1.10 对齐说明符

`_Alignas`、`_Alignof`

## 1.11 C 标准头文件

1. assert.h：提供 assert 宏，用于在调试时，进行运行时断言诊断。
1. complex.h：定义复数类型与复数算术运算函数。
1. ctype.h：提供字符分类（如 isdigit、isalpha）与大小写转换函数。
1. errno.h：定义错误码宏 errno 及错误编号（如 EDOM、ERANGE）。
1. fenv.h：提供浮点环境（舍入模式、异常标志）的访问与控制。
1. float.h：定义各浮点类型特性常量（如 FLT_MAX、DBL_EPSILON）。
1. inttypes.h：提供定宽整数类型的格式化宏与最大宽度整数运算函数。
1. iso646.h：定义 and、or、not 等运算符的替代拼写。
1. limits.h：定义各整数类型取值范围的极限宏（如 INT_MAX、UCHAR_MAX）。
1. locale.h：提供本地化设置（区域类别、小数点、货币格式等）。
1. math.h：提供数学函数（三角函数、幂、对数、取整等）与宏常量。
1. setjmp.h：提供 setjmp/longjmp 非局部跳转能力。
1. signal.h：提供信号处理（signal、raise）及信号类型定义。
1. stdalign.h：定义 alignas、alignof 宏，用于对齐说明。
1. stdarg.h：提供可变参数列表处理（va_start、va_arg 等）。
1. stdatomic.h：定义原子类型与原子操作。
1. stdbool.h：定义 bool、true、false 布尔类型与值。
1. stddef.h：定义常用类型与宏（size_t、NULL、offsetof、ptrdiff_t）。
1. stdint.h：定义定宽整数类型（如 int32_t、uint64_t）及对应极限宏。
1. stdio.h：提供标准输入/输出函数（printf、scanf、文件流操作）。
1. stdlib.h：提供通用工具函数（内存分配、数值转换、exit、qsort 等）。
1. stdnoreturn.h：定义 noreturn 宏，标记不返回的函数。
1. string.h：提供字符串与内存操作函数（strcpy、memcpy、strlen 等）。
1. tgmath.h：提供类型泛型数学宏，自动按参数类型选择对应函数。
1. threads.h：提供线程、互斥量、条件变量等并发支持。
1. time.h：提供日期与时间处理（time、clock、strftime、tm 结构）。
1. uchar.h：定义 char16_t/char32_t 及 Unicode 字符转换函数。
1. wchar.h：提供宽字符与多字节字符的输入/输出及转换函数。
1. wctype.h：提供宽字符分类与大小写映射函数（iswalpha、towlower 等）。

# 二、C++

## 2.1 笔记

1. `const` 值不能赋值给非 `const` 指针，非 `const` 指针不能赋值给 `const` 指针。
    ```c++
    const int var = 1; 
    int *ptr = &var; // 错误。
    
    const int **pptr; 
    int *ptr; pptr = &ptr; // 错误。
    ```
1. 引用变量需要在声明时初始化。`const` 指针也是如此。
   ```c++
   // 错误。
   int y = 1;
   int& x;
   
   // 正确。
   int y = 1;
   int& x = y;
   
   // 错误。
   int* const ptr;
   ptr = &x;
   
   // 正确。
   int* const ptr = &x;
   ```
1. 函数参数有默认值的必须都写在最右边。
1. 类中成员变量不能在定义时初始化。
1. 作用域：程序级、文件级、函数级、块级。
1. 最派生类调用虚基类构造函数，其它派生类不再调用。
1. 成员初始化列表中，虚基类优先执行。
1. 基类构造函数的执行顺序取决于继承定义顺序。
1. 先执行派生类析构再执行基类的。
1. 使用 `new[]` 创建的对象数组，类中必须要定义默认构造函数。
1. 构造函数和析构函数中的虚函数使用静态联编。
1. 引用形参为 `const` 修饰时，允许实参为临时变量。不是左值，和需要类型转换的会生成临时变量。
1. 函数选择中，非 `const` 指针引用和非模板的优先。作用范围越小优先级越高。
1. 初始化列表的执行顺序取决于项目在类中的定义顺序。如果类中有成员作为另一个成员的初始化部分，这个执行顺序就很重要。
1. `const_cast<>` 去除变量的 `const`，但不能改变真 `const` 变量的值。
1. lambda 表达式，匿名函数：`[](){}`。`[]`：捕获列表
   - `[]`：不捕获任何变量。
   - `[=]`：以值方式捕获所有外部变量（即复制所有外部变量）。
   - `[&]`：以引用方式捕获所有外部变量（即创建所有外部变量的引用）。
   - `[var]`：以值方式捕获外部变量 var。
   - `[&var]`：以引用方式捕获外部变量 var。
   - `[this]`：捕获当前对象（在类成员函数中）。
   - `[=, &var]` 或 `[&, var]`：混合捕获。前者以值方式捕获所有变量，但是以引用方式捕获 *var*。后者以引用方式捕获所有变量，但是以值方式捕获 *var*。
 - 复制构造函数加了 `explicit` 修饰，将导致无法 `return` 该类变量。

## 2.2 C++ 标准

- C++98：ISO/IEC 14882:1998
- C++03：ISO/IEC 14882:2003
- C++11：ISO/IEC 14882:2011
- C++14：ISO/IEC 14882:2014
- C++17：ISO/IEC 14882:2017
- C++20：ISO/IEC 14882:2020

## 2.3 C++ 运算符

|                                                                                     运算符                                                                                      | 结合性 |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------:|
|                                                                              `::`作用域解析运算符                                                                               |  L-R   |
| `(表达式)`分组、`()`函数调用、`()`值构造，即 type(expr)、`[]`数组下标、`->`、`.`、`const_cast`、`dynamic_cast`、`reinterpret_cast`、`static_cast`、`typeid`、`++`后缀、`--`后缀 |  L-R   |
|   全是一元运算符，`!`逻辑非、`~`位非、`+`、`-`、`++`前缀、`--`前缀、`&`地址、`*`解除引用，间接值、`()`类型转换，即 type(expr)、`sizeof`、`new`、`new[]`、`delete`、`delete[]`   |  R-L   |
|                                                                                   `.*`、`->*`                                                                                   |  L-R   |
|                                                                          全是二元运算符，`*`、`/`、`%`                                                                          |  L-R   |
|                                                                            全是二元运算符，`+`、`-`                                                                             |  L-R   |
|                                                                                   `<<`、`>>`                                                                                    |  L-R   |
|                                                                              `<`、`<=`、`>=`、`>`                                                                               |  L-R   |
|                                                                                   `==`、`!=`                                                                                    |  L-R   |
|                                                                                       `&`                                                                                       |  L-R   |
|                                                                                       `^`                                                                                       |  L-R   |
|                                                                               <code>&#124;</code>                                                                               |  L-R   |
|                                                                                      `&&`                                                                                       |  L-R   |
|                                                                            <code>&#124;&#124;</code>                                                                            |  L-R   |
|                                                                                      `:?`                                                                                       |  R-L   |
|                                                          `=`、`*=`、`/=`、`%=`、`+=`、`&=`、`^=`、`\|=`、`<<=`、`>>=`                                                           |  R-L   |
|                                                                                     `throw`                                                                                     |  L-R   |
|                                                                                       `,`                                                                                       |  L-R   |

## 2.4 C++ 成员函数属性

|    函数    | 能够继承 | 成员还是友元 | 默认能否生成 | 能否为虚函数 | 是否可以有返回值类型 |
|:----------:|:--------:|:------------:|:------------:|:------------:|:--------------------:|
|  构造函数  |    否    |     成员     |      能      |      否      |          否          |
|  析构函数  |    否    |     成员     |      能      |      能      |          否          |
|     =      |    否    |     成员     |      能      |      能      |          能          |
|     &      |    能    |     任意     |      能      |      能      |          能          |
|  转换函数  |    能    |     成员     |      否      |      能      |          否          |
|     ()     |    能    |     成员     |      否      |      能      |          能          |
|     []     |    能    |     成员     |      否      |      能      |          能          |
|     ->     |    能    |     成员     |      否      |      能      |          能          |
|    op=     |    能    |     任意     |      否      |      能      |          能          |
|    new     |    能    |   静态成员   |      否      |      否      |        void*         |
|   delete   |    能    |   静态成员   |      否      |      否      |         void         |
| 其他运算符 |    能    |     任意     |      否      |      能      |          能          |
|  其他成员  |    能    |     成员     |      否      |      能      |          能          |
|    友元    |    否    |     友元     |      否      |      否      |          能          |

## 2.5 C++ 继承方式

|       特征       |       公有继承       |       保护继承       |       私有继承       |
|:----------------:|:--------------------:|:--------------------:|:--------------------:|
|   公有成员变成   |   派生类的公有成员   |   派生类的保护成员   |   派生类的私有成员   |
|   保护成员变成   |   派生类的保护成员   |   派生类的保护成员   |   派生类的私有成员   |
|   私有成员变成   | 只能通过基类接口访问 | 只能通过基类接口访问 | 只能通过基类接口访问 |
| 能否隐式向上转换 |          是          |  是，只能在派生类中  |          否          |

## 2.6 C++ 标准头文件

1. C++98/C++03 标准头文件
   - algorithm：常用算法
   - bitset：位集容器
   - complex：复数类
   - deque：双端队列容器
   - exception：异常处理类
   - fstream：文件流类
   - functional：函数对象和绑定器
   - iomanip：输入输出操纵器
   - ios：基本输入输出支持
   - iosfwd：输入输出前向声明
   - iostream：标准输入输出流
   - istream：输入流类
   - iterator：迭代器支持
   - limits：数值极限
   - list：双向链表容器
   - locale：本地化支持
   - map：映射容器
   - memory：动态内存管理
   - new：动态内存分配
   - numeric：数值操作
   - ostream：输出流类
   - queue：队列容器
   - set：集合容器
   - sstream：字符串流类
   - stack：栈容器
   - stdexcept：标准异常类
   - streambuf：流缓冲区
   - string：字符串类
   - typeinfo：运行时类型信息
   - utility：通用工具类
   - valarray：数组类
   - vector：动态数组容器
1. C++11 标准新增头文件
   - array：定长数组容器
   - atomic：原子操作
   - chrono：时间库
   - codecvt：Unicode 转换工具
   - condition_variable：条件变量
   - forward_list：单向链表容器
   - future：异步操作支持
   - initializer_list：初始化列表
   - mutex：互斥锁
   - random：随机数库
   - ratio：编译时有理数算术
   - regex：正则表达式
   - scoped_allocator：作用域分配器
   - system_error：系统错误支持
   - thread：线程支持
   - tuple：元组类
   - typeindex：类型索引
   - type_traits：类型特性
   - unordered_map：无序映射容器
   - unordered_set：无序集合容器
1. C++17 标准新增头文件
   - any：类型安全的通用容器
   - charconv：字符串转换
   - filesystem：文件系统库
   - memory_resource：多态内存资源
   - optional：可选值
   - string_view：字符串视图
   - variant：类型安全的联合体
1. C++20 标准新增头文件
   - barrier：屏障同步
   - bit：位操作
   - compare：三向比较
   - concepts：概念
   - coroutine：协程支持
   - latch：闭锁同步
   - numbers：数学常量
   - ranges：范围库
   - semaphore：信号量
