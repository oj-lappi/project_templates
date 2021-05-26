#include <stdio.h>
#include <iostream>

#include <benchmark/benchmark.h>
#include <fmt/core.h>

static void printf_print(benchmark::State& state) {
    for (auto _ : state) 
        fprintf(stderr,"Hello");
}
BENCHMARK(printf_print);

static void stream_print(benchmark::State& state) {
    for (auto _ : state) 
        std::cerr <<"Hello";

}
BENCHMARK(stream_print);

BENCHMARK_MAIN();
