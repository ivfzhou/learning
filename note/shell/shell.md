# 一、笔记

1. [POSIX Shell 语法](https://pubs.opengroup.org/onlinepubs/9799919799/idx/shell.html)。
1. [Bash 语法](https://www.gnu.org/software/bash/manual/html_node/index.html)。
1. 波浪号 ~ 扩展发生在变量扩展之前，~\$user 展开为名为 \$user 的用户的家目录。
1. /etc/shells 系统支持的 shell。
1. ctrl+z 挂起当前进程；ctrl+d 发送 EOF 信号。
1. ssh 复制文件：scp src ivfzhou@ivfzhoudebian:~/src。
1. 脚本文件第一行注释 #!/bin/bash，指明脚本的解释器。
1. 标准输入内容：
   ```bash
   <<EOF
   内容...
   EOF
   ```

   将输入的内容去掉前导的 Tab 字符：
   ```bash
   <<-EOF
   内容...
   EOF
   ```

   硬标签，不解析内容里的变量和命令替换：
   ```bash
   <<'EOF'
   内容...
   EOF
   ```
1. 变量名只能以数字、字母、下划线组合，且不以数字开头。
1. 单引号字符串中不识别变量，不能转义。双引号字符串中可解析变量可转义。
1. 检测系统中是否安装了 bash，并根据检测结果输出 yes 或 no：command -v bash > /dev/null 2>&1 && echo yes || echo no。
1. 算术扩展，可以使用：变量（可省略 \$，如 a 直接代表变量值）、整数常量、算术运算符、比较、逻辑、位运算等：
   ```bash
   a=5
   b=3
   echo $((1 + 1))
   echo $((a + b)) # 8
   echo $((a * b)) # 15
   echo $((a > b ? a : b)) # 5（三元运算）
   
   result=$((x=3, y=5, x+y)))
   echo $result # 8
   ```
1. 命令替换，执行命令，将其标准输出作为字符串插入到当前位置：var=\$(date +%F)。
1. 花括号扩展：
   ```bash
   # 生成一个从 1 到 8 的整数序列
   echo {1..8}
   # 输出：1 2 3 4 5 6 7 8
   
   # 指定步长
   echo {1..8..2}
   # 生成 1 3 5 7
   
   # 字母序列
   echo {a..z}
   # 生成 a 到 z 的字母
   
   # 逆序
   echo {8..1}
   # 生成 8 7 6 5 4 3 2 1
   
   echo {a,b,c} # 输出：a b c
   echo file{1,2,3}.txt # 输出：file1.txt file2.txt file3.txt
   ```
1. 字面量单词列表：
   ```bash
   echo 1 2 3 4
   
   for i in 1 2 3 4; do
       echo $i
   done
   ```
1. 临时设置环境变量，仅对本行命令运行可获取，后面行的命令获取不到变量设置的值：
   ```bash
   LANG=zh_CN 命令 ...
   ```
1. 短路求值：
   - `CmdA && CmdB`：CmdA 返回码为 0 时才运行 CmdB。
   - `CmdA || CmdB`：CmdA 返回码为非 0 时才运行 CmdB。
   - `CmdA && CmdB || CmdC`：CmdA 返回码为非 0 时，不运行 CmdB，CmdA && CmdB 整体是失败的，运行 CmdC；CmdA 返回码为 0 时，运行 CmdB，若 CmdB失败则运行 CmdC，否则 CmdC 不运行。
1. 查询当前是登陆 Shell 还是交互式 Shell，echo \$0，输出 bash 是交互式 Shell，输出 -bash 是登陆 Shell。

# 二、Bash 语法

是一个 Shell 解释器，负责读取用户输入或脚本文件，解释命令并执行。

## 2.1 内置命令

不需要启动子进程即可执行命令。外部命令，由 Bash 通过 PATH 环境变量查找并调用独立可执行文件。

- help：列出所有内置命令及其简要说明。help cd 查看内置命令的详细帮助。

- compgen -b：列出所有内置命令名（不含说明）。

- type *命令*：查看某个命令是内置命令还是外部命令。

- cd *目录*：切换当前工作目录。无参数时切换到 \$HOME。

- pwd：打印当前工作目录（等价于 echo \$PWD）。

- dirs：显示目录栈内容。

- pushd *目录*：将当前目录压入目录栈并切换到指定目录。

- popd：从目录栈弹出栈顶目录并切换到该目录。

- export *变量*=*值*：将变量设为环境变量，使其可传递给子进程。

- readonly *变量*=*值*：定义只读变量，不可修改或删除。

- declare *选项* *变量*：声明变量并设置属性（如整数、数组、只读等），例如 declare -i num=10 声明为整数。

- typeset：declare 的别名（部分系统）。

- local *变量*=*值*：在函数内部定义局部变量。

- unset *变量*：删除变量或函数。

- set：显示或设置 Shell 变量和选项。
  ```bash
  set -e # 任何命令失败立即退出。
  set -u # 使用未定义变量时退出。
  set -x # 打印每条执行的命令。
  set -o pipefail # 管道中任一命令失败则整体失败。
  ```
  
- shift *n*：将位置参数左移 *n* 位（默认 1）。

- getopts *optstring* *var* *args*：解析命令行选项（用于脚本参数解析）。args 默认为 \$@（所有位置参数）。如果遇到非法选项或缺少参数，则设置 var 为 ?（或 :，若处于静默模式）并设置 OPTARG 为错误信息。

  *optstring* 的语法：
  - 普通字母：表示一个无参数选项，如 a 表示接受 -a。
  - 字母后跟冒号 :：表示该选项需要一个参数，如 b: 表示 -b value。
  - 开头的冒号 :：如果 *optstring* 以 : 开头，则 getopts 进入静默错误模式，不自动打印错误信息，由用户自行处理。
  
  变量：
  - OPTARG：保存当前选项的参数值（如果该选项需要参数）。
  - OPTIND：保存下一个要处理的参数在位置参数中的索引。初始值为 1，每次调用 getopts 后更新。
  
  示例 1：
  ```bash
  # ./script.sh -a -b hello
  
  while getopts "ab:" opt; do
     case $opt in
         a)
             echo "选项 -a 被指定"
             ;;
         b)
             echo "选项 -b 被指定，参数为：$OPTARG"
             ;;
         ?)
             echo "无效选项或缺少参数"
             exit 1
             ;;
        esac
  done
  ```
  
  示例 2：
  ```bash 
  # ./script.sh -a
  
  while getopts ":a:b:" opt; do
      case $opt in
          a)
              echo "-a 参数：$OPTARG"
              ;;
          b)
              echo "-b 参数：$OPTARG"
              ;;
          :)
              echo "选项 -$OPTARG 缺少参数"
              exit 1
              ;;
          ?)
              echo "未知选项：-$OPTARG"
              exit 1
              ;;
      esac
  done
  ```
  
  示例 3：
  ```bash
  # ./script.sh -v -n Alice file1 file2
  
  while getopts "vn:" opt; do
      case $opt in
          v) verbose=1 ;;
          n) name="$OPTARG" ;;
      esac
  done
  
  shift $((OPTIND - 1)) # 移除已解析的选项，剩余位置参数作为普通参数。
  
  echo "verbose = $verbose"
  echo "name = $name"
  echo "剩余参数：$@"
  ```
- echo *字符串*：输出文本到标准输出。支持 -n（不换行）、-e（解释转义字符）。
- printf *格式* *参数*...：按格式输出，功能比 echo 更强大，类似 C 语言 printf。
- read *变量*：从标准输入读取一行并赋值给变量。常用 -p（提示）、-a（读入数组）。
- readarray、mapfile：将文本行读入数组。例如 `readarray lines < file.txt`。
- eval *参数*：将参数作为 Shell 命令重新解析执行。常用于动态构建命令。eval "ls -l"。
- exec *命令*：用指定命令替换当前 Shell 进程（不创建子进程）。若不含命令则用于重定向。
- source *文件* 或 . *文件*：在当前 Shell 中读取并执行脚本，不启动子进程。
- command *命令*：执行命令，并绕过函数或别名。常用 command -v 检查命令是否存在。command -v ls 输出 ls 的路径。
- builtin *内置命令*：强制执行 Bash 内置命令，即使有同名函数或别名。
- hash：管理命令哈希表，加速外部命令查找。
- enable：启用或禁用内置命令。
- times：显示当前 Shell 及子进程的用户、系统、CPU、时间。
- jobs：列出当前 Shell 的后台作业。
- fg *作业号*：将后台作业切换到前台运行。
- bg *作业号*：将暂停的后台作业继续在后台运行。
- kill *信号* 作业号/进程号：向作业或进程发送信号。内置 kill 支持作业号（如 %1）。
- wait *进程号、作业号*：等待指定进程或作业结束，并返回其退出状态。
- disown *作业号*：将作业从作业表中移除，使其不受 Shell 退出影响。
- suspend：挂起当前 Shell（类似 Ctrl+Z）。
- test *表达式*：条件测试，返回 0（真）或 1（假）。
- [ *表达式* ]：test 的等价形式，注意方括号两侧必须有空格。
- [[ *表达式* ]]：Bash 扩展测试，支持正则、模式匹配，更安全灵活。
- history：显示命令历史列表。常用 -c 清空历史。
- fc：编辑并重新执行历史命令。
- alias *别名*=*命令*：创建或显示别名。
- unalias *别名*：删除别名。
- ulimit：设置或显示资源限制（如文件大小、内存等）。
- trap *命令列表* *信号列表*：捕获信号并执行指定命令。trap 'echo "收到 SIGINT"; exit' INT。
- let：执行算术运算（类似 \$(( ))）。
- :：空命令，永远返回 0。常用于占位或无限循环。: > file.txt 清空文件。
- true：返回 0。
- false：返回 1。
- logout：退出登录 Shell。
- caller：返回当前子程序调用的上下文信息。

### 2.1.1 umask

umask *选项* *去除权限数字*：（User file-creation mode mask，用户文件创建模式掩码），查看或指定创建文件（夹）时，从默认权限中“拿走”哪些权限。永久修改 umask 值，需要将 umask 命令写入 Shell 的配置文件中。

选项：
- -S：以更易读的符号形式打印当前模式掩码。

## 2.2 关键字

- if、then、elif、else、fi：条件分支结构。
- for、while、until、do、done：循环结构。
- case、esac：多分支选择结构。
- break：跳出当前循环。
- continue：跳过本次循环剩余部分，进入下一次循环。
- return *n*：从函数中返回，可带退出状态码。
- exit *n*：退出当前 Shell 或脚本，可带退出状态码。
- function：定义函数（也可省略）。

## 2.3 变量与环境

- 普通 Shell 变量：只在当前 Shell 中有效。
  - 定义变量：*变量名*=*值*。
  - 引用变量：\$变量名、\${变量名}。
- 环境变量：可传递给子进程。
- 常见环境变量：
  - PATH：命令搜索路径。
  - HOME：当前用户主目录。
  - USER：当前用户名。
  - PWD：当前工作目录。
  - OLDPWD：上一个工作目录。
  - PS1：主提示符。
  - PS2：续行提示符。
  - IFS：内部分隔符。
  - RANDOM：随机数。
  - LINENO：当前脚本行号。
  - BASH_VERSION：Bash 版本号。
- 特殊变量：
  - !!：代表上一条命令。
  - !\$：表示上一条命令的最后一个参数。
  - \$0：脚本名。
  - \$1~\$9：位置参数。
  - \$#：参数个数。
  - \$?：上一条命令的退出状态。
  - \$\$：当前 Shell 的 PID。
  - \$!：最后一个后台进程的 PID。
  - \$@：所有位置参数（每个独立）。
  - \$*：所有位置参数（作为单个字符串）。

## 2.4 配置文件

- /etc/profile：全局登录 Shell 配置。
- /etc/bash.bashrc：全局交互式 Shell 配置。
- ~/.bash_profile：用户登录 Shell 配置。
- ~/.bash_login：用户登录 Shell 配置（备用）。
- ~/.profile：用户登录 Shell 配置（备用）。
- ~/.bashrc：用户交互式 Shell 配置。
- ~/.bash_logout：用户退出登录 Shell 时执行。
- 配置文件读取顺序：
  - 登录 Shell，例如通过 TTY、SSH 或 bash --login：
    1. /etc/profile
    2. ~/.bash_profile、~/.bash_login、~/.profile（三选一）
  - 交互式 Shell，在已登录的图形界面中打开终端模拟器（如 GNOME Terminal、Konsole 等）或执行 bash 命令启动的子 Shell：
    1. /etc/bash.bashrc（如果存在）
    2. ~/.bashrc
  - 非交互式 Shell，当 Bash 用于执行脚本（如 bash script.sh 或直接运行 ./script.sh）时：
    1. 仅当设置了 BASH_ENV 时读取该变量指定的文件。
  - 以 sh 调用（POSIX）登录：
    1. ./etc/profile
    2. ~/.profile
  - 以 sh 调用（POSIX）交互式：
    1. 若设置了 ENV，则读取该变量指定的文件。

## 2.5 索引数组与关联数组

- 索引数组：
  ```bash
  arr=(apple banana cherry)
  echo ${arr[0]} # apple
  echo ${#arr[@]} # 数组长度。
  ```
- 关联数组：
  ```bash
  declare -A person
  person[name]="小明"
  person[age]=20
  echo ${person[name]}
  ```

## 2.6 运算符

- 算术运算符：+  -  *  /  %  ** ++ -- ?:。
   ```bash
   a=10
   b=3
   echo $((a + b)) # 13
   echo $((a ** b)) # 1000
   
   let "a = 5 + 3"
   echo $a
   
   b=$(expr 5 + 3)
   echo $b
   ```
- 字符串比较运算符：
   - =、==：字符串相等。
   - !=：字符串不相等。
   - -z：字符串为空。
   - -n：字符串非空。
   - \<：按字典序小于（需转义或在 [[ ]] 中使用）。
   - \>：字典序大于。
   - =~：正则比较，例如 [[ "abc123" =~ ^[a-z]+[0-9]+\$ ]]。
- 整数比较运算符：
   - -eq：等于。
   - -ne：不等于。
   - -gt：大于。
   - -ge：大于等于。
   - -lt：小于。
   - -le：小于等于。
- 文件测试运算符：
   - -e：文件存在。
   - -f：是普通文件。
   - -d：是目录。
   - -r：可读。
   - -w：可写。
   - -x：可执行。
   - -s：文件非空。
   - -L：是符号链接。
- 逻辑运算符：
   - &&：逻辑与。
   - ||：逻辑或。
   - !：逻辑非。

## 2.7 条件判断与循环

```bash
# 根据命令列表中最后一个命令的退出状态码来决定条件真假。
if 条件; then
    命令
elif 条件; then
    命令
else
    命令
fi

if test -f /etc/passwd; then
    echo "存在"
fi

# 等价写法。
if [ -f /etc/passwd ]; then
    echo "存在"
fi

if [[ $str == *.txt ]]; then
    echo "是 txt 文件"
fi
```

```bash
case 变量 in
    模式1)
        命令
        ;;
    模式2)
        命令
        ;;
    *)
        默认命令
        ;;
esac

read -p "输入 yes/no: " answer
case $answer in
    yes|y)
        echo "你选择了是"
        ;;
    no|n)
        echo "你选择了否"
        ;;
    *)
        echo "无效输入"
        ;;
esac
```

```bash
for 变量 in 列表; do
    命令
done

for i in 1 2 3 4 5; do
    echo $i
done

# 使用范围。
for i in {1..10}; do
    echo $i
done

# C 风格。
for ((i=0; i<5; i++)); do
    echo $i
done

for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break # 跳出循环。
    fi
    if [ $i -eq 3 ]; then
        continue # 跳过本次循环。
    fi
    echo $i
done
```

```bash
while 条件; do
    命令
done

count=1
while [ $count -le 5 ]; do
    echo "count = $count"
    ((count++))
done
```

```bash
# 条件为假时执行，直到条件为真时退出。
until 条件; do
    命令
done
```

## 2.8 函数

```bash
函数名() {
    命令
    return 返回值
}

# 或者。
function 函数名 {
    命令
}

# 函数内部使用 $1、$2 等获取参数。
greet() {
    local name="$1"
    echo "你好，$name"
}

# 输出结果供调用者捕获。
add() {
    echo $(( $1 + $2 ))
}
result=$(add 3 5)
echo "3 + 5 = $result"
```

## 2.9 重定向

```bash
command > file # 标准输出覆盖写入。
command >> file # 标准输出追加写入。
command 2> file # 错误输出覆盖写入。
command 2>&1 # 错误输出合并到标准输出。
command < file # 从文件读取输入。
```

## 2.10 管道

将一个命令的标准输出直接作为另一个命令的标准输入：

```bash
ls -l | grep ".txt"
ps aux | awk '{print $2}'
cat file.txt | sort | uniq
```

## 2.11 参数扩展

```bash
var="Hello World"

echo ${#var} # 长度：11
echo ${var:0:5} # 截取：Hello
echo ${var/World/Bash} # 替换：Hello Bash
echo ${var,,} # 转小写：hello world
echo ${var^^} # 转大写：HELLO WORLD

# 默认值。
echo ${unset_var:-默认值} # 若变量未设置则使用默认值。
echo ${unset_var:=默认值} # 若变量未设置则赋值并使用。

# 字符串拼接。
var2="abc"$var"123"
```

## 2.12 通配符与 Globbing

```bash
*.txt # 匹配所有 .txt 文件。
? # 匹配单个字符。
[abc] # 匹配 a、b 或 c。
[0-9] # 匹配数字。
[!0-9] # 匹配非数字。
```

## 2.13 命令行展开

- ~：当前用户的家目录。等同于 \$HOME。
- ~*用户名*：指定用户的家目录。例如 ~root 会展开为 /root。
- ~+：当前工作目录。等同于 \$PWD 变量。
- ~-：上一个工作目录，等同于 \$OLDPWD 变量（如果已设置）。
- ~*N*：目录栈中的目录。*N* 为数字，对应 dirs 命令显示的目录栈位置。

## 2.14 命令分组

作用是把多条命令打包成一条复合命令。  
语法 `{ cmd1; cmd2; }`。  
`{` 后面必须有空格（或换行），`}` 前面必须有 ;（或换行）。

# 三、命令

## 3.1 系统信息与硬件探查

### 3.1.1 lscpu

### 3.1.2 free

### 3.1.3 uptime

### 3.1.4 vmstat

### 3.1.5 sar

### 3.1.6 lsblk

### 3.1.7 lspci

### 3.1.8 dmidecode

### 3.1.9 uname

uname *选项*...：打印当前系统的基本信息。

选项：
-a、--all：显示所有信息。
-s、--kernel-name：显示内核名称。
-n、--nodename：显示网络主机名。
-r、--kernel-release：显示内核发行号。
-v、--kernel-version：显示内核版本。
-m、--machine：显示机器硬件名称。
-p、--processor：显示处理器类型。
-i、--hardware-platform：显示硬件平台。
-o、--operating-system：显示操作系统名称。

### 3.1.10 who

### 3.1.11 printenv

### 3.1.12 lshw

### 3.1.13 inxi

### 3.1.14 neofetch

### 3.1.15 dmesg

### 3.1.16 lsusb

## 3.2 系统时间、本地化与服务管理

### 3.2.1 localectl

### 3.2.2 timedatectl

### 3.2.3 date

### 3.2.4 hwclock

### 3.2.5 systemctl

### 3.2.6 journalctl

### 3.2.7 tzselect

## 3.3 用户、组与密码管理

### 3.3.1 useradd

### 3.3.2 usermod

### 3.3.3 userdel

### 3.3.4 groupadd

### 3.3.5 groupmod

### 3.3.6 groupdel

### 3.3.7 id

### 3.3.8 passwd

### 3.3.9 newgrp

### 3.3.10 chown

### 3.3.11 chgrp

### 3.3.12 visudo

### 3.3.13 su

### 3.3.14 gpasswd

gpasswd *选项* *组*：管理组成员。

选项：
- -a、--add *用户*：向组中添加用户。
- -d、--delete *用户*：移除组中的用户。

## 3.4 文件权限与属性

### 3.4.1 chmod

chmod *选项*... *模式* *文件*...：修改文件（夹）访问权限。

选项：
- -R：递归处理，对目录及其所有子目录和文件应用相同权限。
- -v：显示每个文件的权限修改详情。
- c：类似 -v，但仅显示有更改的文件。

模式表示方式：
- 符号模式；标示：u 属主、g 属组、o 其它、a 所有，可以组合；操作符：+ - =；权限 r w x s t。例如 chmod ug=rw,o=r *file*。
- 数字模式；用三位或四位八进制数字表示。表示特殊权限、所有者、所属组、其他用户的权限，每个占三比特。

示例：
```bash
find /var/www/html -type d -exec chmod 755 {} +
find /var/www/html -type f -exec chmod 644 {} +
```

### 3.4.2 chattr

### 3.4.3 lsattr

### 3.4.4 stat

## 3.5 文件与目录基础操作

### 3.5.1 ls

ls *选项*... *文件*...：列出文件信息，默认当前工作区。

示例：
```bash
alias ll='ls -l --author -b --color=auto --classify=always --group-directories-first -a -i -s --time=mtime --time-style="+%Y-%m-%d %H:%M:%S.%3N %z"'
```

ll 输出列的含义：
1. inode 索引节点号，文件在文件系统中的唯一数字标识符。
1. 文件占用的磁盘块数。
1. 文件类型与权限。
1. 硬链接数，对于目录，表示其子目录数量（含 . 和 ..）；对于文件，表示指向该 inode 的硬链接个数。
1. 文件所有者。
1. 文件所属组。
1. 文件的作者。
1. 文件大小。
1. 文件修改时间。
1. 文件名与分类标识符，/ 表示目录，* 表示可执行文件，普通文件无后缀符号。

### 3.5.2 ln

ln *选项*... *目标*... *链接名*：创建链接。

选项：
- -s：创建符号链接。
- -f：强制覆盖已存在的目标文件。
- -i：覆盖前询问确认。
- -n：当目标链接指向目录时，将其视为普通文件处理。
- -t *目录*：指定目标存放的目录。

### 3.5.3 find

find *路径* *选项* *表达式*：搜索文件，执行处理操作。

选项：
- -maxdepth *层级数*：控制搜索层级。

表达式：
- -name *名称*：按名称搜索精确查找。*名称*可使用通配符 *。
- -iname *名称*：按名称搜索忽略大小写。
- -type *关键字*：按文件类型搜索。*关键字*：d 文件夹、f 文件、l 链接。
- -size *表达式*：按文件大小搜索。+100M 大于一百兆的文件、-1K 小于一 K 的文件。10M 文件大小刚好 10M。
- -mtime *表达式*：-7 查找最近7天内修改的文件。
- -atime *表达式*：+30 查找超过30天未被访问的文件。
- -ctime *表达式*：1 查找恰好一天前修改的文件。
- -perm *权限*：755 查找权限为 755 的文件。
- -user *用户*：查找属于指定用户的文件。
- -group *组*：查找属于指定组的文件。
- -o：逻辑或。
- !：逻辑非。
- -exec *操作*：对结果执行操作命令。例如 exec rm {} \; ，{} 代表被找到的每一个文件，\; 表示命令的结束。

### 3.5.4 tar

tar *选项*... *文件*...：将多个文件打包成一个文件包，或解包文件包。

操作参数：
-c、--create：创建一个新的归档文件。
-x、--extract：提取归档文件。
-t、--list：列出归档文件的内容。
-r、--append：向已存在的归档文件中追加新文件。
-u、--update：仅将比归档中更新的文件追加进去。

选项：
-f：指定归档文件的文件名。
-v：显示处理过程中的详细信息。
-z：通过 gzip 进行压缩或解压。
-j：通过 bzip2 进行压缩或解压。
-J：通过 xz 进行压缩或解压。
-C：指定解压的目标目录。
--exclude：在创建归档时，排除指定的文件或模式。例如 --exclude='*.log'。

### 3.5.5 zip

zip *选项* *archive.zip* *files*...

选项：
- -r：递归压缩。压缩整个目录 `zip -r archive.zip myfolder/`。
- -x *模式*...：压缩时排除某些文件。例如 `zip -r archive.zip myfolder/ -x "*.log" "*.tmp"`。
- -*n*：设置压缩级别。默认是 -6。例如
  ```shell
  zip -9 -r archive.zip myfolder/   # 最大压缩（速度慢）
  zip -0 -r archive.zip myfolder/   # 仅存储，不压缩（速度快）
  ```
- -UN=*字符集*：压缩时使用指定字符编码。例如 `zip -r -UN=UTF-8 archive.zip myfolder/`。
- -q：安静模式。
- -e：创建带密码的压缩包。会提示输入密码。
- -P *密码*：创建带密码的压缩包。

### 3.5.6 unzip

unzip *选项* *archive.zip*

选项：
- -d：解压到指定目录，不存在会自动创建。。例如 `unzip archive.zip -d /path/to/target/`。
- -l：查看压缩包内容。例如 `unzip -l archive.zip`。
- -x *模式*...：解压时排除某些文件。例如 `unzip archive.zip -x "*.log"`。
- -q：安静模式。
- -P *密码*：解压带密码的压缩包。
- -O *字符集*：指定编码。例如 `unzip -O GBK archive.zip`。

### 3.5.7 cp

### 3.5.8 mv

### 3.5.9 rm

### 3.5.10 mkdir

### 3.5.11 touch

### 3.5.12 rsync

## 3.6 文本查看与交互编辑

### 3.6.1 vi

vi *选项*... *文件*：编辑文件。

移动光标：
- hjkl：左上下右移动光标，可以使用 30j 或 30↓ 的组合按键。
- ^：光标移至本行首字符。
- \$：光标移至本行尾字符。
- gg：跳转到首行。
- G：跳到行尾。
- :*n*：移动到第 *n* 行。
- *n*G：跳转到第 *n* 行。
- *n*w 光标移至后 *n* 个单词首字母。
- *n*b 光标移至前 *n* 个单词首字母。
- *n*e 光标移至后 *n* 个单词尾字母。
- ctrl+f：前一页。
- ctrl+b：后一页。
- ctrl+u：前半页。
- ctrl+d：后半页。
- ctrl+n：切换左侧类目树。
- ctrl+]：函数跳转。
- ctrl+o：函数跳回。
- tab：选择 ycm 实时补全选项。
- v：进入字符可视模式。
- shfit+v：进入行可视模式。
- ctrl+v：进入块可视模式。

编辑文本：
- x：删除光标所在处的字符。
- *n*x：删除包含光标处以后 *n* 个字符。
- *n*dw：剪切包含光标处 *n* 个单词（含空格）。
- *n*de：剪切包含光标处 *n* 个单词（不含空格）。
- d^：剪切从光标字符到行首。
- d$：剪切从光标字符到行尾。
- dd：剪切光标所在的整行。
- *n*dd：删除从当前行开始的 *n* 行。
- y^：复制光标到行首。
- y$：复制光标到行尾。
- yy：复制光标所在的整行。
- *n*yy：复制从当前行开始的 *n* 行。
- *n*yw：复制包含光标处 *n* 个单词（含空格）。
- *n*ye：复制包含光标处 *n* 个单词（不含空格）。
- p：将复制剪切的内容粘贴到光标之后。
- P：将复制剪切的内容粘贴到光标之前。
- r：修改替换当前光标字符。
- *n*J：合并当前行以下 *n* 行内容。
- u：撤销上次更改。
- U：取消对当前行进行的所有操作。
- ctrl+r：撤销上一个动作。
- .：重复上次动作。

搜索与替换：
- /字符串：从光标处向下搜索。
- ?pattern：从光标处向上搜索。
- n：查找下一个。
- N：反向查找下一个。
- :s/*old*/*new*/g：将当前行中的所有 *old* 替换为 *new*。
- :*n*,*m*s/*old*/*new*/g：将第 *n* 行到第 *m* 行中的所有 *old* 替换为 *new*。
- :%s/*old*/*new*/g：整个文件内的替换。
- :s/*old*/*new*/c：替换时需要确认。
- :*n*,*m*y：*n* 行到 *m* 行之间的文本，:100,200y，100 行到 200 的内容。

进入编辑：
- i：从当前光标处。
- I：从当前行首。
- a：从当前光标后。
- A：从当前行末。
- o：从当前行下插入新行。
- O：从当前行上插入新行。
- c^：删除当前光标（不包括）之前到行首的字符。
- c$：删除当前光标到行尾的字符。
- cw：删除当前光标到所在单词尾部字符。
- Esc：退出编辑。

其他：
- :set nu：显示行号。
- :set nonu：取消显示行号。
- :set nohlsearch：取消搜索高亮。
- :w：保存文件。
- :q：退出。
- :! *命令*：临时退出。
- :q!：强制退出。
- :qa!：退出，不保存。

### 3.6.2 more

more *选项*... *文件*...：在终端上查看文件内容。

选项：
- -d：在屏幕底部显示操作提示。
- -*数字*：指定每屏显示的行数。
- +*数字*：从指定的行号开始显示。
- +/*字符串*：在文件中搜索指定字符串，并从第一次出现该字符串的位置开始显示。
- -s：将文件中的多个连续空白行压缩为一行显示。

交互式操作命令：
- 回车键：向下滚动一行。
- 空格键：向下滚动一屏。
- b：向上滚动一屏。
- /字符串：向下搜索指定的字符串。
- n：重复上一次的搜索操作。
- v：使用 vi 编辑器编辑当前文件。
- =：显示当前所在的行号。
- q：退出。
- h：显示所有可用交互命令的帮助信息。

### 3.6.3 less

less *选项*... *文件*...：查看文本文件内容。

选项：
- -N：显示每行的行号。
- -S：不换行显示超长行。
- -p *字符串*：打开文件后，直接跳转到第一次出现该字符串的位置。
- -i：搜索时忽略大小写。
- -s：将多个连续的空行合并为一行显示。
- -m：在底部显示百分比进度信息。
- -F：如果文件内容少于一屏，不进入 less 界面。
- -R：输出原始控制字符，用于显示彩色文本。

交互式操作命令：
- 空格键、PageDown：向下翻一页。
- b、PageUp：向上翻一页。
- 回车键、j、↓：向下滚动一行。
- k、↑：向上滚动一行。
- g：跳转到文件开头。
- G：跳转到文件末尾。
- /*字符串*：向前搜索。
- ?*字符串*：向后搜索。
- n：跳到下一个搜索匹配项。
- N：跳到上一个搜索匹配项。
- :n：切换到下一个文件。
- :p：切换到上一个文件。
- h：显示帮助菜单。
- v：打开编辑器编辑。
- q：退出。

### 3.6.4 head

head *选项*... *文件*...：输出文件的开头部分，默认显示文件的前 10 行。没指定文件或者文件为 - ，就从标准输入读取。

选项：
- -c [-]*字节数*：显示文件前面*字节数*字节内容；负数表示不展示文件最后*字节数*字节的内容，其余内容都展示。
- -n [-]*行数*：显示文件前面*行数*行内容；负数表示不展示文件最后*行数*行内容，其余行内容都展示。
- -q：不打印文件名。指定多个文件时，会打印文件名作为头部。

### 3.6.5 tail

tail *选项*... *文件*...：显示文件末尾的内容，默认输出最后 10 行。没指定文件或者文件为 - ，就从标准输入读取。

选项：
- -c [+]*字节数*：展示文件尾部*字节数*字节内容；加号表示从*字节数*字节处开始展示。
- -n [+]*行数*：展示文件尾部*行数*行内容；加号表示从*行数*行开始展示。
- -f=name、descriptor：实时输出新增内容。
- -F：等于 -f=name --retry。
- --retry：文件不可访问时持续尝试打开。
- -q：不打印文件名。指定多个文件时，会打印文件名作为头部。
- --pid=*pid*：当指定进程结束后自动退出。

### 3.6.6 cat

### 3.6.7 tac

### 3.6.8 nano

## 3.7 文本处理与流编辑

### 3.7.1 sed

sed *选项* *脚本* *文件*... ：对文本查找、替换和删除处理。逐行读取输入，对于每一行，依次执行脚本中所有地址条件满足的命令，然后输出结果。  
省略文件时，从标准输入读取。  
如果斜线 `/` 匹配冲突可以换成别的符号作分割符。  
脚本由地址、命令和参数组成。  
在脚本文件中，`#` 开头的行是注释。

选项：
- -n：取消默认输出，只输出显式打印的内容。
- -e *脚本*：添加一个脚本（可多次使用）。
- -f *脚本文件*：从文件读取脚本。
- -i *后缀*：直接修改文件（可备份为后缀）。
- -E、-r：使用扩展正则表达式（ERE）。
- -u：无缓冲输出（GNU sed）。

地址：
- *N*：第 *N* 行，例如 5d 删除第五行。
- \$：最后一行。
- /*正则*/：正则匹配的行。
- *n*,*m*：第 *n* 到第 *m* 行。
- /*正则1*/,/*正则2*/：扫描到匹配*正则1*的行开始，到匹配*正则2*的行结束。若没到文件末尾，继续这样规则的地址匹配。
- *N*,$：第 *N* 到最后一行。
- *地址*!：与*地址*不匹配的行。
- 省略地址，表示处理所有行。

命令：
- s/*原内容*/*新内容*/*标志*：替换文本。支持正则表达式。
  标志：
  - g：全局替换。
  - p：打印替换成功的行。
  - i：忽略大小写。
  - *数字*：替换第 n 次出现。
- d：删除当前行，立即开始下一行。
- p：打印当前行。
- =：打印当前行号。
- l：以可见形式打印（显示控制字符、行尾）。
- a：在匹配行后追加文本。例如 a\abc。
- i：在匹配行前插入文本。例如 i\abc。
- c：用文本替换整行。例如 c\abc。
- r：在匹配行后读取并插入文件内容。例如 r 文件。
- w：将匹配行写入文件（覆盖）。例如 w 文件。
- R：每次读取一行文件内容，逐行追加到输出（GNU sed 扩展）。例如 R 文件。
- W：将当前模式空间写入文件，但不关闭文件（GNU sed 扩展）。例如 W 文件。
- n：输出当前行（除非 -n），读取下一行到模式空间。
- N：追加下一行到模式空间（用换行符连接）。
- P：打印模式空间的第一部分（到第一个换行符为止）。
- D：删除模式空间的第一部分，若模式空间还有内容则重新开始脚本。
- q：退出 sed（可带退出码，如 q10）。
- b：无条件跳转到标签。例如 b 标签。
- t：如果最近一次替换成功，跳转到标签。例如 t 标签。
- :：定义标签。
- h：将模式空间复制到保持空间。
- H：将模式空间追加到保持空间。
- g：将保持空间复制到模式空间。
- G：将保持空间追加到模式空间。
- x：交换模式空间和保持空间的内容。
- {}：命令分组。多个命令需要作用于同一地址。
  ```sed
  地址 {
      命令1
      命令2
      ...
  }
  地址 { 命令1; 命令2; }
  ```

### 3.7.2 awk

awk *选项*... *'模式 { 操作 }'* *文件*...：文本处理。逐行扫描文本，一行为一记录，按分隔副分隔记录为若干字段；模式匹配记录，执行定义的操作。  
省略模式，则默认处理所有行。  
省略操作，则默认为 {print} 打印整行。

选项：
- -F *分割符或者正则*：指定字段分隔符号。
- -f *程序文件*：指定使用逻辑文件。

字段与变量：
- \$0：代表当前行的全部内容。
- \$1、\$2、...：代表当前行的第 1、第 2 到第 N 个字段。
- NF (Number of Fields)：当前行的字段总数。\$NF 代表最后一个字段。
- NR (Number of Records)：当前处理的行号（从 1 开始）。
- FNR (File Number of Records)：当前文件行号，记录的是正在处理的当前这个文件内部的行数。
- FS (Field Separator)：输入字段分隔符，默认为空白字符（空格或 Tab）。
- OFS (Output Field Separator)：输出字段分隔符，默认为一个空格。
- RS (Record Separator)：输入记录分隔符，默认为换行符。
- ARGC：命令行参数的个数。
- ARGV：存放命令行参数的数组。索引从 0 到 ARGC-1。ARGV[0] 通常指向 awk 命令本身；ARGV[1] 到 ARGV[ARGC-1] 通常是输入文件名。

赋值操作符：
++ -- += -= *= /= %= ^=

关系操作符：
\< \> <= >= == != ~ !~ || && !

- =：变量声明
- BEGIN{}：在读取文件前执行，用于初始化变量和设置分隔符。
- END{}：所有行处理完后执行，常用于输出汇总信息。
- if() else if() else
- while()
- do{}while()
- for(;;)
- for(v in array)
- delete array[index]
- break continue
- sin() cos() int() rand() srand()
- gsub(r,s,t) sub(r,s,t) substr(s,p,n) index(s,t) length(s) match(s,r) split(s,a,sep)
- function name(params){ return result }

示例：
```bash
# 打印整行。
awk '{print}' file.txt
awk '{print} $0' file.txt

# 打印第一列和第三列。
awk '{print $1, $3}' file.txt

# 打印第十行。
awk 'NR==10 {print}' file.txt

# 打印第 5 到第 10 行。
awk 'NR>=5 && NR<=10' file.txt

# 打印所有包含 error 的行。
awk '/error/' file.txt

# 打印所有不包含 success 的行。
awk '!/success/' file.txt

# # 打印第 3 列以 192 开头的行。
awk '$3 ~ /^192/' file.txt

# 打印第 3 列数值大于 100 的行。
awk '$3 > 100' file.txt

# 打印第 2 列等于 admin 的行。
awk '$2 == "admin"' file.txt

# 对第一列求和。
awk '{sum += $1} END {print "总和:", sum}' file.txt

# 计算第二列平均值。
awk '{sum += $2; count++} END {print "平均值:", sum/count}' file.txt

# 统计空白行数。
awk '/^$/ {blank++} END {print "空白行数:", blank}' file.txt

# 以 Tab 分隔输出第 1、3 列。
awk 'BEGIN{OFS="\t"} {print $1, $3}' file.txt

# 统计中第三列（部门）对应的第四列（销售额）的总和。
awk '{dept[$3] += $4} END {for (d in dept) print d, "总销售额:", dept[d]}' file.txt

# 将第一列转为大写，并打印整行。
awk '{$1 = toupper($1)}' file.txt

# 转换为JSON格式片段。
awk '{printf "\t\"%s\":\"%s\",\n", $1, $2}' file.txt
```

### 3.7.3 grep

grep *选项*... *模式* *文件、文件夹*...

选项：
- -i：忽略大小写。
- -r、-R：递归搜索目录。
- -n：显示匹配行的行号。
- -v：反向匹配。
- -c：只输出匹配行的数量。
- -l：只输出包含匹配的文件名。
- -w：匹配整个单词。
- -x：匹配整行。
- -E：使用扩展正则表达式。
- -A *num*：显示匹配行及之后 *num* 行。
- -B *num*：显示匹配行及之前 *num* 行。
- -C *num*：显示匹配行及前后各 *num* 行。
- -e *模式*、--regexp=*模式*：指定多个模式，或逻辑。
- -f *文件*：从文件中读取模式。
- --include=*模式*：递归搜索文件时，按*模式*过滤。例如 `grep -r --include="*.txt" "TODO" ./`。
- --exclude=*模式*：递归搜索文件时，按*模式*排除文件。
- --exclude-dir=*模式*：递归搜索文件时，按*模式*排除文件夹。

### 3.7.4 tee

tee *选项*... *文件*...：将标准输入内容复制到文件中，同时输出到标准输出。

选项：
- -a、--append：内容追加到文件尾部。

### 3.7.5 xargs

### 3.7.6 cut

### 3.7.7 sort

### 3.7.8 uniq

### 3.7.9 tr

### 3.7.10 wc

### 3.7.11 diff

## 3.8 软件包管理与仓库创建

### 3.8.1 dpkg

### 3.8.2 apt

## 3.9 进程管理与控制

### 3.9.1 ps

- -p *pid*：指定线程 ID。
- -o args=：显示线程命令行。
- a：显示与终端关联的所有用户进程。
- x：显示没有控制终端的进程（如守护进程）。
- -e：显示所有进程。
- -C *cmd*：显示命令名完全匹配 *cmd* 的进程。
- -u *user*：显示指定用户（用户名或 UID）的进程。
- -L：显示线程（轻量级进程）信息。
- u：用户导向格式。

### 3.9.2 top

### 3.9.3 kill

### 3.9.4 killall

### 3.9.5 nice

### 3.9.6 renice

### 3.9.7 nohup

### 3.9.8 pstree

### 3.9.9 htop

### 3.9.10 glances

### 3.9.11 pkill

### 3.9.12 pidof

## 3.10 定时、一次性任务调度

### 3.10.1 crontab

### 3.10.2 at

### 3.10.3 atq

### 3.10.4 atrm

### 3.10.5 systemd-timers

### 3.10.6 watch

## 3.11 网络配置与诊断

### 3.11.1 nmcli

### 3.11.2 ip

### 3.11.3 ifup

### 3.11.4 ifdown

### 3.11.5 ss

ss *选项*... *过滤*：查看套接字。

- -t：仅显示 TCP 套接字。
- -u：仅显示 UDP 套接字。
- -x：仅显示 Unix 域套接字。
- -l：仅显示正在监听的套接字
- -a：显示所有套接字，包括监听和非监听的。
- -n：显示数字形式的 IP 地址和端口号，不解析为服务名（如 22 显示为 22 而非 ssh）。
- -p：显示使用该套接字的进程信息（PID 和进程名），通常需要 sudo 权限。
- -s：显示套接字统计信息的摘要。
- -4、-6：分别只显示 IPv4 或 IPv6 的套接字。

示例：
```shell
# 显示所有与 SSH 服务（端口22）相关的 TCP 连接。
ss -at '( dport = :ssh or sport = :ssh )'

# 显示所有连接到目标 IP 192.168.1.100 的套接字。
ss dst 192.168.1.100

# 显示所有连接到远程端口 443（HTTPS）的连接。
ss -t dst :443

# 显示所有连接到 10.0.0.0/24 网段的连接。
ss dst 10.0.0.0/24

# 查看本机发起的或指向远程 22 端口的 TCP 连接。
ss -t dst :22
```

### 3.11.6 route

### 3.11.7 nslookup

### 3.11.8 ping

### 3.11.9 traceroute

### 3.11.10 curl

curl *选项*... *URL*：支持多种协议，HTTP、HTTPS、FTP、SFTP、SMTP 等。

选项：
- -o *文件*：将内容保存为指定文件名。
- -O：使用 URL 中的文件名保存。
- -L：跟随重定向。
- -X、--request：指定请求方法。
- -d、--data *内容*：发送数据（自动使用 POST 方法）。
- --data-urlencode *内容*：对数据进行 URL 编码后发送。
- -F、--form *内容、文件*：模拟表单提交（multipart/form-data）。例如 `-F "file=@/path/to/file.txt"`。
- -H、--header *键值对*：添加自定义请求头。例如 `-H "Content-Type: application/json"`。
- -i：在输出中包含响应头。
- -u、--user：基本认证。例如 `-u username:password`。
- -x、--proxy *地址*：通过代理服务器访问。支持 SOCKS 代理。
- -c *文件*：将服务器返回的 Cookie 保存到文件。
- -b *文件*：发送本地保存的 Cookie。
- -k、--insecure：跳过证书验证。
- --limit-rate *大小*：限制下载、上传速度，单位可为 K、M、G。例如 `--limit-rate 200K`。
- -v、--verbose：显示完整的请求、响应过程，包括握手信息。
- --connect-timeout *秒数*：连接超时时。
- --max-time *秒数*：整个操作的最大耗时。
- --retry *次数*：失败后自动重试次数。
- -T *文件*：上传文件到远程服务器。例如 `curl -T localfile.txt ftp://ftp.example.com/ --user user:pass`。
- -#：显示简单进度条。
- -s：静默模式。
- -w *模式*：输出自定义格式的变量。例如 `curl -o /dev/null -s -w "HTTP Code: %{http_code}\nTime: %{time_total}s\n" https://example.com`。

### 3.11.11 wget

### 3.11.12 dig

### 3.11.13 host

### 3.11.14 iptables

iptables *选项* *链名* *匹配条件*：配置、管理和检查数据包过滤和规则。  
表：raw → mangle → nat → filter。  
链：PREROUTING → INPUT → FORWARD → OUTPUT → POSTROUTING。  

数据包处理顺序：
- 入站数据包：网络接口 → PREROUTING（raw，mangle，nat） → 路由决策 → INPUT（mangle，filter） → 本地进程。
- 转发数据包：网络接口 → PREROUTING（raw，mangle，nat） → 路由决策 → FORWARD（mangle，filter） → POSTROUTING（mangle，nat） → 网络接口。
- 出站数据包：本地进程 → 路由决策 → OUTPUT（raw，mangle，nat，filter） → POSTROUTING（mangle，nat） → 网络接口。

目标：
- ACCEPT：接受数据包。
- DROP：丢弃数据包，不回应。
- REJECT：拒绝数据包，并返回错误信息（如 ICMP port unreachable）。
- LOG：记录日志（通过 syslog）。
- SNAT：源地址转换（修改源 IP）。
- DNAT：目的地址转换（修改目的 IP）。
- MASQUERADE：动态源地址转换（适用于动态 IP 场景）。

选项：
- -t *表*：指定表，默认是 filter。
- -A *链*：在链末尾追加一条规则。
- -I *链* *规则编号*：在链开头或指定编号插入规则。
- -D *链* *规则编号或规则内容*：删除一条规则。
- -R *链* *规则编号* *新规则*：替换指定编号的规则。
- -L *链* 列出规则，可加 -v（详细）、-n（数字形式）。
- -S *链*：以命令语法形式查看规则。
- -F *链*：清空链或所有链的规则。
- -P *链* *目标*：设置链的默认策略（如 ACCEPT、DROP）。
- -N *链*：新建自定义链。
- -X *链*：删除自定义链。
- -Z *链*：清空计数器。
- -p *协议*：指定协议（tcp、udp、icmp、all）。
- -s *地址*：源地址，如 192.168.1.0/24。
- -d *地址*：目的地址。
- --sport *端口*：源端口（需 -p tcp/udp）。
- --dport *端口*：目的端口。
- -i *接口*：入接口（如 eth0）。
- -o *接口*：出接口。
- -m *模块*：使用扩展匹配模块（如 multiport、state、limit）。
- --state *状态*：匹配连接状态（NEW、ESTABLISHED、RELATED、INVALID）。
- -j *目标*：跳转目标（ACCEPT、DROP、REJECT、LOG、SNAT、DNAT 等）。
- --to-source *地址*：用于 SNAT，指定源地址。
- --to-destination *地址*：用于 DNAT，指定目的地址。

示例：
```shell
# 默认拒绝所有入站流量。
iptables -P INPUT DROP

# 默认允许出站流量。
iptables -P OUTPUT ACCEPT

# 不默认允许转发。
iptables -P FORWARD DROP

# 允许所有已建立或相关的连接进入。
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 允许回环接口通信。
iptables -A INPUT -i lo -j ACCEPT
```

## 3.12 内核模块管理

### 3.12.1 modprobe

### 3.12.2 modinfo

### 3.12.3 lsmod

### 3.12.4 insmod

### 3.12.5 rmmod

### 3.12.6 depmod

## 3.13 磁盘存储与 LVM

### 3.13.1 pvcreate

### 3.13.2 pvdisplay

### 3.13.3 pvremove

### 3.13.4 pvchange

### 3.13.5 vgcreate

### 3.13.6 vgdisplay

### 3.13.7 vgchange

### 3.13.8 vgextend

### 3.13.9 vgreduce

### 3.13.10 vgremove

### 3.13.11 lvcreate

### 3.13.12 lvresize

### 3.13.13 lvextend

### 3.13.14 lvreduce

### 3.13.15 lvremove

### 3.13.16 lvchange

### 3.13.17 fdisk

### 3.13.18 parted

### 3.13.19 gdisk

### 3.13.20 lsblk

## 3.14 文件系统操作与挂载

### 3.14.1 mkfs

### 3.14.2 mount

### 3.14.3 umount

### 3.14.4 blkid

### 3.14.5 resize2fs

### 3.14.6 e2fsck

### 3.14.7 df

### 3.14.8 du

### 3.14.9 fsck

### 3.14.10 xfs_growfs

## 3.15 Shell 环境与执行器

### 3.15.1 bash

bash *选项*... *参数*...

选项：
- -c *命令*：新开子 Shell 执行一条命令。
- -x：开启调试模式，逐行打印执行过程。
- --norc：跳过配置文件 .bashrc 启动一个新的子 Shell 环境。
- -n：仅检查语法不执行。
- -v：显示读取的每一行。
- -e：遇到错误停止运行。

### 3.15.2 sh

### 3.15.3 zsh

## 3.16 图形、X11 相关

### 3.16.1 xprop

xprop *选项*...：查看和修改 X 服务器中窗口的属性。  
窗口标题（WM_NAME）、窗口类（WM_CLASS）和窗口状态（WM_STATE）。  
当不带任何选项运行时，xprop 会将鼠标指针变为一个十字准星，提示你点击一个窗口来查看其所有属性。

*选项*：
- -id *id*：通过窗口 ID 选择目标窗口。
- -name *name*：通过窗口名称选择目标窗口。
- -root：选择 X 服务器的根窗口（桌面）。
- -frame：选择窗口管理器框架，而非客户区窗口。
- -spy：持续监控窗口属性变化。
- -set *prop* *value*：设置指定属性的值。
- -remove *prop*：删除指定属性。
- -f *atom* *format*：指定属性的格式，用于 -set 等操作。

### 3.16.2 xrandr

### 3.16.3 xdotool

### 3.16.4 xdpyinfo

## 3.17 安全、密码字典工具

### 3.17.1 cracklib-unpacker

### 3.17.2 create-cracklib-dict

### 3.17.3 pwgen

### 3.17.4 mkpasswd
