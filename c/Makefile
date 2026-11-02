ifeq ($(OS), Windows_NT)
    SHELL := cmd.exe
    CC := cl.exe
    EXE_SUFFIX := .exe
    OBJ_SUFFIX := .obj
    # /nologo：不显示编译器版本/版权横幅
    # /std:c17：按 ISO C17 标准编译（MSVC 以 -std:c17 对齐 gcc 的 -std=c17）
    # /utf-8：源码与执行字符集均按 UTF-8 处理（对应 gcc 的 -finput-charset/-fexec-charset=UTF-8）
    # /D_CRT_SECURE_NO_WARNINGS：关闭 MSVC CRT 安全函数（scanf 等）的 C4996 弃用警告
    # /W4：最高告警级别，等价于 gcc 的 -Wall -Wextra
    # /wd4100：忽略 C4100：函数中未被引用的形参（对应 gcc 的 -Wno-unused-parameter）
    # /wd4189：忽略 C4189：局部变量已初始化但未被引用（对应 -Wno-unused-variable）
    # /wd4505：忽略 C4505：已定义但从未被调用的局部函数（对应 -Wno-unused-function）
    # /Od：禁用优化（debug 默认）
    # /Z7：把调试信息直接写入 .obj，不生成独立 .pdb（等价于 gcc 的 -g）
    # /O2：最大化速度优化（对应 gcc 的 -O2/-O3）
    # /GL：全程序优化 / LTO（配合链接阶段的 /LTCG）
    # /DNDEBUG：定义 NDEBUG，使 assert 失效（对应 gcc 的 -DNDEBUG）
    # /LTCG：链接时代码生成，与编译期的 /GL 配套做跨目标文件优化
    # /c：只编译不链接，生成目标文件（对应 gcc 的 -c）
    # /Fo:$@：指定目标文件名（对应 gcc 的 -o $@）
    # /Fe:$@：指定链接产出的可执行文件名（对应 gcc 的 -o $@）
    CFLAGS_COMMON := /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505
    CFLAGS_DEBUG := $(CFLAGS_COMMON) /Od /Z7
    CFLAGS_RELEASE := $(CFLAGS_COMMON) /O2 /GL /DNDEBUG
    LDFLAGS_DEBUG := /nologo
    LDFLAGS_RELEASE := /nologo /LTCG
    OUT_OBJ = /c /Fo:$@
    OUT_EXE = /Fe:$@
    ifneq ($(shell where cl.exe >nul 2>&1 && echo yes),yes)
        $(info Searching MSVC)
        VSWHERE := $(shell echo "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe")
        VSPATH := $(shell "$(VSWHERE)" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)
        VSPATH := $(strip $(VSPATH))
        ifeq ($(VSPATH),)
            $(error 未找到 cl.exe，且无法通过 vswhere 定位 Visual Studio；请安装 VS/Build Tools 或在开发者命令提示符中运行)
        endif
        VCVARS := $(VSPATH)\VC\Auxiliary\Build\vcvars64.bat
        export INCLUDE := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !INCLUDE!")
        export LIB := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIB!")
        export LIBPATH := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIBPATH!")
        export PATH := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !PATH!")
        $(info "Searching MSVC end")
    endif
else
    SHELL := sh
    CC := gcc
    EXE_SUFFIX :=
    OBJ_SUFFIX := .o
    # -std=c17：按 ISO C17 标准编译（对应 MSVC 的 /std:c17）
    # -finput-charset=UTF-8：声明源文件字符集为 UTF-8，供预处理器/编译器正确解读源码
    # -fexec-charset=UTF-8：把窄字符串/字符字面量按 UTF-8 编码写入目标文件（对应 MSVC 的 /utf-8）
    # -Wpedantic：对非严格符合 C 标准的代码给出警告（依赖 -std=c17 生效）
    # -Winline：函数被声明为 inline 却未能真正内联时给出警告
    # -Wall：启用一组常用告警
    # -Wextra：在 -Wall 基础上启用额外告警（对应 MSVC 的 /W4）
    # -Wno-unused-variable：忽略“局部/静态变量已定义但未使用”的告警（对应 /wd4189）
    # -Wno-unused-function：忽略“静态函数已定义但未调用”的告警（对应 /wd4505）
    # -Wno-unused-local-typedefs：忽略“局部 typedef 已定义但未使用”的告警
    # -Wno-unused-parameter：忽略“函数形参未使用”的告警（对应 /wd4100）
    # -O0：禁用优化，便于调试（debug 默认）
    # -g3：生成最详细的调试信息，含宏定义（对应 MSVC 的 /Z7）
    # -O3：开启最激进的优化（对应 MSVC 的 /O2）
    # -flto：链接时优化 / LTO，编译与链接阶段均需开启（对应 MSVC 的 /GL /LTCG）
    # -DNDEBUG：定义 NDEBUG，使 assert 失效（对应 MSVC 的 /DNDEBUG）
    CFLAGS_COMMON := -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 \
                     -Wpedantic -Winline -Wall -Wextra \
                     -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter
    CFLAGS_DEBUG := $(CFLAGS_COMMON) -O0 -g3
    CFLAGS_RELEASE := $(CFLAGS_COMMON) -O3 -DNDEBUG -flto
    LDFLAGS_DEBUG :=
    LDFLAGS_RELEASE := -flto
    OUT_OBJ = -c -o $@
    OUT_EXE = -o $@
endif


$(info $$(CC) $(CC))
$(info $$(MAKE) $(MAKE))
$(info $$(SHELL) $(SHELL))
$(info $$(OS) $(OS))


TARGET := c
BUILD_DIR := build/
TARGET_DEBUG := $(TARGET)-debug
TARGET_RELEASE := $(TARGET)-release
SOURCES := $(sort $(wildcard *.c *.C))
SOURCES += bitwise/bitwise.c
DEBUG_OBJECTS := $(addprefix $(BUILD_DIR)/debug/, $(patsubst %.c,%$(OBJ_SUFFIX),$(patsubst %.C,%$(OBJ_SUFFIX),$(SOURCES))))
RELEASE_OBJECTS := $(addprefix $(BUILD_DIR)/release/, $(patsubst %.c,%$(OBJ_SUFFIX),$(patsubst %.C,%$(OBJ_SUFFIX),$(SOURCES))))
ifeq ($(OS), Windows_NT)
    CLEAN_COMMAND := if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR) \
                     & if exist $(TARGET_DEBUG)$(EXE_SUFFIX) del /f /q $(TARGET_DEBUG)$(EXE_SUFFIX) \
                     & if exist $(TARGET_RELEASE)$(EXE_SUFFIX) del /f /q $(TARGET_RELEASE)$(EXE_SUFFIX) \
                     & if exist $(TARGET_DEBUG).pdb del /f /q $(TARGET_DEBUG).pdb
else
    CLEAN_COMMAND := rm -rf $(BUILD_DIR) $(TARGET_DEBUG)$(EXE_SUFFIX) $(TARGET_RELEASE)$(EXE_SUFFIX) \
                     $(TARGET_DEBUG).pdb $(TARGET_RELEASE).pdb
endif
$(info $$(SOURCES) $(SOURCES))


.PHONY: debug release all clean format-code


.SECONDEXPANSION:


$(BUILD_DIR)/debug/%$(OBJ_SUFFIX): %.c | $$(dir $$@)
	@$(CC) $(CFLAGS_DEBUG) $(OUT_OBJ) $<


$(BUILD_DIR)/release/%$(OBJ_SUFFIX): %.c | $$(dir $$@)
	@$(CC) $(CFLAGS_RELEASE) $(OUT_OBJ) $<


ifeq ($(OS), Windows_NT)
%/:
	@if not exist "$(subst /,\,$@)" mkdir "$(subst /,\,$@)"
else
%/:
	@mkdir -p $@
endif


$(TARGET_DEBUG)$(EXE_SUFFIX): $(DEBUG_OBJECTS)
	@$(CC) $(LDFLAGS_DEBUG) $(OUT_EXE) $^
	@echo build debug done


$(TARGET_RELEASE)$(EXE_SUFFIX): $(RELEASE_OBJECTS)
	@$(CC) $(LDFLAGS_RELEASE) $(OUT_EXE) $^
	@echo build release done


clean:
	@$(CLEAN_COMMAND)
	@echo clean done


format-code:
	@clang-format -i $(SOURCES)
	@echo format-code done


all: $(TARGET_RELEASE)$(EXE_SUFFIX)
build-debug: $(TARGET_DEBUG)$(EXE_SUFFIX)
build-release: $(TARGET_RELEASE)$(EXE_SUFFIX)
