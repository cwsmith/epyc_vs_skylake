#!/bin/bash -e
module load gcc/7.1.0
module load mvapich2/2.2
source /g/g19/smith516/software/setenv_AOCC.sh

set -x

wget --no-verbose --no-parent --recursive --level=1 --no-directories https://www.cs.virginia.edu/stream/FTP/Code/
clang -O3 -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_O3
clang -O3 -march=znver1 -flto -fuse-ld=lld -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_opt

export OMP_DISPLAY_ENV=1
export OMP_PLACES=cores
export OMP_PROC_BIND=close

log=opt_place${OMP_PLACES}_bind${OMP_PROC_BIND}.log
cat /dev/null > $log
for i in {1..96}; do 
  export OMP_NUM_THREADS=$i
  ./stream_aocc_omp_opt &>> $log
done 
awk '/^Triad/ {print $2}' $log > $log.triad

log=O3_place${OMP_PLACES}_bind${OMP_PROC_BIND}.log
cat /dev/null > $log
for i in {1..96}; do 
  export OMP_NUM_THREADS=$i
  ./stream_aocc_omp_O3 &>> $log
done 
awk '/^Triad/ {print $2}' $log > $log.triad

set +x
