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
else ifeq ($(OS), Linux)
    SHELL := /bin/sh
    CC := gcc
    EXE_SUFFIX :=
    OBJ_SUFFIX := .o
    CFLAGS_COMMON := -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 \
                     -Wpedantic -Winline -Wall -Wextra \
                     -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedef -Wno-unused-parameter
    CFLAGS_DEBUG := $(CFLAGS_COMMON) -O0 -g3
    CFLAGS_RELEASE := $(CFLAGS_COMMON) -O3 -DNDEBUG -flto
    LDFLAGS_DEBUG :=
    LDFLAGS_RELEASE := -flto
    OUT_OBJ = -c -o $@
    OUT_EXE = -o $@
else
    $(error 不支持的操作系统 $(OS)：仅支持 Linux 和 Windows，终止运行)
endif


$(info $$(CC) $(CC))
$(info $$(MAKE) $(MAKE))
$(info $$(SHELL) $(SHELL))
$(info $$(OS) $(OS))


TARGET := c
TARGET_DEBUG := $(TARGET)-debug
TARGET_RELEASE := $(TARGET)-release
SOURCES := $(sort $(wildcard *.c *.C))
SOURCES += bitwise/bitwise.c
DEBUG_OBJECTS := $(addprefix debug/, $(patsubst %.c,%$(OBJ_SUFFIX),$(patsubst %.C,%$(OBJ_SUFFIX),$(SOURCES))))
RELEASE_OBJECTS := $(addprefix release/, $(patsubst %.c,%$(OBJ_SUFFIX),$(patsubst %.C,%$(OBJ_SUFFIX),$(SOURCES))))
BUILD_DIRS := $(sort $(patsubst %/,%,$(dir $(DEBUG_OBJECTS) $(RELEASE_OBJECTS))))
ifeq ($(OS), Windows_NT)
    DUMMY := $(shell $(foreach d,$(subst /,\,$(BUILD_DIRS)),if not exist "$(d)" mkdir "$(d)" &) rem)
    CLEAN_COMMAND := if exist debug rmdir /s /q debug & if exist release rmdir /s /q release \
                     & if exist $(TARGET_DEBUG)$(EXE_SUFFIX) del /f /q $(TARGET_DEBUG)$(EXE_SUFFIX) \
                     & if exist $(TARGET_RELEASE)$(EXE_SUFFIX) del /f /q $(TARGET_RELEASE)$(EXE_SUFFIX) \
                     & if exist $(TARGET_DEBUG).pdb del /f /q $(TARGET_DEBUG).pdb
else
    DUMMY := $(shell mkdir -p $(BUILD_DIRS))
    CLEAN_COMMAND := rm -rf debug/ release/ $(TARGET_DEBUG)$(EXE_SUFFIX) $(TARGET_RELEASE)$(EXE_SUFFIX) \
                     $(TARGET_DEBUG).pdb $(TARGET_RELEASE).pdb
endif

$(info $$(SOURCES) $(SOURCES))


.PHONY: debug release all clean format-code


debug/%$(OBJ_SUFFIX): %.c
	@$(CC) $(CFLAGS_DEBUG) $(OUT_OBJ) $<


release/%$(OBJ_SUFFIX): %.c
	@$(CC) $(CFLAGS_RELEASE) $(OUT_OBJ) $<


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
debug: $(TARGET_DEBUG)$(EXE_SUFFIX)
release: $(TARGET_RELEASE)$(EXE_SUFFIX)
