ifeq ($(OS), Windows_NT)
    SHELL := cmd.exe
    CC := cl.exe
    EXE_SUFFIX := .exe
    # /wd4100 未使用形参；/wd4189 未使用局部变量；/wd4505 未使用局部函数（对应 gcc 的 -Wno-unused-*）
    CFLAGS_COMMON := /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505
    CFLAGS_DEBUG := $(CFLAGS_COMMON) /Od /Z7
    CFLAGS_RELEASE := $(CFLAGS_COMMON) /O2 /GL /DNDEBUG
    LDFLAGS_DEBUG := /nologo
    LDFLAGS_RELEASE := /nologo /LTCG
    OUT_OBJ = /c /Fo:$@
    OUT_EXE = /Fe:$@
else ifeq ($(OS), Linux)
    SHELL := /bin/sh
    CC := gcc
    EXE_SUFFIX :=
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
DEBUG_OBJECTS := $(addprefix debug/, $(patsubst %.c,%.o,$(patsubst %.C,%.o,$(SOURCES))))
RELEASE_OBJECTS := $(addprefix release/, $(patsubst %.c,%.o,$(patsubst %.C,%.o,$(SOURCES))))
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


debug/%.o: %.c
	@$(CC) $(CFLAGS_DEBUG) $(OUT_OBJ) $<


release/%.o: %.c
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
