#include <fmt/core.h>
#include <omp.h>

int
main(int argc, char* argv[])
{

    omp_set_num_threads(4);

    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        fmt::print("Thread {} says hello\n", id);
        fmt::print("Thread {} says goodbye\n", id);
    }
}
