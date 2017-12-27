datadir='../../DATA/'
inputfile=$1
cp ${datadir}${inputfile} comdet/

cd comdet/

#tr ',' ' ' < ${inputfile} > ${inputfile}.sp
#graphfile=${inputfile}.sp

#./convert -i ${graphfile} -o ${graphfile}.bin -w ${graphfile}.weights
#./community ${graphfile}.bin -l -1 -w ${graphfile}.weights -q 0.0001 > ${graphfile}.tree
#nlevels=`./hierarchy ${graphfile}.tree | sed -n 1p | cut -d' ' -f4`
#btmlvl=`expr $nlevels - 1`
#./hierarchy ${graphfile}.tree -l $btmlvl > ${graphfile}.comm

#remove the edge weight
filename=$(basename "$inputfile")
extension="${filename##*.}"
filename="${filename%.*}"
#filename="${inputfile##*/}"
awk -F ',' '{print $1 "\ " $2}' ${inputfile} >> ${filename}

#rewrite edges
awk -F ',' '{print $2 "\ " $1}' ${inputfile} >> ${filename}

#write congifuration file
echo "edgelistfile = ${filename}" > ${filename}.config
echo "outputfile = ${filename}.csv" >> ${filename}.config
edges=($(wc -l ${filename}))
echo "numEdges = ${edges}" >> ${filename}.config
#wc -l ${inputfile} >> ${filename}.config
echo "numDimensions = 2" >> ${filename}.config
#max=($(sort -n ${filename} | sed -n '1s/^\([0-9]\+\).*$/\1/p;$s/^\([0-9]\+\).*$/\1/p'))
#echo "min=${max[0]}, max=${max[1]}"
max0=($(awk '$1>x{x=$1}END{print x}' ${filename}))
max1=($(awk '$2>x{x=$2}END{print x}' ${filename}))
max=($(($max0 > $max1 ? $max0 : $max1)))
#echo "max=${max}"
max=($(($max + 1)))
max0=($(($max0 + 1)))
max1=($(($max1 + 1)))
echo "dimensionSize0 = $max0" >> ${filename}.config
echo "dimensionSize1 = $max1" >> ${filename}.config
#echo "dimensionSize0 = ${max[1]}" >> ${filename}.config
#echo "dimensionSize1 = ${max[1]}" >> ${filename}.config
echo "shape = hyperbola" >> ${filename}.config
echo "sharedDimension0 = 0" >> ${filename}.config
echo "sharedDimension1 = 0" >> ${filename}.config

#change java path
unset DYLD_FRAMEWORK_PATH DYLD_LIBRARY_PATH

#run hyperbolic
java -jar comdet.jar ${filename}.config

resultdir=`echo ${inputfile} | cut -d'.' -f1`/
mkdir ../${resultdir}
mv ${filename}* ../${resultdir}
cd .. 
#pwd
cp ${resultdir}* ../VariablePrecisionIntegers/VariablePrecisionIntegers

