CC ?= gcc
CXX ?= g++

SHELL=/bin/sh

srcdir=src
build_dir=build

sources=$(wildcard $(srcdir)/*.cpp)
main_filename=main.cpp
main_file=$(srcdir)/$(main_filename)

objects=$(subst $(srcdir)/, $(build_dir)/, $(sources:.cpp=.o))
object_deps=$(subst $(srcdir)/, $(build_dir)/, $(sources:.cpp=.d))

binary_name=out.a
build_target=$(build_dir)/$(binary_name)

CPPFLAGS=-g
include_dirs= -Iinclude -Isrc
ALL_CPPFLAGS=$(CPPFLAGS) $(include_dirs)

all : $(build_target)

.PHONY: clean
clean :
	rm -rf $(build_dir)/*

$(build_target) : $(objects)
	$(CXX) -o $@ $(ALL_CPPFLAGS) $(objects)

$(build_dir)/%.o: $(srcdir)/%.cpp
	$(CXX) -c -o $@ $(ALL_CPPFLAGS) $<

$(build_dir)/%.d: $(srcdir)/%.cpp
	@set -e; rm -f $@; \
	$(CXX) -MM $(ALL_CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,$(build_dir)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

include $(object_deps)

.PHONY: test
test:
	./$(build_target)

