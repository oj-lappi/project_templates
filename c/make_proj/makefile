CC ?= gcc
CXX ?= g++

SHELL=/bin/sh

srcdir=src
build_dir=build

sources=$(wildcard $(srcdir)/*.c)
main_filename=main.c
main_file=$(srcdir)/$(main_filename)

objects=$(subst $(srcdir)/, $(build_dir)/, $(sources:.c=.o))
object_deps=$(subst $(srcdir)/, $(build_dir)/, $(sources:.c=.d))

binary_name=a.out
build_target=$(build_dir)/$(binary_name)

CFLAGS=-g
include_dirs= -Iinclude -Isrc
ALL_CFLAGS=$(CFLAGS) $(include_dirs)

all : $(build_target)

$(build_target) : $(objects)
	$(CC) -o $@ $(ALL_CFLAGS) $(objects)

$(build_dir)/%.o: $(srcdir)/%.c
	$(CC) -c -o $@ $(ALL_CFLAGS) $<

$(build_dir)/%.d: $(srcdir)/%.c
	@set -e; rm -f $@; \
	$(CC) -MM $(ALL_CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,$(build_dir)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

include $(object_deps)

.PHONY: clean
clean :
	rm -rf $(build_dir)/*

.PHONY: format
format:
	find src/ -iname *.h -o -iname *.c | xargs clang-format -i -style=file

.PHONY: test
test:
	./$(build_target)
