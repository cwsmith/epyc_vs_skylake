#!/bin/bash -e
module load gcc/7.1.0
module load mvapich2/2.2
source /g/g19/smith516/software/setenv_AOCC.sh

set -x

wget --no-verbose --no-parent --recursive --level=1 --no-directories https://www.cs.virginia.edu/stream/FTP/Code/
clang -O3 -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_O3
clang -O3 -march=znver1 -flto -fuse-ld=lld -fopenmp -D_OPENMP stream.c -o stream_aocc_omp_opt
cat /dev/null > opt.log; for i in {1..96}; do export OMP_NUM_THREADS=$i; ./stream_aocc_omp_opt >> opt.log; done
cat /dev/null > O3.log; for i in {1..96}; do export OMP_NUM_THREADS=$i; ./stream_aocc_omp_O3 >> O3.log; done
awk '/^Triad/ {print $2}' opt.log > opt.triad.log
awk '/^Triad/ {print $2}' O3.log > O3.triad.log

set +x
