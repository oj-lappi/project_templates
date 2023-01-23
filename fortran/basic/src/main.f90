      program {{project_name}}
        implicit none
        integer,dimension(5) :: array
        integer :: i

        print *, "Hello, world."

        array = 10
        print '(i3," ",i3," ",i3," ",i3," ",i3)', array

        do i = 1, size(array)
          array(i) = i
        end do
        
        print '(i3," ",i3," ",i3," ",i3," ",i3)', array
      endprogram {{project_name}}
