CC ?= gcc
CXX ?= g++

SHELL=/bin/sh

main_filename=main.cpp
srcdir=src
main_file=$(srcdir)/$(main_filename)
sources=$(wildcard $(srcdir)/*.cpp)

binary_name=out.a
build_dir=build
build_target=$(build_dir)/$(binary_name)

all : $(build_target)

.PHONY: clean
clean :
	rm -rf $(build_dir)/*

include $(subst $(srcdir)/, $(build_dir)/, $(sources:.cpp=.d))

$(build_target) : $(main_file) 
	$(CXX) -o $@ -I$(srcdir) $<

$(build_dir)/%.d: $(srcdir)/%.cpp
	@set -e; rm -f $@; \
	$(CXX) -M $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
