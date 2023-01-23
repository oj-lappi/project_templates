#include "./args.hpp"
#include "{{program_name}}.hpp"
#include <fmt/format.h>

int main(int argc, char **argv) {
  auto args = parse_args(argc, argv);
  fmt::print("not doing anything yet (IMPLEMENT ME!)");
}
