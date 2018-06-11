#!/bin/bash -e
usage="Usage: $0 <download=0|1> <compiler=gcc|aocc>"
[ $# -ne 2 ] && echo $usage && exit 1

download=$1
[[ "$download" != "0" && "$download" != "1" ]] && echo "download set to '$download'" && echo $usage && exit 1

compiler=$2
[[ "$compiler" != "gcc" && "$compiler" != "aocc" ]] && echo "compiler set to '$compiler'" && echo $usage && exit 1

if [ "$download" == "1" ]; then
  wget --no-verbose --no-parent --recursive --level=1 --no-directories https://www.cs.virginia.edu/stream/FTP/Code/
fi

module load gcc/7.1.0
module load mvapich2/2.2

if [ "$compiler" == "aocc" ]; then
  source /g/g19/smith516/software/setenv_AOCC.sh
  clang -O3 -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_O3
  clang -O3 -march=znver1 -flto -fuse-ld=lld -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_opt
fi

if [ "$compiler" == "gcc" ]; then
  gcc -O3 -fopenmp -D_OPENMP stream.c -o stream_gcc_omp_O3
  gcc -O3 -march=native -flto -fopenmp -D_OPENMP stream.c -o stream_gcc_omp_opt
fi

set -x

export OMP_DISPLAY_ENV=1
export OMP_PLACES=cores

for build in opt O3; do
  for procBind in close spread; do
    export OMP_PROC_BIND=${procBind}
    bin=./stream_${compiler}_omp_${build}
    log=${build}_${compiler}_place${OMP_PLACES}_bind${OMP_PROC_BIND}.log
    cat /dev/null > $log
    for i in {1..96}; do
      export OMP_NUM_THREADS=$i
      $bin &>> $log
    done
    awk '/^Triad/ {print $2}' $log > $log.triad
  done
done

set +x
