#!/bin/bash
#SBATCH --partition=compute2
#SBATCH --account=bb0519
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=36
#SBATCH --time=05:00:00

# Script to run NEMO on Mistral, DKRZ, Hamburg, Germany

# Begin of section with executable commands
set -e
ls -l

if [ -e mesh_mask_0000.nc ] ; then
   rm mesh_mask_????.nc 
fi

module purge
module load gcc/4.8.2
module unload intel && module load intel
module load cdo nco netcdf_c
export LD_LIBRARY_PATH=/sw/rhel6-x64/gcc/gcc-4.8.2/lib64:$LD_LIBRARY_PATH 

module unload intelmpi
module load intel/18.0.4 intelmpi/2018.5.288 autoconf/2.69
export MPIROOT=$($MPIFC -show | perl -lne 'm{ -I(.*?)/include } and print $1') 

export I_MPI_FABRICS=shm:dapl
export I_MPI_FALLBACK=disable
export I_MPI_SLURM_EXT=1
export I_MPI_LARGE_SCALE_THRESHOLD=8192 # Set to a value larger than the number of your MPI-tasks if you use 8192 or more tasks.
export I_MPI_DYNAMIC_CONNECTION=0
export DAPL_NETWORK_NODES=$SLURM_NNODES
export DAPL_NETWORK_PPN=$SLURM_NTASKS_PER_NODE
export DAPL_WR_MAX=500

module unload netcdf && module load netcdf_c/4.3.2-gcc48
module unload cmake && module load cmake/3.5.2
export PATH=/sw/rhel6-x64/gcc/binutils-2.24-gccsys/bin:${PATH}
export MPI_LIB=$($MPIFC -show |sed -e 's/^[^ ]*//' -e 's/-[I][^ ]*//g')

export HDF5ROOT=/sw/rhel6-x64/hdf5/hdf5-1.8.16-parallel-impi-intel14/
export NETCDFROOT=/sw/rhel6-x64/netcdf/netcdf_c-4.4.0-parallel-impi-intel14/
export NETCDFFROOT=/sw/rhel6-x64/netcdf/netcdf_fortran-4.4.3-parallel-impi-intel14/
export PNETCDFROOT=/sw/rhel6-x64/netcdf/parallel_netcdf-1.6.1-impi-intel14/

export SZIPROOT=/sw/rhel6-x64/sys/libaec-0.3.2-gcc48

export LD_LIBRARY_PATH=${NETCDFFROOT}/lib:${HDF5ROOT}/lib:${NETCDFROOT}/lib:${SZIPROOT}/lib:${PNETCDFROOT}/lib:$LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH "

export XIOSROOT=/pf/b/b350090/models/xios-2.5/

module list

srun -l --kill-on-bad-exit=1 --cpu_bind=cores --distribution=block:cyclic --propagate=STACK,CORE ./nemo


