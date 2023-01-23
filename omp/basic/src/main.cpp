#include <omp.h>
#include <stdio.h>

int
main(int argc, char* argv[])
{

    omp_set_num_threads(4);

    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        printf("Thread %d says hello\n", id);
        printf("Thread %d says goodbye\n", id);
    }
}
