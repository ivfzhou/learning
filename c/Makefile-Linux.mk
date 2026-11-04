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


.PHONY: all clean format-code \
        run-static-debug run-static-release run-shared-debug run-shared-release \
        build-static-debug build-static-release build-shared-debug build-shared-release


all: run-static-release


%/:
	@mkdir -p $@


build/static-debug/%.o: %.c | $(STATIC_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -c -o $@ $<


build/static-release/%.o: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -c -o $@ $<


build/shared-debug/%.o: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -fPIC -c -o $@ $<


build/shared-release/%.o: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -fPIC -c -o $@ $<


libc-static-debug.a: $(STATIC_DEBUG_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static debug done


libc-static-release.a: $(STATIC_RELEASE_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static release done


libc-shared-debug.so: $(SHARED_DEBUG_OBJECTS) bitwise/libbitwise-shared-debug.so
	@$(CC) -shared -Wl,-soname,$@ -Wl,-rpath,'$$ORIGIN' -o $@ $^
	@echo build shared debug done


libc-shared-release.so: $(SHARED_RELEASE_OBJECTS) bitwise/libbitwise-shared-release.so
	@$(CC) -shared -flto -Wl,-soname,$@ -Wl,-rpath,'$$ORIGIN' -o $@ $^
	@echo build shared release done


c-static-debug: build/static-debug/main.o libc-static-debug.a bitwise/libbitwise-static-debug.a
	@$(CC) -o $@ $^
	@echo build static debug exe done


c-static-release: build/static-release/main.o libc-static-release.a bitwise/libbitwise-static-release.a
	@$(CC) -flto -o $@ $^
	@echo build static release exe done


c-shared-debug: build/shared-debug/main.o libc-shared-debug.so bitwise/libbitwise-shared-debug.so
	@$(CC) -o $@ $^ -Wl,-rpath,'$$ORIGIN'
	@echo build shared debug exe done


c-shared-release: build/shared-release/main.o libc-shared-release.so bitwise/libbitwise-shared-release.so
	@$(CC) -flto -o $@ $^ -Wl,-rpath,'$$ORIGIN'
	@echo build shared release exe done


clean:
	@rm -rf build \
	       libc-static-debug.a libc-static-release.a \
	       libc-shared-debug.so libc-shared-release.so \
	       c-static-debug c-static-release \
	       c-shared-debug c-shared-release
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
