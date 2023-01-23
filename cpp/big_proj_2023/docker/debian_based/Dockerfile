ARG IMAGE
FROM ${IMAGE}

#Build dependencies
RUN apt update && apt install -y \
	cmake \
        cmake-curses-gui \
	clang \
	catch2 \
        gdb \
        libopenmpi-dev \
        #Open MPI installs gcc 12, which clang will pick up (but it doesn't install c++ libraries)
        libstdc++-12-dev \
        libomp-dev \
        libboost-math-dev \
	libfmt-dev \
	libbenchmark-dev

#Development dependencies
RUN apt update && apt install -y \
	ccache \
	clang-tools \
        clang-tidy \
        clangd  \
        curl \
	fd-find \
        git \
        jq \
        man-db \
	neovim \
        pre-commit \
	ripgrep \
	gnuplot \
        doxygen \
	texlive-latex-base \
	texlive-latex-recommended \
	texlive-latex-extra
#texlive-fonts-extra


#Install the _latest_ version of clang-tidy
    #RUN apt search clang-tidy- | grep 'clang-tidy-[0-9]' | cut -d'/' -f1| sort -V | tail -1 | xargs apt install -y
    #RUN mkdir /developer_bin
    #RUN ln -s $(command -v $({ IFS=:; ls -H $PATH; } | grep '^clang-tidy-[0-9]' | sort -V | tail -1)) /developer_bin/clang-tidy


#Profiling dependencies
RUN apt update && apt install -y \
	perf-tools-unstable \
	binutils-dev \
	# These are mpiP deps
	libelf-dev \
	libdwarf-dev \
	libunwind-dev \
	libiberty-dev \
	# Tau needs llvm dev files for llvm plugins
	libclang-14-dev


ENV CXX=clang++
ENV CC=clang

ENV OMPI_CXX=${CXX}
ENV OMPI_CC=${CC}

##MPIP

RUN git clone -b 3.5 --depth 1 https://github.com/LLNL/mpiP.git /mpiP/3.5
WORKDIR /mpiP/3.5

# Patch mpiP to use newer BFD API and not rely on PTR being defined in a header file somewhere
RUN sed -i 's/PTR/void */g' pc_lookup.c

#With libdwarf/libelf
#RUN HAVE_PYTHON=python3 ./configure --prefix=/usr --enable-dwarf=yes --enable-demangling=GNU CFLAGS="-I/usr/include/libiberty -I/usr/include/libdwarf" CPPFLAGS="-I/usr/include/libiberty -I/usr/include/libdwarf"

#With libbfd/binutils
#RUN HAVE_PYTHON=python3 ./configure --prefix=/usr --enable-bfd=yes --enable-demangling=GNU CFLAGS="-I/usr/include/libiberty" CPPFLAGS="-I/usr/include/libiberty"
#RUN LOGNAME=`whoami` make PYTHON=python3
#RUN make install

#RUN rm -rf /mpiP


## TAU

ENV TAU_ROOT /tau_root
ENV PDT_INSTALL_PREFIX /tau_root/pdt
ENV TAU_INSTALL_PREFIX /tau_root/tau

#  An install tree for tau
RUN mkdir $TAU_ROOT
RUN mkdir $TAU_INSTALL_PREFIX
RUN mkdir $PDT_INSTALL_PREFIX

##  Downloads first
RUN mkdir /pdt
WORKDIR /pdt
RUN curl -fLo pdt.tgz http://tau.uoregon.edu/pdt.tgz
RUN gunzip pdt.tgz
RUN tar -x -f pdt.tar && rm pdt.tar && mv pdtoolkit-*/* . && mv pdtoolkit-*/.??* .
RUN rmdir pdtoolkit-*

RUN mkdir /tau
WORKDIR /tau
RUN curl -fLo tau.tgz http://tau.uoregon.edu/tau.tgz
RUN gunzip tau.tgz
RUN tar -x -f tau.tar && rm tau.tar && mv tau-*/* . && mv tau-*/.??* .
RUN rmdir tau-*
##  Downloads done


# Install PDT
WORKDIR /pdt
RUN ./configure -prefix=${PDT_INSTALL_PREFIX} -${CXX}
RUN make
RUN make install

# Install TAU proper
WORKDIR /tau
#RUN ./installtau
RUN ./configure -mpi -c++=clang++ -cc=clang -ompt -iowrapper -bfd=download -otf=download -unwind=download -pdt=${PDT_INSTALL_PREFIX} -prefix=${TAU_INSTALL_PREFIX}

RUN make
RUN make install
RUN echo export TAU_MAKEFILE=`cat .active_stub` > /etc/profile.d/tau_env.sh
RUN echo export PATH=${TAU_INSTALL_PREFIX}/x86_64/bin:\$PATH >> /etc/profile.d/tau_env.sh
#These get populated, but /etc/profile is apparently not run...

## PROFILERS DONE ##

#RUN apt upgrade -y

#TODO: install nvim from source



##################
# 		 #
# Configure nvim #
# 		 #
##################

WORKDIR /
RUN curl -fLo /usr/share/nvim/runtime/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Systemwide config, includes nvim/sysinit.vim
COPY usr_share /usr/share
RUN find /usr/share/nvim -type d | xargs chmod 755
RUN find /usr/share/nvim -type f | xargs chmod 644

RUN mkdir /usr/share/nvim/plugged
RUN NVIM_PLUGIN_BOOTSTRAP=Y nvim  +'PlugInstall --sync' +qa
#2022-06-03, treesitter broken
#RUN nvim +'TSInstallSync cpp ' +qa


################
# 	       #
# Shell config #
# /env config  #
# 	       #
################
RUN mkdir -p /developer_home/dotfiles
RUN mkdir -p /developer_home/config
RUN mkdir -p /developer_home/local

#These will be copied into the users home dir once the user is created in docker-entrypoint
COPY dotfiles/bashrc /developer_home/dotfiles/.bashrc
COPY dotfiles/profile /developer_home/dotfiles/.profile
COPY dotfiles/vsnip /developer_home/dotfiles/.vsnip
#COPY config/ /developer_home/config

RUN mkdir /{{project_name}}
WORKDIR /{{project_name}}

COPY ./docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh
