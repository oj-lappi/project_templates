#include "{{project_name}}.hpp"

#include <fmt/format.h>
#include <getopt.h>

#define BAD_EXEC_CONFIG_ERROR 010

void argument_error(std::string msg) {
  fmt::print("Error parsing arguments:{}\n", msg);
  exit(1);
}

void print_usage_and_exit(const char *name, int exit_code) {
  fmt::print("Usage:\n"
             "{} --dryrun [ARGS]\n"
             " Print arguments as they were parsed\n"
             "\n"
             "{} --version\n"
             "   Print version string and exit\n"
             "\n",
             name, name);
  exit(exit_code);
};

struct cli_args {
  bool dryrun;
};

// Main arg parsing is done here
cli_args parse_args(int argc, char *argv[]) {
  cli_args args{};

  if (argc == 0) {
    print_usage_and_exit(static_cast<const char *>("????"), 1);
  } else if (argc == 1) {
    print_usage_and_exit(argv[0], 1);
  }

  char *program_name = argv[0];

  static struct option long_options[] = {{"dryrun", no_argument, 0, 'd'},
                                         {"version", no_argument, 0, 'v'},
                                         {"help", no_argument, 0, 'h'},
                                         {nullptr, 0, 0, 0}};

  int opt_char{};
  int option_index{};

  while ((opt_char =
              getopt_long(argc, argv, "", long_options, &option_index)) != -1) {
    switch (opt_char) {
    case 'd': {
      args.dryrun = true;
      break;
    }
    case 'v':
      fmt::print("VERSION (not implemented)\n");
      // fmt::print("{}", build_config_info());
      exit(0);
      break;
    case 'h':
      print_usage_and_exit(program_name, 0);
    default: {
      argument_error("unknown argument");
    }
    }
  }

  if (args.dryrun) {
    // dryrun(args);
    fmt::print("DRYRUN (not implemented)\n");
    exit(0);
  }

  return args;
}
