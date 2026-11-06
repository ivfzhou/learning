# 一、笔记

1. 

# 二、语法

```Makefile
# 依赖文件的修改时间，大于目标文件的修改时间，或者目标项文件不存在，就执行该目标。依赖可以是其他目标。
目标: 依赖
	命令
target: prerequisites
<Tab>recipe


# 井号开头为注释。
# 第一个目标为默认目标。
all: 


# 特殊目标，指定伪目标，伪目标不会当作成文件。
.PHONY: clean all install


# 特殊目标，目标的配方变成在一个 Shell 环境下运行。使用换行符 \ 或者分号 ; 分割命令能达到同样的效果。
.ONESHELL:
your_target:


# 特殊目标，在之后的脚本中，在目标和依赖上，二次展开 $。
.SECONDEXPASION:


# 有 & 符号表示，一次执行配方会生成两个目标；没有 & 符号就会执行两个配置。
your_target your_target2: prerequisites
your_target your_target2 &: prerequisites


# 符号 | 后面的依赖叫有序依赖，只要存在就不会触发构建。
your_target: prerequisites | other_target


# @ 不回显命令。
# - 命令失败也继续。
# = 强制真正执行，不跳过。
your_target:
	@echo '123'
	-echo '123'
	+echo '123'


# 设置变量。
var = value # 在执行时扩展，动态扩展，允许递归扩展。
var2 := value # 在定义时扩展，静态扩展。
var3 ?= value # 只有在该变量为空时才设置值。
var4 += value # 将值追加到变量的尾端。
var5 = v1 v2 v3 # 数组变量。
# 命令中使用变量。
your_target:
	echo $(var)
# 命令中使用 Shell 环境变量。
your_target:
	echo $$LANG
# 内置变量。
your_target_6:
	echo "$(CC)"
	echo "$(MAKE)"
	echo "$(SHELL)"
	echo "$(OS)"
# 自动变量。
your_target:
	echo $@ # 指目标
	echo $< # 指第一个依赖。
	echo $? # 指比目标更新的依赖。
	echo $^ # 指所有依赖（去重）。
	echo $* # 指模式匹配 % 部分。
	echo $(@D) # 指目标的文件夹。
	echo $(@F) # 指目标的文件名。
	echo $(<D) # 指第一个依赖的文件夹。
  echo $(<F) # 指第一个依赖的文件名。
# 目标专属变量。目标专属变量高于 Makefile 中的全局赋值，但低于命令行传入的值。
your_target: CFLAGS := $(CFLAGS_DEBUG)
your_target: override CFLAGS := $(CFLAGS_DEBUG) # override 让专属值优先。
# 执行 Recipe 时，将有 PATH 环境变量。
export PATH := ...


# 内置变量，在之后的脚本中，配方开头不用 tab 而用 >。
.RECIPEPREFIX = >
your_target:
>echo abc


# 内置变量，传给 shell 的命令行参数。
.SHELLFLAGS


# 目标和依赖中的 % 号表示模式匹配。
# 编译所有 .c 文件，生成 .o 文件。只有在其他目标（如可执行文件）需要某个 .o 时才触发。
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


# 分支语句。ifeq 后面必须有空白。
ifeq ($(DEBUG), 1)
    CFLAGS += -g
else ifeq ()

else

endif


# 循环语句。i：循环变量，list：以空格分隔的单词列表，$(i).ext：list 元素加上 .ext。
LIST = $(foreach i, $(list), $(i).ext)


# 函数调用。语法：$(func args) 或 ${func, args}。
LIST := $(shell echo src/{00..99}.txt) # 执行命令。
LIST := $(wildcard src/*.txt) # 替换通配符。
VAR := $(subst ee,EE,feet on the street) # 替换文本。格式：from,to,text。
VAR := $(patsubst %.c,%.o,x.c bar.c) # 模式匹配替换。格式：pattern,replace,text。
VAR := $(VAR:.js=.ts) # 替换后缀名。
VAR := $(basename $(VAR))
$(info info message)
$(warnning warnning message)
$(error error message)
LIST := $(addprefix build/,$(OBJECTS))
LIST := $(sort $(LIST))
VAR := $(dir $(VAR))
LIST := $(filter-out elem,$(LIST))
```

# 三、命令

make *选项*... *目标*...

选项：
- -f *file*、--file=*file*、--makefile=*file*：指定 Makefile 文件，当文件名不叫 `Makefile`、`makefile` 时。
- -C *dir*、--directory=*dir*：切换到指定目录后再执行。
- -j [*n*]、--jobs[=*n*]：并行执行最多 *n* 个任务。不给定参数 *n* 表示不限制任务数。
- -O [*type*]、--output-sync[=*type*]：多个任务的输出会交错，让每个目标的输出成组显示，便于阅读错误。
- -n、--just-print、--dry-run、--recon：只打印将要执行的命令，不实际执行。
- -B、--always-make：强制重新构建所有目标，忽略时间戳。
- -k、--keep-going：出错后继续构建其他无关目标。
- -s、--silent、--quiet：静默模式，不打印命令本身。
- -i、--ignore-errors：忽略 recipe 中的错误。
- -d：输出 make 的决策过程，包括哪些文件被比较、哪些隐式规则被尝试等。
- --debug[=*flags*]：同上。
- -p、--print-data-base：打印 make 实际使用的规则和变量数据库，适合排查“为什么这条规则生效了”。
- -q、--question：不执行任何命令，仅检查目标是否最新，通过退出码（0 = 最新，1 = 需要更新）供脚本使用。
- -e、--environment-overrides：让环境变量覆盖 Makefile 中定义的变量。make 的变量来源优先级（从高到低）大致是：命令行赋值 > Makefile 内部赋值 > 环境变量。

# 四、定义 PREFIX

在 Makefile 中定义：`PREFIX ?= /path/to/dir`，将成为 `PREFIX` 的默认值。  
然后在命令行中指定：`make PREFIX=/path/to/dir`，修改 `PREFIX` 的值。  
或者通过环境变量修改 `PREFIX` 默认值，例如：`export PREFIX=/path/to/dir`。
