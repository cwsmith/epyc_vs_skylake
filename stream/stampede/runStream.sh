#!/bin/bash -e
usage="Usage: $0 <download=0|1>"
[ $# -ne 1 ] && echo $usage && exit 1

download=$1
[[ "$download" != "0" && "$download" != "1" ]] && echo "download set to '$download'" && echo $usage && exit 1

if [ "$download" == "1" ]; then
  cmd='wget --no-verbose --no-parent --recursive --level=1 --no-directories'
  $cmd https://www.cs.virginia.edu/stream/FTP/Code/ #openmp stream
  $cmd http://www.cs.virginia.edu/stream/FTP/Code/Versions/ # stream_mpi
fi

module swap intel intel/18.0.2

compiler=intel1802
icc -O3 -fopenmp -D_OPENMP stream.c -o stream_${compiler}_omp_O3

set -x

### OpenMP
export OMP_DISPLAY_ENV=1
export OMP_PLACES=cores
par=omp
for build in O3; do
  for procBind in close spread; do
    export OMP_PROC_BIND=${procBind}
    bin=./stream_${compiler}_${par}_${build}
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
