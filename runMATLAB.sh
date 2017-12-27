#!/bin/bash
echo "cd ${1}" > runMATLAB.m
a=${@}
command="${2}("

count=0
for var in "$@"
do
    (( count++ ))
done

i=1
start=2
for var in "$@"
do
	if [ "$i" -gt "$start" ];then
		if [ "$i" -lt "$count" ];then
			command="$command${var},"
		else
			command="$command${var})"
		fi 
	fi

    (( i++ ))

done

echo $command >>runMATLAB.m
matlab -nodisplay -nosplash < runMATLAB.m | tail -n +11
rm runMATLAB.m
