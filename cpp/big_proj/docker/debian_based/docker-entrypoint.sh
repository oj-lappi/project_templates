#!/bin/sh

CXX_DEVELOPER_UID=$(stat --printf="%u" /{{project_name}}_proj)
CXX_DEVELOPER_GID=$(stat --printf="%g" /{{project_name}}_proj)

# dev-group != user group
if [ "${CXX_DEVELOPER_GID}" != "${CXX_DEVELOPER_UID}" ];then
    getent group ${CXX_DEVELOPER_GID} || groupadd -g ${CXX_DEVELOPER_GID} cxx-development-group
    useradd -m -s /bin/bash -u ${CXX_DEVELOPER_UID} -G cxx-development-group cxx-developer
else
    useradd -m -s /bin/bash -u ${CXX_DEVELOPER_UID} cxx-developer
fi

#Set up the home directory of cxx-developer
cp /developer_home/dotfiles/.* /home/cxx-developer
cp -r /developer_home/config /home/cxx-developer/.config
cp -r /developer_home/local /home/cxx-developer/.local

#chown the home directory, root takes ownership otherwise
chown -R cxx-developer /home/cxx-developer

su --login cxx-developer -c "cd /{{project_name}}; pre-commit install"

# I think this can be anything, as long as the container stays alive
exec /bin/bash
