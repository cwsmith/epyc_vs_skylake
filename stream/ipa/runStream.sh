#!/bin/bash -e
usage="Usage: $0 <download=0|1> <compiler=gcc|aocc>"
[ $# -ne 2 ] && echo $usage && exit 1

download=$1
[[ "$download" != "0" && "$download" != "1" ]] && echo "download set to '$download'" && echo $usage && exit 1

compiler=$2
[[ "$compiler" != "gcc" && "$compiler" != "aocc" ]] && echo "compiler set to '$compiler'" && echo $usage && exit 1

if [ "$download" == "1" ]; then
  cmd='wget --no-verbose --no-parent --recursive --level=1 --no-directories'
  $cmd https://www.cs.virginia.edu/stream/FTP/Code/ #openmp stream
  $cmd http://www.cs.virginia.edu/stream/FTP/Code/Versions/ # stream_mpi
fi

aoccver=1.2
gccver=6.1.0
module load gcc/${gccver}
module load mvapich2/2.3

if [ "$compiler" == "aocc" ]; then
  compiler=${compiler}${aoccver}
  source /g/g19/smith516/software/setenv_AOCC.sh
  clang -O3 -fopenmp -D_OPENMP stream.c -o stream_${compiler}_omp_O3
  clang -O3 -march=znver1 -flto -fuse-ld=lld -fopenmp -D_OPENMP stream.c -o stream_${compiler}_omp_opt
fi

if [ "$compiler" == "gcc" ]; then
  compiler=${compiler}${gccver}
  gcc -O3 -fopenmp -D_OPENMP stream.c -o stream_${compiler}_omp_O3
  gcc -O3 -march=native -flto -fopenmp -D_OPENMP stream.c -o stream_${compiler}_omp_opt
  mpicc -O3 stream_mpi.c -o stream_${compiler}_mpi_O3
  mpicc -O3 -march=native -flto stream_mpi.c -o stream_${compiler}_mpi_opt
fi

set -x


### MPI
par=mpi
for build in opt O3; do
  bin=./stream_${compiler}_${par}_${build}
  log=${build}_${compiler}_${par}.log
  cat /dev/null > $log
  for i in {1..96}; do
    srun -n $i $bin &>> $log
  done
  awk '/^Triad/ {print $2}' $log > $log.triad
done

### OpenMP
export OMP_DISPLAY_ENV=1
export OMP_PLACES=cores
par=omp
for build in opt O3; do
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
