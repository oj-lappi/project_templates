      program {{project_name}}
        use omp_lib
        implicit none
        !$omp parallel
        write(*,'(I2)') omp_get_thread_num()
        !$omp end parallel
      endprogram {{project_name}}
