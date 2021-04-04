#!/bin/sh

name={project_name}

print_usage(){
cat << EOF     
Usage:                      
        $name [?] ?
                frobnicate the frobnicee
        -h, --help
                prints this help message
EOF                                    
}

#-o i: <- expects argument
#-o : <- doesn't expect argument
OPTS=`getopt -o h --long help -n "$name"  -- "$@"`
if [ $? != 0 ] ; then echo "Failed to parse args" >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true;do
case "$1" in
-h|--help)
	print_usage
	exit 0
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

