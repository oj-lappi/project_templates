
#if OJL_HIRES_TIMER_IMPL == 1

#include <chrono>
high_resolution_timer::high_resolution_timer()
    : start_time(take_time_stamp()) {}

void high_resolution_timer::restart() { start_time = take_time_stamp(); }

double high_resolution_timer::elapsed() const {
  return static_cast<double>(take_time_stamp() - start_time) * 1e-9;
}

std::uint64_t high_resolution_timer::elapsed_nanoseconds() const {
  return take_time_stamp() - start_time;
}

std::uint64_t high_resolution_timer::take_time_stamp() {
  return std::chrono::duration_cast<std::chrono::nanoseconds>(
             std::chrono::steady_clock::now().time_since_epoch())
      .count();
}
#endif
