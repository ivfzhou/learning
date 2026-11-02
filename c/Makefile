ifeq ($(OS), Windows_NT)
    SHELL := cmd.exe
    CC := cl.exe
    EXE_SUFFIX := .exe
    OBJ_SUFFIX := .obj
    # /wd4100 未使用形参；/wd4189 未使用局部变量；/wd4505 未使用局部函数（对应 gcc 的 -Wno-unused-*）
    CFLAGS_COMMON := /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505
    CFLAGS_DEBUG := $(CFLAGS_COMMON) /Od /Z7
    CFLAGS_RELEASE := $(CFLAGS_COMMON) /O2 /GL /DNDEBUG
    LDFLAGS_DEBUG := /nologo
    LDFLAGS_RELEASE := /nologo /LTCG
    OUT_OBJ = /c /Fo:$@
    OUT_EXE = /Fe:$@
    # 若 cl.exe 不在 PATH 中（未在 VS 开发者命令提示符下运行），
    # 则通过 vswhere 定位 vcvars64.bat，并将其配置好的环境变量导出给所有 recipe。
    ifeq ($(shell where cl.exe >nul 2>&1 && echo yes),yes)
        MSVC_ENV_READY := yes
    else
        VSWHERE := $(subst ",,$(shell echo "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"))
        VCVARS := $(strip $(shell "$(VSWHERE)" -latest -products * \
                   -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath))\VC\Auxiliary\Build\vcvars64.bat
        ifeq ($(VCVARS),)
            $(error 未找到 cl.exe，且无法通过 vswhere 定位 Visual Studio；请安装 VS/Build Tools 或在开发者命令提示符中运行)
        endif
        # 注意：需用 cmd /v:on 延迟展开（!VAR!），否则 %VAR% 会在 call 之前展开而取到旧值
        export INCLUDE := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !INCLUDE!")
        export LIB     := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIB!")
        export LIBPATH := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIBPATH!")
        export PATH    := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !PATH!")
        MSVC_ENV_READY := yes
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
    $(error "不支持的操作系统 $(OS)：仅支持 Linux 和 Windows，终止运行")
endif

# 用户自定义的额外链接参数（如 -pthread、-lm 等）。
LDFLAGS_EXTRA :=


$(info $$(CC) $(CC))
$(info $$(MAKE) $(MAKE))
$(info $$(SHELL) $(SHELL))
$(info $$(OS) $(OS))
$(info $$(CFLAGS_DEBUG) $(CFLAGS_DEBUG))
$(info $$(CFLAGS_RELEASE) $(CFLAGS_RELEASE))

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
                     & if exist $(TARGET_DEBUG).pdb del /f /q $(TARGET_DEBUG).pdb \
                     & if exist $(TARGET_RELEASE).pdb del /f /q $(TARGET_RELEASE).pdb
else
    DUMMY := $(shell mkdir -p $(BUILD_DIRS))
    CLEAN_COMMAND := rm -rf debug/ release/ $(TARGET_DEBUG) $(TARGET_RELEASE) \
                     $(basename $(TARGET_DEBUG)).pdb $(basename $(TARGET_RELEASE)).pdb
endif

$(info $$(SOURCES) $(SOURCES))
$(info $$(BUILD_DIRS) $(BUILD_DIRS))
$(info $$(CLEAN_COMMAND) $(CLEAN_COMMAND))


.PHONY: debug release all clean format-code


debug/%$(OBJ_SUFFIX): %.c
	@$(CC) $(CFLAGS_DEBUG) $(OUT_OBJ) $<


release/%$(OBJ_SUFFIX): %.c
	@$(CC) $(CFLAGS_RELEASE) $(OUT_OBJ) $<


$(TARGET_DEBUG)$(EXE_SUFFIX): $(DEBUG_OBJECTS)
	@$(CC) $(LDFLAGS_DEBUG) $(LDFLAGS_EXTRA) $(OUT_EXE) $^
	@echo build debug done


$(TARGET_RELEASE)$(EXE_SUFFIX): $(RELEASE_OBJECTS)
	@$(CC) $(LDFLAGS_RELEASE) $(LDFLAGS_EXTRA) $(OUT_EXE) $^
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
