CC := gcc
AR := ar
SHELL := sh

SOURCES := $(sort $(wildcard *.c))
HEADERS := $(sort $(wildcard *.h))
LIB_SOURCES := $(filter-out main.c,$(SOURCES))
STATIC_DEBUG_OBJECTS := $(addprefix build/static-debug/, $(patsubst %.c,%.o,$(LIB_SOURCES)))
STATIC_RELEASE_OBJECTS := $(addprefix build/static-release/, $(patsubst %.c,%.o,$(LIB_SOURCES)))
SHARED_DEBUG_OBJECTS := $(addprefix build/shared-debug/, $(patsubst %.c,%.o,$(LIB_SOURCES)))
SHARED_RELEASE_OBJECTS := $(addprefix build/shared-release/, $(patsubst %.c,%.o,$(LIB_SOURCES)))
STATIC_DEBUG_OBJECT_DIRS := $(sort $(dir $(STATIC_DEBUG_OBJECTS)))
STATIC_RELEASE_OBJECT_DIRS := $(sort $(dir $(STATIC_RELEASE_OBJECTS)))
SHARED_DEBUG_OBJECT_DIRS := $(sort $(dir $(SHARED_DEBUG_OBJECTS)))
SHARED_RELEASE_OBJECT_DIRS := $(sort $(dir $(SHARED_RELEASE_OBJECTS)))
$(info $$(SOURCES) $(SOURCES))
$(info $$(HEADERS) $(HEADERS))


.PHONY: all clean format-code run-static-release run-static-debug run-shared-release run-shared-debug build-static-debug build-static-release build-shared-debug build-shared-release


all: run-static-release


%/:
	@mkdir -p $@


build/static-debug/%.o: %.c | $(STATIC_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -c -o $@ $<


build/static-release/%.o: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -c -o $@ $<


build/shared-debug/%.o: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -fPIC -c -o $@ $<


build/shared-release/%.o: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -fPIC -c -o $@ $<


libc-static-debug.a: $(STATIC_DEBUG_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static debug done


libc-static-release.a: $(STATIC_RELEASE_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static release done


libc-shared-debug.so: $(SHARED_DEBUG_OBJECTS) bitwise/libbitwise-static-debug.a
	@$(CC) -shared -o $@ $^
	@echo build shared debug done


libc-shared-release.so: $(SHARED_RELEASE_OBJECTS) bitwise/libbitwise-static-release.a
	@$(CC) -shared -flto -o $@ $^
	@echo build shared release done


c-static-debug: libc-static-debug.a build/static-debug/main.o bitwise/libbitwise-static-debug.a
	@$(CC) -o $@ build/static-debug/main.o libc-static-debug.a bitwise/libbitwise-static-debug.a
	@echo build static debug exe done


c-static-release: libc-static-release.a build/static-release/main.o bitwise/libbitwise-static-release.a
	@$(CC) -flto -o $@ build/static-release/main.o libc-static-release.a bitwise/libbitwise-static-release.a
	@echo build static release exe done


c-shared-debug: libc-shared-debug.so build/static-debug/main.o
	@$(CC) -o $@ build/static-debug/main.o -L. -lc-shared-debug -Wl,-rpath,'$$ORIGIN'
	@echo build shared debug exe done


c-shared-release: libc-shared-release.so build/static-release/main.o
	@$(CC) -flto -o $@ build/static-release/main.o -L. -lc-shared-release -Wl,-rpath,'$$ORIGIN'
	@echo build shared release exe done


clean:
	@rm -rf build \
	       libc-static-debug.a libc-static-release.a \
	       libc-shared-debug.so libc-shared-release.so \
	       c-static-debug c-static-release \
	       c-shared-debug c-shared-release \
	       c-static-debug.exe c-static-release.exe
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: libc-static-debug.a


build-static-release: libc-static-release.a


build-shared-debug: libc-shared-debug.so


build-shared-release: libc-shared-release.so


run-static-debug: c-static-debug


run-static-release: c-static-release


run-shared-debug: c-shared-debug


run-shared-release: c-shared-release
