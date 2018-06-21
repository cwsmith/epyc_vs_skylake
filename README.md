## MFEM 

Clone the benchmarking repo

`git clone git@github.com:CEED/benchmarks.git ceed-benchmarks`

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

`bp1` was executed on a dual socket AMD EPYC 7451 node using GCC 7.1.0 and AOCC 1.2 
with MVAPICH2, and the 2018 Intel compiler and MPI implementation.
Each 7451 has 24 cores and supports two hardware threads per core (96 threads in
total).  The node has 256GB (16GB x16) of RAM running at 2.67Ghz.

http://www.cpu-world.com/CPUs/Zen/AMD-EPYC%207451.html

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

### Lyra

`bp1` was executed on a single socket AMD EPYC 7451 node using AOCC 1.2 with
MPICH 3.1.2.  Each 7451 has 24 cores and supports two hardware threads per core (48 threads in
total).  The node has 128GB of RAM running at 2.67Ghz.  Note, the motherboard
design places two DIMMs per channel ('dual rank') which results in the memory
only running at 2.4Ghz; a 10% reduction.

The AOCC 1.2 C++ and Fortran (not required for mfem) was installed using the
tarballs and directions here:

https://developer.amd.com/amd-aocc/

Run the tests:

```
cp epyc_vs_skylake/mfem/machine-configs/lyra.sh ceed-benchmarks/machine-configs
salloc -N 1 -t60
cd ceed-benchmarks/tests/mfem_bps/
procs="3 6 12 24 48"
base_nxyz="1 1 3" ../../go.sh -c lyra -m aocc -r bp1_v1.sh -n "$procs" -p "$procs" &> lyra_bp1_aocc12.txt
```

### Post Processing

Generate plots for each system-compiler pair:

```
cd epyc_vs_skylake/mfem/bp1/<system-compiler>/
ln -s ceed-benchmarks/tests/mfem_bps/*.py .
python postprocess-plot-1.py *.txt
python postprocess-plot-2.py *.txt
python postprocess-plot-3.py *.txt
```

Generate comparison plots between system-compiler pairs A and B:

```
cd epyc_vs_skylake/mfem/bp1/<system-compiler-A_vs_system-compiler-B>/
ln -s ceed-benchmarks/tests/mfem_bps/*.py .
python postprocess-plot-4.py ../<system-compiler-A>/*.txt ../<system-compiler-B>/*.txt
```


## STREAM Triad

### Stampede2

Peak OpenMP STREAM Triad performance using the Intel18 compiler on the two socket Skylake nodes on Stampede2 is 211 GB/s.

The following TACC benchmarking report lists a 194 GB/s using the Intel17 compiler:

https://repositories.lib.utexas.edu/bitstream/handle/2152/61472/SKX_Benchmarking.pdf?sequence=2&isAllowed=y

.  Colfax Research also has an article here the discusses other Xeon SKUs:

https://colfaxresearch.com/xeon-2017/#sec-3

### IPA

Peak OpenMP STREAM Triad performance on the two socket EPYC nodes on IPA is 200 GB/s
using GCC 7.1.0.  

AOCC 1.2 test results peak at 153 GB/s and oscillate significantly versus thread count.

The following AnAndTech and Tirias Research articles discuss the EPYC NUMA domains.  AnAndTech testing produces a slightly higher peak bandwidth of 207 GB/s using the Intel compilers.

https://www.anandtech.com/show/11544/intel-skylake-ep-vs-amd-epyc-7000-cpu-battle-of-the-decade/12

https://www.amd.com/system/files/2018-03/AMD-Optimizes-EPYC-Memory-With-NUMA.pdf

#### execution

Allocate an EPYC node and run the `runStream` script.

```
./runStream.sh <download=0|1> <compiler=gcc|aocc>
```

### Lyra

Peak OpenMP STREAM Triad performance on the one socket EPYC nodes on Lyra is 101 GB/s
using GCC 5.4.0.  

AOCC 1.2 test results peak at 85 GB/s and oscillate significantly versus thread count.

#### execution

Allocate an EPYC node and run the `runStream` script.

```
./runStream.sh <download=0|1> <compiler=gcc|aocc>
```



### Post Processing

This produces \*.log and \*.log.triad files with the STREAM output and the triad
peak bandwidth results, respectively.  The contents of the \*.log.triad files
can be plotted (generates `<outfig name>.png`) with the `plot.py` script:

```
../plot.py  <outfig name> <input log> [...<input log>]
```





