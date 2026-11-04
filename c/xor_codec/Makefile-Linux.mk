CC := gcc
AR := ar
SHELL := sh


PREFIX ?= /usr/local
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
	@$(CC) -std=c18 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -c -o $@ $<


build/static-release/%.o: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c18 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
           -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -c -o $@ $<


build/shared-debug/%.o: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c18 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -DXOR_CODEC_EXPORTS -fPIC -c -o $@ $<


build/shared-release/%.o: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c18 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable \
	       -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -DXOR_CODEC_EXPORTS -fPIC -c -o $@ $<


libxor_codec-static-debug.a: $(STATIC_DEBUG_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static debug done


libxor_codec-static-release.a: $(STATIC_RELEASE_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static release done


libxor_codec-shared-debug.so: $(SHARED_DEBUG_OBJECTS)
	@$(CC) -shared -Wl,-soname,$@ -Wl,-rpath,'$$ORIGIN' -o $@ $^
	@echo build shared debug done


libxor_codec-shared-release.so: $(SHARED_RELEASE_OBJECTS)
	@$(CC) -shared -flto -Wl,-soname,$@ -Wl,-rpath,'$$ORIGIN' -o $@ $^
	@echo build shared release done


xor_codec-static-debug: build/static-debug/main.o libxor_codec-static-debug.a
	@$(CC) -o $@ $^
	@echo build static debug exe done


xor_codec-static-release: build/static-release/main.o libxor_codec-static-release.a
	@$(CC) -flto -o $@ $^
	@echo build static release exe done


xor_codec-shared-debug: build/shared-debug/main.o libxor_codec-shared-debug.so
	@$(CC) -o $@ $^ -Wl,-rpath,'$$ORIGIN'
	@echo build shared debug exe done


xor_codec-shared-release: build/shared-release/main.o libxor_codec-shared-release.so
	@$(CC) -flto -o $@ $^ -Wl,-rpath,'$$ORIGIN'
	@echo build shared release exe done


clean:
	@rm -rf build \
	       libxor_codec-static-debug.a libxor_codec-static-release.a \
	       libxor_codec-shared-debug.so libxor_codec-shared-release.so \
	       xor_codec-static-debug xor_codec-static-release \
	       xor_codec-shared-debug xor_codec-shared-release
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: libxor_codec-static-debug.a


build-static-release: libxor_codec-static-release.a


build-shared-debug: libxor_codec-shared-debug.so


build-shared-release: libxor_codec-shared-release.so


run-static-debug: xor_codec-static-debug


run-static-release: xor_codec-static-release


run-shared-debug: xor_codec-shared-debug


run-shared-release: xor_codec-shared-release
