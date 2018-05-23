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

function setup_mpi()
{
   MPICC=mpicc
   MPICXX=mpicxx
   MPIFC=mpifort
   MPIF77=mpif77
   # OpenMPI
   export OMPI_CC="$CC"
   export OMPI_CXX="$CXX"
   export OMPI_FC="$FC"
   # or MPICH
   export MPICH_CC="$CC"
   export MPICH_CXX="$CXX"
   export MPICH_FC="$FC"
}

function setup_mpich()
{
   source /ccs/home/cwsmith/software/mpich-3.2.1/mpich-3.2.1-aocc12.sh
   MPICC=`which mpicc`
   MPICXX=`which mpicxx`
   MPIFC=`which mpifort`
   MPIF77=`which mpif77`

   export MPICH_CC="$CC"
   export MPICH_CXX="$CXX"
   export MPICH_FC="$FC"
}



function setup_gcc()
{
   CC=gcc
   CXX=g++
   FC=gfortran

   setup_mpi

   CFLAGS="-O3"
   FFLAGS="$CFLAGS"
}


function setup_aocc()
{
   source /ccs/home/cwsmith/software/aocc/setenv_AOCC.sh
   CC=clang
   CXX=clang++
   FC=flang

   setup_mpich

   CFLAGS="-O3"
   FFLAGS="$CFLAGS"
}


function set_mpi_options()
{
   # Run all tasks on the same node.
   num_proc_node=${num_proc_run}
   compose_mpi_run_command
}


search_file_list LAPACK_LIB \
   "/usr/lib64/atlas/libsatlas.so" "/usr/lib64/libopenblas.so"

valid_compilers="gcc aocc"
# Number of processors to use for building packages and tests:
num_proc_build=8
# Default number of processors and processors per node for running tests:
num_proc_run=${num_proc_run:-4}
num_proc_node=${num_proc_run}
# Total memory per node:
memory_per_node=128

# Optional (default): MPIEXEC (mpirun), MPIEXEC_OPTS (), MPIEXEC_NP (-np)
