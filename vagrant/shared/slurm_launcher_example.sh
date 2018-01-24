#!/bin/bash -l
##################################################################
#
#SBATCH -N 1
### -c, --cpus-per-task=<ncpus>
###     (multithreading) Request that ncpus be allocated per process
#SBATCH -c 1
#
#SBATCH --time=0-01:00:00   # 1 hour
#
#          Set the name of the job
#SBATCH -J NAME

#          Passive jobs specifications
###SBATCH --partition batch
###SBATCH --qos qos-batch

### General SLURM Parameters
echo "SLURM_JOBID        = ${SLURM_JOBID}"
echo "SLURM_JOB_NODELIST = ${SLURM_JOB_NODELIST}"
echo "SLURM_NNODES = ${SLURM_NNODES}"
echo "SLURM_NTASK  = ${SLURM_NNODES}"
echo "SLURMTMPDIR  = ${SLURMTMPDIR}"
echo "Submission directory = ${SLURM_SUBMIT_DIR}"

sleep 10
