#ifndef OHL_PROFILING_HPP
#define OHL_PROFILING_HPP

#include <map>
#include <vector>

namespace ojl_profiling {

struct Distribution {
  double bin_width;
  std::vector<size_t> bins;
} __attribute__((aligned(32)));

using integer_profile = std::vector<std::uint64_t>;

struct Profiler {
  std::map<std::string, integer_profile> profiles;
  std::map<std::string, std::vector<size_t>> path_properties;
  std::string output_filename;
  Profiler(std::string output_filename);
  ~Profiler();
  void dump() const;
};

#ifdef OJL_PROFILER_ON
extern Profiler stats;

// API: macros
#define OJL_PROFILE_FUNC                                                       \
  auto &func_stats = {{project_name}}_profiling::stats.profiles[__func__];                \
  high_resolution_timer timer;

#define OJL_PROFILE_FUNC_END func_stats.push_back(timer.elapsed_nanoseconds());
#else
#define OJL_PROFILE_FUNC ;
#define OJL_PROFILE_FUNC_END ;
#endif

// API: setters
// set_bin_width(size_t);

// Implementation
#if OJL_PROFILER_IMPLEMENTATION == 1

// json serialization of Distribution
// TODO: make sure NLOHMANN JSON is included
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Distribution, bin_width, bins);

Profiler::Profiler(std::string output_filename_)
    : output_filename(std::move(output_filename_)) {}

Profiler::~Profiler() { dump(); }

// TODO: wip, finish this

#endif

} // namespace ojl_profiling
#endif
