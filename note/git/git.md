# 一、笔记

1. 官网 https://git-scm.com/。
1. Git 源码包中的命令补齐脚本 `contrib/completion/git-completion.bash` 复制到 `/etc/bash_completion.d/` 对应的目录中。重新加载自动补齐脚本，使之在当前的 shell 中生效 `. /etc/bash_completion`。
1. ![](./工作区、版本库、暂存区原理图.jpeg)

# 二、文件说明

- `.git/COMMIT_EDITMSG` 保存了上次的提交日志。
- `.git/info/exclude` 忽略文件信息。
- `.git/packed-refs` 打包的引用信息。
- `$HOME/.gitconfig` 全局配置文件。
- `/etc/gitconfig` 系统配置文件。
- `.git/config` 版本库配置文件。

# 三、各类型 SHA1 ID 计算规则：

## 3.1 Commit

1. git cat-file commit HEAD | wc -c
1. (printf "commit <字数>\000"; git cat-file commit HEAD) | sha1sum

## 3.2 Blob

1. git cat-file blob HEAD:a.txt | wc -c
1. (printf "blob <字数>\000"; git cat-file blob HEAD:a.txt) | sha1sum

## 3.3 Tree

1. git cat-file tree HEAD^{tree} | wc -c
1. (printf "tree <字数>\000"; git cat-file tree HEAD^{tree}) | sha1sum

## 3.4 Tag

1. git cat-file tag v2.0.0 | wc -c
1. (printf "tag <字数>\000"; git cat-file tag v2.0.0) | sha1sum

# 四、对象格式

- `HEAD^`：HEAD 的父提交。
- `HEAD^^`：HEAD 的父提交的父提交。
- `HEAD^2`：HEAD 的父提交的父提交。
- `HEAD~2`：HEAD 的父提交的父提交。
- `HEAD^{tree}`：提交对应的树对象。
- `<commit-id>:<file-name>`：某一次提交对应的文件对象。
- `:<file-path>`：暂存区中的文件对象。
- `master@{2}`：master 两次改变之前的提交 ID。
- `<commit-id>..<commit-id>`：提交范围。不含前者，包含后者。
- `<commit-id>...<commit-id>`：两个版本共同能够访问到的除外。
- `:1:<file-path>`：选择文件。数字 1 是编号，当合并冲突时，文件有不同的版本。
- `git check-ref-format <ref-spec>`：检查引用名称是否符合规范，返回值为 0，则引用名称符合规范。

# 五、忽略文件的语法规则

- 空行或以井号（#）开始的行会被忽略。
- 可以使用通配符，参见 Linux 手册：glob（7）。例如：星号（*）代表任意多字符，问号（?）代表一个字符，方括号（[abc]）代表可选字符范围等。
- 如果名称的最前面是一个路径分隔符（/），表明要忽略的文件在此目录下，而非子目录的文件。
- 如果名称的最后面是一个路径分隔符（/），表明要忽略的是整个目录，同名文件不忽略，否则同名的文件和目录都忽略。
- 通过在名称的最前面添加一个感叹号（!），代表不忽略。

# 六、在 Debian 编译安装

```shell
cd ~/src/
git clone git@github.com:git/git.git -o github
sudo apt install libcurl4-openssl-dev zlib1g-dev libssl-dev libexpat1-dev gettext
make clean
make NO_DOC=1 NO_TCLTK=1 NO_RUST=1 prefix=~/programs/git install
```

# 七、设置访问远程仓库账密

1. 开启账密存储：`git config --global credential.helper store`。
1. 用户家目录下文件 `.git-credentials` 添加 `https://user:token@host.com`。`.netrc` 添加 `machine github.com login USERNAME password APIKEY`。

# 八、配置 ssh 网络代理

```shell
sudo apt install connect-proxy
vim .ssh/config
```
添加：
```txt
Host github.com
User git
ProxyCommand connect-proxy -S 127.0.0.1:7897 %h %p
```

# 九、命令样例

## 9.1 生成一个没有父提交的新提交对象

```shell
git cat-file commit <commit> | sed -e '/^parent/d' > tmpfile
git hash-object -t commit -w -- tmpfile
```

## 9.2 提取提交与回放

```shell
# 提取从 <起始提交> 之后（不含它）到 <结束提交> 的所有提交
git format-patch -o /path/to/patches/ <起始提交>..<结束提交>

# 在目标仓库中
git am /path/to/patches/*.patch
```

##  9.3 公钥密钥

- `ssh-keygen -t rsa -C <email>`：生成 RSA 密钥对。
- `ssh -T git@github.com`：测试与 GitHub 的 SSH 连接是否正常。

## 9.4 配置

- `git config set --global user.name ivfzhou`：设置全局用户名。
- `git config set --global user.email ivfzhou@126.com`：设置全局用户邮箱地址。
- `git config set --global alias.ci commit`：设置 Git 命令别名。例如设置后输入 `git ci` 即等同于 `git commit`。
- `git config set --global color.ui true`：在 Git 命令输出中开启颜色显示。
- `git config edit`：打开编辑器编辑当前仓库（local 级别）的配置文件。
- `git config edit --global`：打开编辑器编辑全局（global 级别）配置文件。
- `git config edit --system`：打开编辑器编辑系统级（system 级别）配置文件。
- `git config get <section>.<key>`：获取指定配置项的值。
- `git config unset <section>.<key>`：移除指定配置项。
- `git config list`：列出当前有效的所有配置项。
- `GIT_CONFIG=test.ini git config set a.b.c.d "hello,world"`：利用 Git 配置机制读写指定 ini 文件。
- `core.quotepath false`：关闭非 ASCII 字符（如中文文件名）的八进制转义显示。
- `i18n.logOutputEncoding gbk`：设置日志输出时提交说明所使用的字符编码为 GBK。
- `i18n.commitEncoding gbk`：设置录入提交说明时所使用的字符编码为 GBK。
- `core.fileMode false`：禁止 Git 跟踪文件的可执行权限变更。在此模式下，已入库文件的执行位变化不会被识别为新改动；新增文件统一以 100644 权限（忽略可执行位）加入版本库。
- `core.logallrefupdates`：控制是否记录引用更新日志（即 reflog）。默认在裸仓库中为 false，非裸仓库为 true。
- `core.excludesfile`：指定全局忽略文件的路径。
- `gc.auto`：调整自动垃圾回收（gc --auto）触发时的松散对象阈值，默认值为 6700；设为 0 则禁用自动整理。
- `receive.denyNonFastForwards true`：设置为 true 可禁止任何用户进行非快进式（non-fast-forward）推送。
- `http.sslVerify false`：关闭 HTTPS 连接时的 SSL 证书验证。
- `https.proxy https://proxyuser:password@proxyserver:port`：配置 HTTPS 协议的网络代理。
- `http.proxy http://proxyuser:password@proxyserver:port`：配置 HTTP 协议的网络代理。
- `remote.<origin>.skipDefaultUpdate true`：在执行 `git remote update` 时跳过该远程仓库的自动更新。
- `receive.denyDeletes true`：禁止通过推送操作删除远程分支。

## 9.5 初始化仓库

- `git init <dir>`：在指定目录下初始化一个空的 Git 版本库。
- `git clone <url> -o <origin> -b <branch> <dir>`：从远程 URL 克隆仓库到本地指定目录，可自定义远端名称和初始分支。

## 9.6 工作区与暂存区交互

- `git add <file>`：将指定文件添加到暂存区（staging area）。
- `git add .`：将工作区中所有修改和新增文件添加到暂存区。
- `git add -f <file>`：强制将被 `.gitignore` 忽略的文件添加到暂存区。
- `git add -u .`：将已追踪文件在工作区的修改更新到暂存区（不含未追踪的新文件）。
- `git checkout <filename>`：用暂存区的内容恢复指定文件，丢弃工作区对该文件的修改。
- `git checkout .`：用暂存区的内容恢复当前目录下所有文件，覆盖整个工作区的修改。
- `git rm --cached -rf <filename>`：从暂存区移除文件（保留工作区物理文件不受影响）。
- `git checkout .`：使用暂存区内容整体覆盖工作区，撤销所有未提交的改动。

## 9.7 暂存区与版本库交互

- `git commit -m <注释>`：将暂存区的内容提交到本地版本库，并附带提交说明。
- `git commit -am <注释>`：将工作区所有已追踪文件的修改一并提交至暂存区和本地版本库（仅限已追踪文件）。
- `git commit --amend -m <注释>`：修改最近一次提交的说明或内容，将其合并为一次新的提交。
- `git commit --allow-empty`：创建一个没有任何实际文件变动的空提交。
- `git reset <filename>`：将指定文件从暂存区撤回（用 HEAD 版本覆盖暂存区），工作区保持不变。
- `git commit -C <commit-id>`：复用指定提交的提交说明（message）和作者信息。

## 9.8 版本库操作

- `git reset --hard HEAD^`：硬重置到上一个版本，工作区、暂存区和版本库均被还原，所有未提交的改动将丢失。
- `git reset --hard <commitId>`：硬重置到指定提交版本，三区（工作区、暂存区、版本库指针）全部对齐到该版本。
- `git reset --soft <commitId>`：软重置到指定版本，仅移动 HEAD 指针，所有改动保留在暂存区待重新提交。
- `git reset --mixed HEAD^`：混合重置到上一版本，撤销暂存区的文件，但工作区文件改动保持不变（默认模式）。
- `git reset HEAD -- <file-path>`：仅将指定文件从暂存区撤出（unstage），工作区不受影响。
- `git revert <commit-id>`：新建一个提交来撤销指定提交引入的改动（不改变已有的历史提交记录）。
- `git checkout <branch> -- <file-path>`：从指定分支取出文件，覆盖当前分支的暂存区和工作区。
- `git cherry-pick <commit-id>`：将指定提交的改动"拣选"出来，在当前 HEAD 上重新应用为一个新提交。
- `git reset --hard ORIG_HEAD`：回到合并分支前的提交处。ORIG_HEAD 就是合并前的 HEAD。

## 9.9 查看

- `git status -s`：以简洁格式显示工作区与暂存区的状态（已暂存、已修改、未追踪等）。
- `git ls-tree <commit-id>`：查看指定提交对应的目录树结构（包含文件列表及其模式）。
- `git ls-tree -l HEAD`：查看 HEAD 指向的目录树，额外显示每个条目的文件大小。
- `git ls-files -s`：显示暂存区中文件的详细信息（含模式、哈希和 staged 状态）。
- `git cat-file -p <id>`：查看指定 Git 对象（blob/tree/commit/tag）的内容。
- `git cat-file -t <id>`：查看指定 Git 对象的类型（blob/tree/commit/tag）。
- `git cat-file commit HEAD`：查看 HEAD 所指向的 commit 对象的完整内容（含父提交、树、作者等）。
- `git blame <file>`：逐行显示指定文件每一行最后的修改人与提交信息。
- `git blame -L 6,+5 <file-name>`：查看文件第 6 行起共 5 行范围内的逐行 blame 信息。
- `git rev-parse HEAD`：解析并输出 HEAD 对应的完整提交 HASH 值。
- `git grep '关键词'`：在工作区代码库中按关键字搜索匹配的文本内容。
- `git rev-parse --git-dir`：显示版本库 `.git` 目录的绝对路径。
- `git rev-parse --show-toplevel`：显示工作区根目录的绝对路径。
- `git rev-parse --show-prefix`：显示当前目录相对于工作区根目录的相对路径。
- `git rev-parse --show-cdup`：显示从当前目录回退（cd up）到工作区根目录所需的层级深度。
- `git rev-parse master`：解析 master 引用并输出其对应的提交 ID。
- `git --version`：打印当前安装的 Git 版本号。
- `git rev-parse --git-dir`：显示版本库 `.git` 目录所在的绝对路径位置。
- `git rev-parse --show-toplevel`：显示当前工作区根目录的绝对路径。
- `git rev-parse --show-prefix`：显示当前目录相对于工作区根目录的相对路径前缀。
- `git rev-parse --show-cdup`：显示从当前目录后退（cd up）到工作区根目录所需的深度。
- `git rev-parse refs/heads/master`：解析 `refs/heads/master` 引用并输出对应的提交 ID。
- `git rev-parse HEAD`：解析 HEAD 并输出其指向的提交 ID。
- `git rev-parse HEAD:<file>`：解析并输出 HEAD 提交中指定路径所对应 blob 对象的 ID。
- `git rev-parse HEAD^{tree}`：解析并输出 HEAD 提交关联的树（tree）对象 ID。
- `git rev-parse HEAD^{tree}:<file-path>`：解析并输出 HEAD 目录树下指定路径文件的对象 ID。
- `git rev-parse --symbolic --branches`：列出所有本地分支的引用名称。
- `git rev-parse --symbolic --tags`：列出所有里程碑（tag）的引用名称。
- `git rev-parse --symbolic --glob=refs/*`：列出符合 glob 模式的所有引用。
- `git rev-parse master v1.0.1^{commit}`：一次性解析多个引用，分别输出各自对应的提交 ID。
- `git describe | xargs git rev-parse`：先通过 `git describe` 获取可读描述名，再解析为对应的提交 ID。
- `git rev-list HEAD`：按时间顺序列出从 HEAD 可达的所有提交记录。
- `git rev-list --oneline master`：以单行精简格式列出 master 分支上的所有提交记录。
- `git rev-list --oneline <commit-id> <commit-id>`：列出两个或多个提交各自可达的提交集的并集。
- `git rev-list --oneline ^<commit-id> <commit-id>`：列出后者可达但在前者中不可达的提交集（排除前者及其祖先）。
- `git rev-list --oneline <commit-id>..<commit-id>`：等价于两点语法，列出右端可达但左端不可达的提交。
- `git rev-list --oneline <commit-id>...<commit-id>`：三点语法，列出两端各自可达但共同祖先不可达的对称差集。
- `git rev-list --oneline <commit-id>^@`：列出指定提交的所有祖先提交（自身除外）。
- `git rev-list --oneline <commit-id>^!`：仅列出指定提交本身（不包括其任何祖先提交）。
- `git cat-file -t <ID>`：查看指定对象的类型（blob/tree/commit/tag）。
- `git cat-file -p <ID>`：查看指定对象的完整内容（pretty-print 格式）。
- `git cat-file blob HEAD:<file-path>`：查看 HEAD 提交中指定路径文件的原始内容。
- `git ls-tree -l HEAD`：查看 HEAD 目录树的文件列表及各条目的大小。
- `git ls-tree -l -r -t <ID>`：递归查看指定目录树的完整结构（含子目录和大小）。
- `git ls-files --stage`：查看暂存区（index）中文件的详细分阶段信息。
- `git ls-files`：列出暂存区和工作区中已追踪的所有文件。
- `git ls-files --with-tree HEAD^`：对比上一版本（HEAD^），列出暂存区中有差异的文件。
- `git write-tree`：将当前暂存区的目录树写入对象库，返回树对象的 ID。
- `git clean -nd`：预览将被清除的未追踪文件和目录（dry run 模式，并不实际执行删除）。
- `git clean -fd`：强制清除工作区中未被版本库跟踪的文件和目录。
- `git rm`：从版本库索引和工作区中删除指定文件。
- `git mv`：对版本库中的文件执行重命名或移动操作（Git 会自动检测此变更）。
- `git describe`：根据当前提交查找最近的 tag，生成一个可读的版本描述字符串。
- `git name-rev`：将提交 ID 转换为最接近的可读引用名称（如分支名或 tag 名）。
- `git show <object> --stat`：显示指定对象（提交、tag 等）的简要统计信息（变更文件列表及增删行数）。

## 9.10 远程分支

- `git remote -v`：列出当前仓库配置的所有远程仓库地址（含 fetch 和 push URL）。
- `git remote add <origin> <url>`：添加一个新的远程仓库，并命名为 origin。
- `git remote set-url <origin> <newurl>`：修改已命名远程仓库的 URL 地址。
- `git remote set-url --push <origin> <newurl>`：仅为 push 操作单独设置远程仓库的 URL 地址。
- `git remote rm <origin>`：移除名为 origin 的远程仓库配置。
- `git remote rename <origin> <newname>`：将远程仓库 origin 重命名为新名称。
- `git fetch --all`：从所有远程仓库拉取最新的分支和提交数据到本地远程跟踪分支。
- `git fetch <remote>`：从 *remote* 远程仓库拉取最新的分支和提交数据到本地远程跟踪分支。
- `git fetch --no-tags`：拉取远程分支及提交数据但不下载里程碑（tag）对象。
- `git ls-remote --heads <remote> <pattern>`：按模式过滤列出远程仓库的分支引用。
- `git ls-remote --tags <remote>`：列出远程仓库的所有标签（tag）引用。
- `git push <remote> <refspec>:<refspec>`：将本地引用推送到远程仓库并可指定远端目标引用名称。
- `git push <remote> <tag>`：将本地指定的单个 tag 推送到远程仓库。
- `git pull <remote> <refspec>`：从远程仓库拉取指定引用并合并到当前分支。
- `git pull origin refs/tags/mytag2:refs/tags/mytag2`：将远程仓库的 tag 引用拉取并覆盖本地同名 tag 引用。
- `git cherry`：查看当前分支有哪些提交尚未推送到上游跟踪分支（ahead 的提交数）。
- `git push <origin> :<branch-name>`：通过推送空引用的方式删除远程仓库中的指定分支。

## 9.11 里程碑

- `git tag --sort=-creatordate -l -n <pattern>`：按创建时间倒序列出匹配模式的 tag 及其注解。
- `git tag -d <tag>`：删除本地指定的 tag。
- `git tag`：显示当前版本库中的全部里程碑（tag）列表。
- `git tag -n <num>`：显示里程碑列表并同时附上最多 num 行的说明文字。
- `git tag -l v2.*`：使用通配符过滤并只显示名称匹配的里程碑。
- `git tag <tag> <HEAD>`：在当前 HEAD 位置创建一个轻量级（lightweight）里程碑。
- `git tag -u <key-id> -m <message> <tag>`：使用指定的 GPG 密钥签名创建一个带注解的里程碑。
- `git tag -v <tag>`：验证指定 tag 的 GPG 签名是否有效且可信。
- `git push <remote> :<tag>`：通过推送空引用删除远程仓库中的指定 tag。
- `git show <tag>`：查看指定 tag 的详细信息（包括关联的提交内容和注解）。

## 9.12 分支

- `git branch -v`：显示本地分支列表及每个分支最后一次提交的摘要信息。
- `git checkout <branch-name>`：切换工作区到指定的已有分支。
- `git checkout -b <branch-name> <start-point>`：基于指定起始点创建新分支并立即切换过去。
- `git branch -r`：列出所有远程跟踪分支（remote-tracking branches）。
- `git branch <branch-name>`：基于当前 HEAD 创建一个新的本地分支（不切换）。
- `git branch <branch-name> <strat-point>`：基于指定的起始点（提交或分支）创建新的本地分支。
- `git branch -d <branch-name>`：删除已合并的本地分支（安全删除，未合并时会拒绝）。
- `git branch -D <branch-name>`：强制删除本地分支（无论是否已合并）。
- `git branch -m <branch-name> <new-branch-name>`：重命名本地分支（目标不存在时使用）。
- `git branch -M <branch-name> <new-branch-name>`：强制重命名本地分支（若目标已存在则覆盖）。
- `git pull <origin> <branch>`：从远程 origin 的指定分支拉取变动并与当前本地分支合并。
- `git push -u <origin> <branch-name>`：推送本地分支到远程 origin 并建立上游（upstream）跟踪关系。
- `git push <origin> --tags`：将本地所有 tag 推送到远程仓库。
- `git push <origin> <tag-name>`：将本地指定的单个 tag 推送到远程仓库。
- `git push <origin> --all`：将本地所有分支推送到远程仓库。
- `git merge <branch-name>`：将指定分支合并到当前分支，并保留合并提交历史。

## 9.13 日志

- `git reflog`：查看 HEAD 引用的移动历史（包括被 reset 丢弃的提交等操作记录）。
- `git log --pretty=oneline`：每条提交显示为一行（提交 hash + 说明）。
- `git log --graph --pretty=oneline --abbrev=commit`：以图形化 ASCII 树形图 + 单行精简格式展示提交历史。
- `git log --oneline`：以最精简的单行格式（短 hash + 说明）展示提交记录。
- `git log --stat`：展示提交历史并在每次提交下方附加文件变更的统计信息（增删行数）。
- `git log --pretty=raw`：以原始格式显示提交详情，包含完整的父提交 ID 和 tree ID。
- `git log --pretty=fuller`：同时显示完整的作者信息（Author）和提交者信息（Committer）。
- `git log --graph --oneline`：以 ASCII 图形化单行方式直观地展示分支合并历史的拓扑结构。
- `git log -p`：显示提交历史并在每次提交下方附带具体的代码差异（patch/diff）。
- `git log --graph --pretty=raw stash`：以图形化原始格式查看 stash 引用相关的提交记录。
- `git log --decorate`：在输出的提交 hash 旁标注其所关联的引用名称（如分支名或 tag 名）。
- `git reflog show master`：查看 master 分支引用的变更历史记录。
- `git reflog show refs/stash`：查看 stash（暂存栈）引用的变更历史记录。
- `git reflog expire --expire=now --all`：立即过期清空所有 reflog 日志条目（`.git/logs/` 下文件将被清空）。
- `git log -n 5`：查看最近 5 条提交记录。

## 9.14 暂存

- `git stash`：将当前工作区的修改（含暂存区改动）临时保存到 stash 栈中，恢复工作区到干净状态。
- `git stash pop`：恢复 stash 栈顶保存的最近一次修改到工作区，并将其从栈中移除。
- `git stash apply`：恢复 stash 栈顶保存的修改到工作区（不从栈中删除，可重复应用）。
- `git stash list`：列出 stash 栈中所有已保存的暂存版本条目。

## 9.15 比较

- `git diff <file>`：比较指定文件在暂存区与工作区之间的差异。
- `git diff --cached <file>`：比较指定文件在最新提交（HEAD）与暂存区之间的差异。
- `git diff <commit-id> <file>`：比较指定文件在某个历史提交与当前工作区之间的差异。
- `git diff <a> <b> <file>`：比较指定文件在两个不同提交之间的差异。
- `git diff <branch> <branch> <file>`：比较指定文件在两个不同分支末梢之间的差异。
- `diff -u a.txt b.txt > diff.txt`：将两个文件之间的标准 unified 差异输出重定向保存为补丁文件。
- `patch a.txt diff.txt`：将补丁文件应用到 a.txt 文件使其变为 b.txt 文件的内容。
- `patch -R b.txt diff.txt`：以反向模式将补丁应用到 b.txt 文件使其还原为 a.txt 的内容。
- `git diff`：比较工作区与暂存区之间所有的差异（默认范围）。
- `git diff --word-diff`：以逐词粒度（而非逐行）展示差异，便于定位细微的文字改动。
- `git diff HEAD`：比较工作区与 HEAD 提交之间的所有差异（含暂存区和工作区的总改动）。
- `git diff --cached`：比较暂存区与 HEAD 提交之间的差异（即已 stage 但尚未 commit 的改动）。
- `git diff --cached <commit>`：比较暂存区与指定历史提交之间的差异。
- `git diff <commit> <commit> -- <file>`：显示指定文件在两个不同提交版本之间的内容差异。
- `git diff A...B`：找出 A 与 B 的共同祖先（merge base），然后显示从共同祖先到 B 的差异。
- `git format-patch -s <commit-id>..<commit-id>`：根据两个提交之间的差异生成可邮寄的标准邮件格式补丁文件。

## 9.16 查找提交

- `git bisect start`：启动二分查找流程，开始定位引入 bug 的提交。
- `git bisect bad`：将当前 HEAD 版本标记为"坏提交"（存在 bug 的版本）。
- `git bisect good <commit>`：将指定的已知正常版本标记为"好提交"（无 bug 的版本）。
- `git checkout bisect/bad`：切换到 bisect 当前标记的坏提交位置以便排查。
- `git bisect reset`：中止二分查找并将版本库切回到执行 bisect 之前所在的分支。
- `git bisect log > logfile`：将二分查找的过程日志导出保存到指定文件中。
- `git bisect replay logfile`：根据之前保存的日志文件恢复二分查找进度并重新开始。
- `git bisect run sh good-or-bad.sh`：自动化运行二分查找，由脚本判断每次测试版本的好坏。

## 9.17 变基

- `git rebase --onto <newbase> <since> <till>`：将从 `<since>` 到 `<till>` 之间的提交摘出，重新应用到 `<newbase>` 分支之上。
- `git rebase <base-branch>`：将当前分支自分歧点以来的所有提交逐一重新应用（replay）到 `<base-branch>` 之上。
- `git rebase --continue`：解决完冲突后将变基过程继续推进至下一个提交。
- `git rebase --skip`：跳过当前冲突提交不做任何修改，继续变基剩余的提交。
- `git rebase --abort`：完全中止变基操作并将版本库恢复到执行 rebase 之前的原始状态。

## 9.18 gnupg

- `gpg --list-keys`：列出当前系统可用的 GnuPG 公钥密钥环中的密钥。
- `gpg gen-key`：交互式地生成一对全新的 GnuPG 公钥和私钥。

## 9.19 归档

- `git archive -o <file> HEAD`：基于当前最新提交（HEAD）打包生成归档文件。
- `git archive -o <file> HEAD src doc`：基于 HEAD 打包归档，仅包含 src 和 doc 两个目录下的内容。
- `git archive --format=tar --prefix=1.0/ v1.0 | gzip > foo-1.0.tar.gz`：基于 v1.0 tag 创建 tar.gz 归档，并为内部文件统一添加 `1.0/` 目录前缀。

## 9.20 松散文件

- `git show-ref`：列出当前版本库中存在的所有引用（含分支、tag 等）及其对应的对象 ID。
- `git pack-refs --all`：将分散的松散引用文件打包合并到一个集中的 pack 文件中以提升性能。
- `git show-index < .git/objects/pack/pack-*.idx`：显示指定 pack 索引文件中所包含的全部对象及其偏移量。
- `git fsck`：检查版本库完整性，报告未被任何引用关联的孤立（dangling/orphan）松散对象。
- `git prune`：清理并永久删除所有未被任何引用关联到的松散对象以释放磁盘空间。
- `git gc`：执行垃圾回收操作，打包松散对象、清理无效引用并压缩优化版本库存储。

## 9.21 子模组

- `git submodule add <url> <dir>`：将外部仓库作为子模块添加到指定目录，并在 `.gitmodules` 中记录配置。
- `git submodule status`：显示各子模块的当前提交哈希、路径及状态摘要（与记录版本是否一致）。
- `git submodule init`：根据 `.gitmodules` 配置初始化子模块，在 `.git/config` 中完成本地注册。
- `git submodule update`：依据注册信息克隆缺失的子模块，或将其检出到记录的提交版本。

## 9.22 合并其它版本库

1. `git remote add <other-git> <url>`：添加其它版本库。
1. `git fetch <other-git>`：拉取数据。
1. `git checkout -b <branch-name1> <other-git/master>`：基于远程版本库创建分支。
1. `git read-tree --prefix=<dir> <branch-name1>`：将远程版本库文件写入暂存区。
1. `git checkout master`：切换原分支。
1. `git write-tree`：获取当前暂存区的树 ID。
1. `git rev-parse HEAD`、`git rev-parse <branch-name1>`：获取到提交 ID。
1. `git commit-tree <暂存区树 ID> -p <HEAD 提交 ID> -p <branch-name1 树 ID> -m <提交说明>`：创建树获取 ID。
1. `git reset <新树 ID>`：将版本库重置到新的树。
1. `git log`：查看其它版本库合并进来的日志。

# 十、同仓库不同分支使用不同 user 信息方案

## 10.1 使用 includeIf 和 onbranch

在 .git/ 下创建分支专属配置文件，例如 .git/\<branch\>-config：
```ini
[user]
    name = Your Personal Name
    email = personal@example.com
```
然后在仓库配置 .git/config 中添加：
```ini
[includeIf "onbranch:<branch>"]
    path = .git/<branch>-config
```
切换到分支 \<branch\>，查看 user 信息：
```shell
git config get user.name
git config get user.email
```

## 10.2 使用 git worktree

为分支创建工作目录：
```shell
git worktree add ../<repo>-<branch> <branch>
```
进入目录，查看 user 信息：
```shell
cd ../<repo>-<branch>
git config get user.name
git config get user.email
```

## 10.3 使用环境变量

在提交时设置环境变量：
```shell
GIT_AUTHOR_NAME="ivfzhou" GIT_AUTHOR_EMAIL="ivfzhou@126.com" GIT_COMMITTER_NAME="ivfzhou" GIT_COMMITTER_EMAIL="ivfzhou@126.com" git commit -m "message"
```

## 10.4 使用 pre-commit 钩子

在 .git/hooks/pre-commit 中编写脚本。
