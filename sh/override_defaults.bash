#!/bin/bash

print_usage()
{
	echo "HEY BUDDY"
}

declare -A params
declare -A optmap

optstring="h"
add_short_param_opt()
{
	#Don't add opt if there already is one
	[[ ${optmap[$1]:+1} ]] && return
	optmap[$1]=$2
	optstring="${optsring}$1:"
}

longoptstring="help"
add_long_param_opt()
{
	optmap[$1]=$1
	longoptstring="${longoptstring},$1:"
}

#Default params
params=(
	[foo]="A!"
	[bar]="B!"
	[baz]="C!"
)

#Prepare options for CLI argument parsing
for param in "${!params[@]}"; do
	add_long_param_opt ${param}
	add_short_param_opt ${param:0:1} ${param}
done
add_short_param_opt z baz

#Parse arguments
OPTS=`getopt -o ${optstring} --long ${longoptstring} -- "$@"`
if [ $? != 0 ] ; then echo "Failed to parse args" >&2 ; exit 1 ; fi

eval set -- "$OPTS"


#Overwrite params from environment
for param in "${!params[@]}"; do
	env_var_name=EIRON_SLURM_${param}
	if [ "${!env_var_name}" ]; then
		value=${!env_var_name}
		echo "Setting $param=$value from env"
		params[$param]=$value
	fi
done

#Overwrite params from CLI arguments

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
 opt=${1/#-/}
 opt=${opt/#-/}
 if [[ ! ${optmap[$opt]:+1} ]];then
   echo "$opt is not a valid option"
   break
 fi
 param=${optmap[$opt]}
 echo "Setting $param=$2 from command line"
 params[$param]=$2
 shift
 break
 ;;
esac
shift
done

for param in "${!params[@]}"; do
	echo "$param = ${params[$param]}"
done

