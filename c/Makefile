CC := clang

# 打印变量值。
$(info $$(CC) $(CC))
$(info $$(MAKE) $(MAKE))
$(info $$(SHELL) $(SHELL))
$(info $$(OS) $(OS))


# -std=c17：指定 C17 语言标准（即 ISO/IEC 9899:2018，clang 中 c18 为 c17 的别名）。
# -finput-charset=UTF-8：指定源文件字符集为 UTF-8。
# -fexec-charset=UTF-8：指定窄字符/字符串字面量的执行字符集为 UTF-8。
# -Wall：开启一组常用、低误报的告警。
# -Wextra：在 -Wall 基础上额外开启一组告警（未使用参数、符号比较等）。
# -Wpedantic：开启标准合规性告警（对超出标准、依赖编译器扩展的用法发出警告）。
# -Winline：开启 inline 相关告警（如 inline 函数声明却未定义）。
# -Wno-unused-variable：关闭“未使用变量”告警。
# -Wno-unused-function：关闭“未使用函数”告警。
# -Wno-unused-local-typedef：关闭“未使用局部 typedef”告警。
# -Wno-unused-parameter：关闭“未使用参数”告警。
# -Wno-unused：关闭一组“未使用”告警（变量、函数、标签、值等，不含参数）。
# -O0：关闭优化。
# -O1：开启一级优化（基础优化，兼顾编译速度与可调试性）。
# -O2：开启二级优化（大多数常用优化）。
# -O3：开启三级优化（更激进的优化，如自动向量化、更激进内联），编译更慢、代码更大，追求极致运行速度。
# -Os：体积优先优化（在尽量减小代码体积的前提下优化）。
# -flto：开启链接时优化（LTO），跨翻译单元优化，通常配合 -O2/-O3 使用。
# -fdebug-macro：在调试信息中生成宏定义信息（-g3 需配合此项才有宏信息）。
# -fcolor-diagnostics：强制输出彩色诊断信息（即使输出不是终端）。
# -fno-color-diagnostics：关闭彩色诊断输出（即使输出到终端）。
# -pthread：定义 _REENTRANT 并链接 pthread 线程库。
# -static：静态链接，生成不依赖共享库的可执行文件。
# -shared：生成共享库（.so）。
# -w：关闭所有告警。
# -Werror：把所有告警升级为错误（出现告警即编译失败）。
# -Werror=<组>：把指定告警组升级为错误（如 -Werror=unused-variable）。
# -g0：不生成调试信息。
# -g1：生成最小调试信息（仅行号表，只能定位行号）。
# -g2：生成完整调试信息（局部变量、类型、源码行等，等价于 -g）。
# -g3：生成最详细调试信息（与 -g2 同为完整调试信息；宏调试信息需额外加 -fdebug-macro）。
# -DNDEBUG：定义宏 NDEBUG（用于关闭 assert 等调试代码）。
# -I：添加头文件搜索路径（供 #include 查找）。
# -L：添加链接库搜索路径（供链接器查找 lib*.a/lib*.so）。
# -l：链接库 lib<name>.a 或 lib<name>.so。
CFLAGS_COMMON := -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra \
                 -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedef -Wno-unused-parameter
CFLAGS_DEBUG := $(CFLAGS_COMMON) -O0 -g3 -fdebug-macro
CFLAGS_RELEASE := $(CFLAGS_COMMON) -O3 -g0 -DNDEBUG -flto
TARGET := c
SOURCES := $(shell ls | grep -E '(\.c$$)|(\.C$$)')
SOURCES += bitwise/bitwise.c
DEBUG_OBJECTS := $(addprefix debug/, $(SOURCES:.c=.o))
RELEASE_OBJECTS := $(addprefix release/, $(SOURCES:.c=.o))
CLEAN_COMMAND := rm -rf debug/ release/ $(TARGET)-debug $(TARGET)-debug.exe $(TARGET)-release $(TARGET)-release.exe
$(info $$(CFLAGS_DEBUG) $(CFLAGS_DEBUG))
$(info $$(CFLAGS_RELEASE) $(CFLAGS_RELEASE))
$(info $$(SOURCES) $(SOURCES))
$(info $$(DEBUG_OBJECTS) $(DEBUG_OBJECTS))
$(info $$(RELEASE_OBJECTS) $(RELEASE_OBJECTS))
$(info $$(CLEAN_COMMAND) $(CLEAN_COMMAND))


.PHONY: debug release all clean format-code


# 编译每个源代码（debug 版本）。
debug/%.o: %.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS_DEBUG) -c -o $@ $<


# 编译每个源代码（release 版本）。
release/%.o: %.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS_RELEASE) -c -o $@ $<


# 链接代码（debug 版本）。
$(TARGET)-debug: $(DEBUG_OBJECTS)
	@$(CC) $(CFLAGS_DEBUG) -o $@ $^
	@echo 'build debug done'


# 链接代码（release 版本）。
$(TARGET)-release: $(RELEASE_OBJECTS)
	@$(CC) $(CFLAGS_RELEASE) -o $@ $^
	@echo 'build release done'


clean:
	@$(CLEAN_COMMAND)
	@echo 'clean done'


# 格式化所有源文件（-i 原地修改）。依赖 clang-format 工具。
format-code:
	@clang-format -i $(SOURCES)
	@echo 'format-code done'


all: $(TARGET)-release
debug: $(TARGET)-debug
release: $(TARGET)-release
