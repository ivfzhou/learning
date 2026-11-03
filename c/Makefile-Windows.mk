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
    VSPATH := $(strip $(shell "$(VSWHERE)" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath))
    ifeq ($(VSPATH),)
        $(error cl.exe was not found, and Visual Studio could not be located via vswhere; please install VS/Build Tools or run from the Developer Command Prompt)
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


.PHONY: all clean format-code run-static-release run-static-debug run-shared-release run-shared-debug \
        build-static-debug build-static-release build-shared-debug build-shared-release


all: run-static-release


%/:
	@if not exist "$(subst /,\,$@)" md "$(subst /,\,$@)"


build/static-debug/%.obj: %.c | $(STATIC_DEBUG_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 /Od /Z7 /MDd /c /Fo:$@ $<


build/static-release/%.obj: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /W4 /wd4100 /wd4189 /wd4505 /O2 /GL /DNDEBUG /MD /c /Fo:$@ $<


build/shared-debug/%.obj: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /DC_EXPORTS /W4 /wd4100 /wd4189 /wd4505 /Od /Z7 /MDd /c /Fo:$@ $<


build/shared-release/%.obj: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) /nologo /std:c17 /utf-8 /D_CRT_SECURE_NO_WARNINGS /DC_EXPORTS /W4 /wd4100 /wd4189 /wd4505 /O2 /GL /DNDEBUG /MD /c /Fo:$@ $<


c-static-debug.lib: $(STATIC_DEBUG_OBJECTS)
	@$(AR) /nologo /OUT:$@ $^
	@echo build static debug done


c-static-release.lib: $(STATIC_RELEASE_OBJECTS)
	@$(AR) /nologo /LTCG /OUT:$@ $^
	@echo build static release done


c-shared-debug.dll: $(SHARED_DEBUG_OBJECTS) bitwise/bitwise-static-debug.lib
	@$(LD) /nologo /DLL /DEBUG /INCREMENTAL:NO /OUT:$@ $^
	@echo build shared debug done


c-shared-release.dll: $(SHARED_RELEASE_OBJECTS) bitwise/bitwise-static-release.lib
	@$(LD) /nologo /DLL /LTCG /OUT:$@ $^
	@echo build shared release done


c-static-debug.exe: c-static-debug.lib build/static-debug/main.obj bitwise/bitwise-static-debug.lib
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ build/static-debug/main.obj c-static-debug.lib bitwise/bitwise-static-debug.lib
	@echo build static debug exe done


c-static-release.exe: c-static-release.lib build/static-release/main.obj bitwise/bitwise-static-release.lib
	@$(LD) /nologo /LTCG /OUT:$@ build/static-release/main.obj c-static-release.lib bitwise/bitwise-static-release.lib
	@echo build static release exe done


c-shared-debug.exe: c-shared-debug.dll build/static-debug/main.obj
	@$(LD) /nologo /DEBUG /INCREMENTAL:NO /OUT:$@ build/static-debug/main.obj c-shared-debug.lib
	@echo build shared debug exe done


c-shared-release.exe: c-shared-release.dll build/static-release/main.obj
	@$(LD) /nologo /LTCG /OUT:$@ build/static-release/main.obj c-shared-release.lib
	@echo build shared release exe done


clean:
	@if exist build rmdir /s /q build
	@for %%f in (c-static-debug.lib c-static-release.lib \
	             c-shared-debug.dll c-shared-debug.exp c-shared-debug.lib c-shared-debug.pdb \
	             c-shared-release.dll c-shared-release.exp c-shared-release.lib c-shared-release.pdb \
	             c-static-debug.exe c-static-debug.pdb c-static-release.exe c-static-release.pdb \
	             c-shared-debug.exe c-shared-debug.pdb c-shared-release.exe c-shared-release.pdb \
	             bitwise-shared-debug.dll bitwise-shared-release.dll) do @if exist %%f del /f /q %%f
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: c-static-debug.lib


build-static-release: c-static-release.lib


build-shared-debug: c-shared-debug.dll


build-shared-release: c-shared-release.dll


run-static-debug: c-static-debug.exe


run-static-release: c-static-release.exe


run-shared-debug: c-shared-debug.exe


run-shared-release: c-shared-release.exe
