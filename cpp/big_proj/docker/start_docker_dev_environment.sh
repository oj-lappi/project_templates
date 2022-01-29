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


search_for_container() {
    container=$(docker ps -l --filter "name=${image}" --format='{{ .Names }}')
}

(set -x; docker-compose up ${docker_compose_flags} -d || exit 2)

echo
echo Looking for a container of the image ${image}
search_for_container
retries=10
while [ "${container}" == "" ] && [ ${retries} -gt 1 ]; do
	search_for_container
	retries=$((${retries}-1))
	echo retrying...
	sleep 0.4
done

if [ "${container}" != "" ]; then
    echo Found running \"${image}\" container: ${container}, starting shell
    docker exec -u cxx-developer -it ${container} /bin/bash
else
    echo No \"${image}\" container found, check the status of the container
fi
