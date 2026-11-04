CC := cl.exe
LD := link.exe
AR := lib.exe
SHELL := cmd.exe


MSVC_FREE_GOALS := clean format-code install uninstall
GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),all)
NEED_MSVC := $(filter-out $(MSVC_FREE_GOALS),$(GOALS))
ifeq ($(if $(NEED_MSVC),$(shell where cl.exe >nul 2>&1 && echo no || echo yes),no),yes)
    $(info Searching MSVC)
    VSWHERE := $(shell echo "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe")
    VSPATH := $(strip $(shell "$(VSWHERE)" -latest -products * \
                              -requires Microsoft.VisualStudio.Component.VC.Tools.x86x64 -property installationPath))
    ifeq ($(VSPATH),)
        $(error cl.exe was not found, and Visual Studio could not be located via vswhere; \
                please install VS/Build Tools or run from the Developer Command Prompt)
    endif
    VCVARS := $(VSPATH)\VC\Auxiliary\Build\vcvars64.bat
    export INCLUDE := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !INCLUDE!")
    export LIB := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIB!")
    export LIBPATH := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !LIBPATH!")
    export PATH := $(shell cmd /v:on /c "call "$(VCVARS)" >nul 2>&1 && echo !PATH!")
    $(info Searching MSVC end)
endif


PREFIX ?= C:/usr/local
SOURCES := $(sort $(wildcard *.c))
HEADERS := $(sort $(wildcard *.h))
LIB_SOURCES := $(filter-out main.c,$(SOURCES))
STATIC_DEBUG_OBJECTS := $(addprefix build/static-debug/, $(patsubst %.c,%.obj,$(LIB_SOURCES)))
STATIC_RELEASE_OBJECTS := $(addprefix build/static-release/, $(patsubst %.c,%.obj,$(LIB_SOURCES)))
SHARED_DEBUG_OBJECTS := $(addprefix build/shared-debug/, $(patsubst %.c,%.obj,$(LIB_SOURCES)))
SHARED_RELEASE_OBJECTS := $(addprefix build/shared-release/, $(patsubst %.c,%.obj,$(LIB_SOURCES)))
STATIC_DEBUG_OBJECT_DIRS := $(sort $(dir $(STATIC_DEBUG_OBJECTS)))
STATIC_RELEASE_OBJECT_DIRS := $(sort $(dir $(STATIC_RELEASE_OBJECTS)))
SHARED_DEBUG_OBJECT_DIRS := $(sort $(dir $(SHARED_DEBUG_OBJECTS)))
SHARED_RELEASE_OBJECT_DIRS := $(sort $(dir $(SHARED_RELEASE_OBJECTS)))
$(info $$(SOURCES) $(SOURCES))
$(info $$(HEADERS) $(HEADERS))


.PHONY: all clean format-code \
        run-static-debug run-static-release  run-shared-debug run-shared-release\
        build-static-debug build-static-release build-shared-debug build-shared-release


all: run-static-release


%/:
	@if not exist "$(subst /,\,$@)" md "$(subst /,\,$@)"


build/static-debug/%.obj: %.c | $(STATIC_DEBUG_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 \
	       /Od /Z7 /MDd /c /Fo:$@ $<


build/static-release/%.obj: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 \
	       /O2 /GL /DNDEBUG /MD /c /Fo:$@ $<


build/shared-debug/%.obj: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 \
	       /Od /Z7 /MDd /DXOR_CODEC_EXPORTS /c /Fo:$@ $<


build/shared-release/%.obj: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 \
	       /O2 /GL /DNDEBUG /MD /DXOR_CODEC_EXPORTS /c /Fo:$@ $<


xor_codec-static-debug.lib: $(STATIC_DEBUG_OBJECTS)
	@$(AR) /nologo /OUT:$@ $^
	@echo build static debug done


xor_codec-static-release.lib: $(STATIC_RELEASE_OBJECTS)
	@$(AR) /nologo /LTCG /OUT:$@ $^
	@echo build static release done


xor_codec-shared-debug.dll xor_codec-shared-debug.lib &: $(SHARED_DEBUG_OBJECTS)
	@$(LD) /nologo /DLL /DEBUG /INCREMENTAL:NO /OUT:xor_codec-shared-debug.dll $^
	@echo build shared debug done


xor_codec-shared-release.dll xor_codec-shared-release.lib &: $(SHARED_RELEASE_OBJECTS)
	@$(LD) /nologo /DLL /LTCG /OUT:xor_codec-shared-release.dll $^
	@echo build shared release done


xor_codec-static-debug.exe: build/static-debug/main.obj xor_codec-static-debug.lib
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ $^
	@echo build static debug exe done


xor_codec-static-release.exe: build/static-release/main.obj xor_codec-static-release.lib
	@$(LD) /nologo /LTCG /OUT:$@ $^
	@echo build static release exe done


xor_codec-shared-debug.exe: build/shared-debug/main.obj xor_codec-shared-debug.lib
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ $^
	@echo build shared debug exe done


xor_codec-shared-release.exe: build/shared-release/main.obj xor_codec-shared-release.lib
	@$(LD) /nologo /LTCG /OUT:$@ $^
	@echo build shared release exe done


clean:
	@(if exist build rmdir /s /q build) \
	&& (if exist xor_codec-static-debug.exe del /f /q xor_codec-static-debug.exe) \
	&& (if exist xor_codec-static-debug.lib del /f /q xor_codec-static-debug.lib) \
	&& (if exist xor_codec-static-debug.pdb del /f /q xor_codec-static-debug.pdb) \
	&& (if exist xor_codec-static-release.exe del /f /q xor_codec-static-release.exe) \
	&& (if exist xor_codec-static-release.lib del /f /q xor_codec-static-release.lib) \
	&& (if exist xor_codec-shared-debug.dll del /f /q xor_codec-shared-debug.dll) \
	&& (if exist xor_codec-shared-debug.exe del /f /q xor_codec-shared-debug.exe) \
	&& (if exist xor_codec-shared-debug.exp del /f /q xor_codec-shared-debug.exp) \
	&& (if exist xor_codec-shared-debug.lib del /f /q xor_codec-shared-debug.lib) \
	&& (if exist xor_codec-shared-debug.pdb del /f /q xor_codec-shared-debug.pdb) \
	&& (if exist xor_codec-shared-release.dll del /f /q xor_codec-shared-release.dll) \
	&& (if exist xor_codec-shared-release.exe del /f /q xor_codec-shared-release.exe) \
	&& (if exist xor_codec-shared-release.exp del /f /q xor_codec-shared-release.exp) \
	&& (if exist xor_codec-shared-release.lib del /f /q xor_codec-shared-release.lib)
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: xor_codec-static-debug.lib


build-static-release: xor_codec-static-release.lib


build-shared-debug: xor_codec-shared-debug.dll


build-shared-release: xor_codec-shared-release.dll


run-static-debug: xor_codec-static-debug.exe


run-static-release: xor_codec-static-release.exe


run-shared-debug: xor_codec-shared-debug.exe


run-shared-release: xor_codec-shared-release.exe
