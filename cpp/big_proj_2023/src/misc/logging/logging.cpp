#include <fmt/format.h>

void {{project_name}}_log_verbose0(std::string msg) {
    fmt::print("{}", msg);
}
void {{project_name}}_log_verbose1(std::string msg) {
#if {{project_name}}_VERBOSITY > 0
    fmt::print("{}", msg);
#endif
}

void {{project_name}}_log_verbose2(std::string msg) {
#if {{project_name}}_VERBOSITY > 1
    fmt::print("{}", msg);
#endif
}
