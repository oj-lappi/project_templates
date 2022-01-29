ARG IMAGE
FROM ${IMAGE}

#Build dependencies
RUN apt update && apt install -y \
	cmake \
	clang \
	catch2 \
	libfmt-dev \
	libbenchmark-dev

#Development dependencies
RUN apt install -y \
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
	ripgrep


#Install the _latest_ version of clang-tidy
    #RUN apt search clang-tidy- | grep 'clang-tidy-[0-9]' | cut -d'/' -f1| sort -V | tail -1 | xargs apt install -y
    #RUN mkdir /developer_bin
    #RUN ln -s $(command -v $({ IFS=:; ls -H $PATH; } | grep '^clang-tidy-[0-9]' | sort -V | tail -1)) /developer_bin/clang-tidy


##################
# 		 #
# Configure nvim #
# 		 #
##################
RUN curl -fLo /usr/share/nvim/runtime/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Systemwide config, includes nvim/sysinit.vim
COPY usr_share /usr/share
RUN find /usr/share/nvim -type d | xargs chmod 755
RUN find /usr/share/nvim -type f | xargs chmod 644

RUN mkdir /usr/share/nvim/plugged
RUN NVIM_PLUGIN_BOOTSTRAP=Y nvim  +'PlugInstall --sync' +qa
RUN nvim  +'TSInstallSync cpp ' +qa


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
#COPY config/ /developer_home/config

RUN mkdir /{{project_name}}_proj
WORKDIR /{{project_name}}_proj

COPY ./docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh
