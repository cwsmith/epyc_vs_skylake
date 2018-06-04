# Copyright (c) 2017, Lawrence Livermore National Security, LLC. Produced at
# the Lawrence Livermore National Laboratory. LLNL-CODE-734707. All Rights
# reserved. See files LICENSE and NOTICE for details.
#
# This file is part of CEED, a collection of benchmarks, miniapps, software
# libraries and APIs for efficient high-order finite element and spectral
# element discretizations for exascale applications. For more information and
# source code availability see http://github.com/ceed.
#
# The CEED research is supported by the Exascale Computing Project (17-SC-20-SC)
# a collaborative effort of two U.S. Department of Energy organizations (Office
# of Science and the National Nuclear Security Administration) responsible for
# the planning and preparation of a capable exascale ecosystem, including
# software, applications, hardware, advanced system engineering and early
# testbed platforms, in support of the nation's exascale computing imperative.

# Configuration for LLNL's Quartz system

function setup_intel()
{
   module load intel/16.0.3
   module load mvapich2/2.2
   MPICC=mpicc
   MPICXX=mpicxx
   MPIF77=mpif77
   mpi_info_flag="-v"

   CFLAGS="-O3"
   FFLAGS="-O3"
   TEST_EXTRA_CFLAGS="-xHost"
   NATIVE_CFLAG="-xHost"

   NEK5K_EXTRA_PPLIST=""
}


function setup_gcc()
{
   module load gcc/7.1.0
   module load mvapich2/2.2
   MPICC=mpicc
   MPICXX=mpicxx
   MPIF77=mpif77

   CFLAGS="-O3"
   FFLAGS="$CFLAGS"
   TEST_EXTRA_CFLAGS="-march=native --param max-completely-peel-times=3"
   # TEST_EXTRA_CFLAGS+=" -std=c++11 -fdump-tree-optimized-blocks"
   NATIVE_CFLAG="-march=native"

   NEK5K_EXTRA_PPLIST=""
}

function setup_gccOpt()
{
   module load gcc/7.1.0
   module load mvapich2/2.2
   MPICC=mpicc
   MPICXX=mpicxx
   MPIF77=mpif77

   CFLAGS="-O3 -march=znver1 -flto"
   FFLAGS="$CFLAGS"
}

function setup_aocc()
{
   module load gcc/7.1.0
   module load mvapich2/2.2
   source /g/g19/smith516/software/setenv_AOCC.sh
   MPICC=mpicc
   MPICXX=mpicxx
   MPIF77=mpif77
   MPICH_CC=clang
   MPICH_CCC=clang++
   MPICH_F90=flang

   CFLAGS="-O3"
   FFLAGS="$CFLAGS"
}

function setup_aoccOpt()
{
   module load gcc/7.1.0
   module load mvapich2/2.2
   source /g/g19/smith516/software/setenv_AOCC.sh
   MPICC=mpicc
   MPICXX=mpicxx
   MPIF77=mpif77
   MPICH_CC=clang
   MPICH_CCC=clang++
   MPICH_F90=flang

   CFLAGS="-O3 -march=znver1 -flto -fuse-ld=lld"
   FFLAGS="$CFLAGS"
}

function set_mpi_options()
{
   # run in interactive mode
   # Run all tasks on the same node.
   num_proc_node=${num_proc_run}
   compose_mpi_run_command
}


MFEM_EXTRA_CONFIG=""

valid_compilers="intel gcc gccOpt aocc aoccOpt"
num_proc_build=${num_proc_build:-48}
num_proc_run=${num_proc_run:-48}
num_proc_node=${num_proc_node:-48}
memory_per_node=256
# node_virt_mem_lim=

# Optional (default): MPIEXEC (mpirun), MPIEXEC_OPTS (), MPIEXEC_NP (-np)
MPIEXEC=srun
MPIEXEC_NP=-n
