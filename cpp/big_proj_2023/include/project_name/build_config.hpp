#ifndef {{project_name}}_BUILD_CONFIG_HPP
#define {{project_name}}_BUILD_CONFIG_HPP
#include <array>
#include <cstdint>
#include <string>

consteval int                {{project_name}}_major_version();
consteval int                {{project_name}}_minor_version();
consteval int                {{project_name}}_patch_version();
consteval std::array<int, 3> {{project_name}}_version_tuple();

consteval std::array<uint32_t, 5> {{project_name}}_git_hash();
consteval bool                    {{project_name}}_git_commited();

consteval bool {{project_name}}_is_debug_build();

consteval bool {{project_name}}_has_feature_openmp();
consteval bool {{project_name}}_has_feature_mpi();

std::string {{project_name}}_build_config_info();

std::string {{project_name}}_version_string();
std::string {{project_name}}_build_config_info();

#endif
