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
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -DBITWISE_EXPORTS -fPIC -c -o $@ $<


build/shared-release/%.o: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -DBITWISE_EXPORTS -fPIC -c -o $@ $<


libbitwise-static-debug.a: $(STATIC_DEBUG_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static debug done


libbitwise-static-release.a: $(STATIC_RELEASE_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static release done


libbitwise-shared-debug.so: $(SHARED_DEBUG_OBJECTS)
	@$(CC) -shared -o $@ $^
	@echo build shared debug done


libbitwise-shared-release.so: $(SHARED_RELEASE_OBJECTS)
	@$(CC) -shared -flto -o $@ $^
	@echo build shared release done


bitwise-static-debug: libbitwise-static-debug.a build/static-debug/main.o
	@$(CC) -o $@ build/static-debug/main.o libbitwise-static-debug.a
	@echo build static debug exe done


bitwise-static-release: libbitwise-static-release.a build/static-release/main.o
	@$(CC) -flto -o $@ build/static-release/main.o libbitwise-static-release.a
	@echo build static release exe done


bitwise-shared-debug: libbitwise-shared-debug.so build/static-debug/main.o
	@$(CC) -o $@ build/static-debug/main.o -L. -lbitwise-shared-debug -Wl,-rpath,'$$ORIGIN'
	@echo build shared debug exe done


bitwise-shared-release: libbitwise-shared-release.so build/static-release/main.o
	@$(CC) -flto -o $@ build/static-release/main.o -L. -lbitwise-shared-release -Wl,-rpath,'$$ORIGIN'
	@echo build shared release exe done


clean:
	@rm -rf build \
	       libbitwise-static-debug.a libbitwise-static-release.a \
	       libbitwise-shared-debug.so libbitwise-shared-release.so \
	       bitwise-static-debug bitwise-static-release \
	       bitwise-shared-debug bitwise-shared-release
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: libbitwise-static-debug.a


build-static-release: libbitwise-static-release.a


build-shared-debug: libbitwise-shared-debug.so


build-shared-release: libbitwise-shared-release.so


run-static-debug: bitwise-static-debug


run-static-release: bitwise-static-release


run-shared-debug: bitwise-shared-debug


run-shared-release: bitwise-shared-release
