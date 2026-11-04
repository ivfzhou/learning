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
        run-static-release run-static-debug run-shared-release run-shared-debug \
        build-static-debug build-static-release build-shared-debug build-shared-release


all: run-static-release


%/:
	@mkdir -p $@


build/static-debug/%.o: %.c | $(STATIC_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -c -o $@ $<


build/static-release/%.o: %.c | $(STATIC_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -c -o $@ $<


build/shared-debug/%.o: %.c | $(SHARED_DEBUG_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O0 -g3 -DBITWISE_NEGATION_EXPORTS -fPIC -c -o $@ $<


build/shared-release/%.o: %.c | $(SHARED_RELEASE_OBJECT_DIRS)
	@$(CC) -std=c17 -finput-charset=UTF-8 -fexec-charset=UTF-8 -Wpedantic -Winline -Wall -Wextra -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-parameter -O3 -DNDEBUG -flto -DBITWISE_NEGATION_EXPORTS -fPIC -c -o $@ $<


libbitwise_negation-static-debug.a: $(STATIC_DEBUG_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static debug done


libbitwise_negation-static-release.a: $(STATIC_RELEASE_OBJECTS)
	@$(AR) rcs $@ $^
	@echo build static release done


libbitwise_negation-shared-debug.so: $(SHARED_DEBUG_OBJECTS)
	@$(CC) -shared -o $@ $^
	@echo build shared debug done


libbitwise_negation-shared-release.so: $(SHARED_RELEASE_OBJECTS)
	@$(CC) -shared -flto -o $@ $^
	@echo build shared release done


bitwise_negation-static-debug: libbitwise_negation-static-debug.a build/static-debug/main.o
	@$(CC) -o $@ build/static-debug/main.o libbitwise_negation-static-debug.a
	@echo build static debug exe done


bitwise_negation-static-release: libbitwise_negation-static-release.a build/static-release/main.o
	@$(CC) -flto -o $@ build/static-release/main.o libbitwise_negation-static-release.a
	@echo build static release exe done


bitwise_negation-shared-debug: libbitwise_negation-shared-debug.so build/static-debug/main.o
	@$(CC) -o $@ build/static-debug/main.o -L. -lbitwise_negation-shared-debug -Wl,-rpath,'$$ORIGIN'
	@echo build shared debug exe done


bitwise_negation-shared-release: libbitwise_negation-shared-release.so build/static-release/main.o
	@$(CC) -flto -o $@ build/static-release/main.o -L. -lbitwise_negation-shared-release -Wl,-rpath,'$$ORIGIN'
	@echo build shared release exe done


clean:
	@rm -rf build \
	       libbitwise_negation-static-debug.a libbitwise_negation-static-release.a \
	       libbitwise_negation-shared-debug.so libbitwise_negation-shared-release.so \
	       bitwise_negation-static-debug bitwise_negation-static-release \
	       bitwise_negation-shared-debug bitwise_negation-shared-release
	@echo clean done


format-code:
	@clang-format --style=file -i $(SOURCES) $(HEADERS)
	@echo format code done


build-static-debug: libbitwise_negation-static-debug.a


build-static-release: libbitwise_negation-static-release.a


build-shared-debug: libbitwise_negation-shared-debug.so


build-shared-release: libbitwise_negation-shared-release.so


run-static-debug: bitwise_negation-static-debug


run-static-release: bitwise_negation-static-release


run-shared-debug: bitwise_negation-shared-debug


run-shared-release: bitwise_negation-shared-release
