#!/bin/bash

default_image={{project_name}}_dev_unstable
image=$default_image

print_usage() {
	echo "$0 [--build] --compose_args <args to docker-compose up> --image <docker-image>"
        echo
        echo '  --build'
        echo '                  passes --build to docker-compose up'
        echo '                  short for -c --build'
        echo '  --compose_args <args>'
        echo '                  passes <args> to docker-compose up'
        echo '  --image'
        echo '                  uses image as the pattern of the docker image to search for.'
        echo '                  You can use the names of the services in docker-compose.yml'
        echo "                  the default is $default_image."
}

hash() {
    text="$1"
    echo $text | cksum | cut -d' ' -f 1 | xargs printf "%x\n"
}

OPTS=`getopt -o hi:c:b -l help,image:,compose_args:,build -n "$0"  -- "$@"`
if [ $? != 0 ] ; then echo "Failed to parse args" >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true;do
case "$1" in
-h|--help)
	print_usage
	exit 0
	;;
-i|--image)
	shift
	image=$1
	;;
-b|--build)
        docker_compose_flags="$docker_compose_flags --build"
        ;;
-c|--compose_args)
	shift
        docker_compose_flags="$docker_compose_flags $1"
	;;
--)
	shift
	break
	;;
*)
	break
	;;
esac
shift
done

#Check that we have a git config
REAL_USER="${SUDO_USER:-$LOGNAME}"
USER_GITCONFIG="/home/$REAL_USER/.gitconfig"
[[ -f "$USER_GITCONFIG" ]] || { echo "No global gitconfig found ($USER_GITCONFIG), please tell git who you are to use the development container"; exit 1; }


search_for_container() {
    container=$(docker ps -l --filter "name=${project_image}" --format='{{ .Names }}')
}

project_image=$(set -x; COMPOSE_PROJECT_NAME=$(hash $PWD) docker-compose up ${docker_compose_flags} -d 2>&1 | tee >(cat 1>&2) | grep -m 1 -oE "\w+${image}") || exit 2

echo
echo "Looking for a container of the image ${project_image} ($image)"
search_for_container

#TODO: make retries an exponential backoff for smoother experience?
retries=20
sleep_time=0.5
while [ "${container}" == "" ] && [ ${retries} -gt 1 ]; do
	search_for_container
	retries=$((${retries}-1))
	echo retrying...
	sleep $sleep_time
	sleep_time=$(bc <<< "$sleep_time * 1.5")
done

sleep_time=1
if [ "${container}" != "" ]; then
    echo Found running \"${project_image}\" container: ${container}, starting shell
    echo Checking to see that the container is initialized

    #TODO: make retries an exponential backoff for smoother experience?
    retries=20
    while ! docker exec ${container} stat /home/cxx-developer/user_created >& /dev/null && [ ${retries} -gt 1 ]; do
	echo retrying...
	sleep $sleep_time
	sleep_time=$(bc <<< "$sleep_time * 1.5")
    done

    docker exec -u cxx-developer -it ${container} /bin/bash -l
else
    echo No \"${project_image}\" container found, check the status of the container
fi
