datadir='../../DATA/'
inputfile=$1
cp ${datadir}${inputfile} Community_latest/

cd Community_latest/
#make clean
#make

tr ',' ' ' < ${inputfile} > ${inputfile}.sp
graphfile=${inputfile}.sp

./convert -i ${graphfile} -o ${graphfile}.bin -w ${graphfile}.weights
./community ${graphfile}.bin -l -1 -w ${graphfile}.weights -q 0.0001 > ${graphfile}.tree
nlevels=`./hierarchy ${graphfile}.tree | sed -n 1p | cut -d' ' -f4`
btmlvl=`expr $nlevels - 1`
./hierarchy ${graphfile}.tree -l $btmlvl > ${graphfile}.comm
resultdir=`echo ${inputfile} | cut -d'.' -f1`/
mkdir ../${resultdir}
mv ${inputfile}* ../${resultdir}
cd .. 
pwd
cp ${resultdir}* ../VariablePrecisionIntegers/VariablePrecisionIntegers

