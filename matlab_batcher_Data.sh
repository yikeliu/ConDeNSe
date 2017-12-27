#!/bin/sh

matlab_exec=matlab
X="${1}('${2}','${3}','${4}')"
echo "cd DATA" > matlab_command_.m
echo ${X} >> matlab_command_.m
cat matlab_command_.m
${matlab_exec} -nodisplay -nosplash < matlab_command_.m | tail -n +11
rm matlab_command_.m
