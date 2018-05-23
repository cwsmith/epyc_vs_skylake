## MFEM 

Clone the benchmarking repo

git clone git@github.com:CEED/benchmarks.git ceed-benchmarks

The scripts provided by this repo with download and build mfem, and then run the
`bp1` benchmark on a range of processes with varying basis function order
and mesh size.

`bp1` requires the total number of processes be a power of two.  Thus, on both
Skylake and EPYC tests do not use all available cores/hardware threads.

### Stampede2

`bp1` was executed on a dual socket Intel Xeon Platinum 8160 Skylake node using
GCC 7.1.0 with Intel MPI 17 and Intel 18.0.0 with Intel MPI 18.

The [Stampede2 User Guide provides the following information on the Skylake nodes](
https://portal.tacc.utexas.edu/user-guides/stampede2#overview-skxcomputenodes)
```
Model:  Intel Xeon Platinum 8160 ("Skylake")
Total cores per SKX node:   48 cores on two sockets (24 cores/socket)
Hardware threads per core:  2
Hardware threads per node:  48 x 2 = 96
Clock rate:   2.1GHz nominal (1.4-3.7GHz depending on instruction set and number of active cores)
RAM:  192GB (2.67GHz)
Cache:  32KB L1 data cache per core; 1MB L2 per core; 33MB L3 per socket. Each
socket can cache up to 57MB (sum of L2 and L3 capacity).
```

https://ark.intel.com/products/120501/Intel-Xeon-Platinum-8160-Processor-33M-Cache-2_10-GHz

Run the tests:

```
cp epyc_vs_skylake/mfem/machine-configs/stampede2.sh ceed-benchmarks/machine-configs
idev -N1 -p skx-dev
cd ceed-benchmarks/tests/mfem_bps/
../../go.sh -c stampede2 -m intel -r bp1_v1.sh -n "4 8 16 32" -p "4 8 16 32" &> stampede2_bp1_intel18.txt
../../go.sh -c stampede2 -m gcc -r bp1_v1.sh -n "4 8 16 32" -p "4 8 16 32" &> stampede2_bp1_gcc7.txt
```

### IPA

`bp1` was executed on a dual socket AMD EPYC 7451 node using GCC 7.1.0 and AOCC 1.2 with MVAPICH2.
Each 7451 has 24 cores and supports two hardware threads per core (96 threads in
total).  The node has 256GB of XYZ memory @ ABC GHz.


The AOCC 1.2 C++ and Fortran (not required for mfem) was installed using the
tarballs and directions here:

https://developer.amd.com/amd-aocc/

Run the tests:

```
cp epyc_vs_skylake/mfem/machine-configs/ipa.sh ceed-benchmarks/machine-configs
salloc -N 1 -t60 -p epyc
cd ceed-benchmarks/tests/mfem_bps/
../../go.sh -c ipa -m aocc -r bp1_v1.sh -n "4 8 16 32" -p "4 8 16 32" &> ipa_bp1_aocc12.txt
../../go.sh -c ipa -m gcc -r bp1_v1.sh -n "4 8 16 32" -p "4 8 16 32" &> ipa_bp1_gcc7.txt
```
