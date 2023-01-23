#include "definitions.hpp"
#include "{{project_name}}/misc/build_config.hpp"

#include <fmt/format.h>

consteval int {{project_name}}_major_version() {
#ifdef {{project_name}}_MAJOR_VERSION
  return {{project_name}}_MAJOR_VERSION;
#else
  return -1;
#endif
}

consteval int {{project_name}}_minor_version() {
#ifdef {{project_name}}_MINOR_VERSION
  return {{project_name}}_MINOR_VERSION;
#else
  return -1;
#endif
}

consteval int {{project_name}}_patch_version() {
#ifdef {{project_name}}_PATCH_VERSION
  return {{project_name}}_PATCH_VERSION;
#else
  return -1;
#endif
}

consteval std::array<int, 3> {{project_name}}_version_tuple() {
  return {{{project_name}}_major_version(), {{project_name}}_minor_version(), {{project_name}}_patch_version()};
}

consteval std::array<uint32_t, 5> {{project_name}}_git_hash() {
#ifdef {{project_name}}_GIT_HASH_1
  return {{{project_name}}_GIT_HASH_1, {{project_name}}_GIT_HASH_2, {{project_name}}_GIT_HASH_3,
          {{project_name}}_GIT_HASH_4, {{project_name}}_GIT_HASH_5};
#else
  return {0, 0, 0, 0, 0};
#endif
}

consteval bool {{project_name}}_is_git_hash_reliable() {
#ifdef {{project_name}}_GIT_UNSTAGED_FILES
  return false;
#endif
  return true;
}

consteval bool {{project_name}}_is_debug_build() {
#ifndef NDEBUG
  return true;
#else
  return false;
#endif
}

consteval bool {{project_name}}_has_feature_openmp() {
#if USE_OPENMP
  return true;
#else
  return false;
#endif
}

consteval bool {{project_name}}_has_feature_mpi() {
#if USE_MPI
  return true;
#else
  return false;
#endif
}

std::string {{project_name}}_version_string() {
  int major = {{project_name}}_major_version();
  int minor = {{project_name}}_minor_version();
  int patch = {{project_name}}_patch_version();

  return fmt::format(
      "{}.{}.{}{}({:08x}{})", major >= 0 ? fmt::format("{}", major) : "?",
      minor >= 0 ? fmt::format("{}", minor) : "?",
      patch >= 0 ? fmt::format("{}", patch) : "?",
      {{project_name}}_is_debug_build() ? "_DEBUG" : "", fmt::join({{project_name}}_git_hash(), ""),
      {{project_name}}_is_git_hash_reliable() ? "" : "_GIT_WORKING_TREE_DIRTY");
}

#define STRINGIFY_(X) #X
#define STRINGIFY(X) STRINGIFY_(X)

std::string {{project_name}}_build_config_info() {
  return fmt::format("  Version: {}\n"
                     "    DEBUG: {}\n"
                     "VERBOSITY: {}\n"
                     {{project_name}}_version_string(), STRINGIFY({{project_name}}_PRNG_CHOICE),
                     STRINGIFY({{project_name}}_PRNG), {{project_name}}_is_debug_build(),
                     STRINGIFY({{project_name}}_VERBOSITY));
}
