CC := cl.exe
LD := link.exe
AR := lib.exe
SHELL := cmd.exe


MSVC_FREE_GOALS := clean format-code
GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),all)
NEED_MSVC := $(filter-out $(MSVC_FREE_GOALS),$(GOALS))
ifeq ($(if $(NEED_MSVC),$(shell where cl.exe >nul 2>&1 && echo no || echo yes),no),yes)
    $(info Searching MSVC)
    VSWHERE := $(shell echo "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe")
    VSPATH := $(strip $(shell "$(VSWHERE)" -latest -products * \
                              -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath))
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
        run-static-debug run-static-release run-shared-debug run-shared-release \
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
	       /Od /Z7 /MDd /DBITWISE_EXPORTS /c /Fo:$@ $<


build/shared-release/%.obj: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 \
	       /O2 /GL /DNDEBUG /MD /DBITWISE_EXPORTS /c /Fo:$@ $<


bitwise-static-debug.lib: $(STATIC_DEBUG_OBJECTS)
	@$(AR) /nologo /OUT:$@ $^
	@echo build static debug done


bitwise-static-release.lib: $(STATIC_RELEASE_OBJECTS)
	@$(AR) /nologo /LTCG /OUT:$@ $^
	@echo build static release done


bitwise-shared-debug.dll bitwise-shared-debug.lib &: $(SHARED_DEBUG_OBJECTS)
	@$(LD) /nologo /DLL /DEBUG /INCREMENTAL:NO /OUT:bitwise-shared-debug.dll $^
	@echo build shared debug done


bitwise-shared-release.dll bitwise-shared-release.lib &: $(SHARED_RELEASE_OBJECTS)
	@$(LD) /nologo /DLL /LTCG /OUT:bitwise-shared-release.dll $^
	@echo build shared release done


bitwise-static-debug.exe: build/static-debug/main.obj bitwise-static-debug.lib
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ $^
	@echo build static debug exe done


bitwise-static-release.exe: build/static-release/main.obj bitwise-static-release.lib
	@$(LD) /nologo /LTCG /OUT:$@ $^
	@echo build static release exe done


bitwise-shared-debug.exe: build/shared-debug/main.obj bitwise-shared-debug.lib
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ $^
	@echo build shared debug exe done


bitwise-shared-release.exe: build/shared-release/main.obj bitwise-shared-release.lib
	@$(LD) /nologo /LTCG /OUT:$@ $^
	@echo build shared release exe done


clean:
	@(if exist build rmdir /s /q build) \
	&& (if exist bitwise-static-debug.exe del /f /q bitwise-static-debug.exe) \
	&& (if exist bitwise-static-debug.lib del /f /q bitwise-static-debug.lib) \
	&& (if exist bitwise-static-debug.pdb del /f /q bitwise-static-debug.pdb) \
	&& (if exist bitwise-static-release.exe del /f /q bitwise-static-release.exe) \
	&& (if exist bitwise-static-release.lib del /f /q bitwise-static-release.lib) \
	&& (if exist bitwise-shared-debug.dll del /f /q bitwise-shared-debug.dll) \
	&& (if exist bitwise-shared-debug.exe del /f /q bitwise-shared-debug.exe) \
	&& (if exist bitwise-shared-debug.exp del /f /q bitwise-shared-debug.exp) \
	&& (if exist bitwise-shared-debug.lib del /f /q bitwise-shared-debug.lib) \
	&& (if exist bitwise-shared-debug.pdb del /f /q bitwise-shared-debug.pdb) \
	&& (if exist bitwise-shared-release.dll del /f /q bitwise-shared-release.dll) \
	&& (if exist bitwise-shared-release.exe del /f /q bitwise-shared-release.exe) \
	&& (if exist bitwise-shared-release.exp del /f /q bitwise-shared-release.exp) \
	&& (if exist bitwise-shared-release.lib del /f /q bitwise-shared-release.lib)
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: bitwise-static-debug.lib


build-static-release: bitwise-static-release.lib


build-shared-debug: bitwise-shared-debug.dll


build-shared-release: bitwise-shared-release.dll


run-static-debug: bitwise-static-debug.exe


run-static-release: bitwise-static-release.exe


run-shared-debug: bitwise-shared-debug.exe


run-shared-release: bitwise-shared-release.exe
