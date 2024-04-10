% Savio intermediate training: Savio tips and tricks: making the most of the Slurm scheduler and of installing/using software in Mamba/Conda environments
% April 18, 2024
% Chris Paciorek and Jeffrey Jacob

# Upcoming events and hiring

 - We offer platforms and services for researchers working with [sensitive data](https://docs-research-it.berkeley.edu/services/srdc/)

 - Get paid to develop your skills in research data and computing! Berkeley Research Computing is hiring several graduate student Domain Consultants for flexible appointments, 10% to 25% effort (4-10 hours/week). Email your cover letter and CV to: research-it@berkeley.edu.

# Introduction

We'll do this mostly as a demonstration. We encourage you to login to your account and try out the various examples yourself as we go through them.

Much of this material is based on the extensive Savio documention we have prepared and continue to prepare, available at [https://docs-research-it.berkeley.edu/services/high-performance-computing/](https://docs-research-it.berkeley.edu/services/high-performance-computing/).

The materials for this tutorial are available using git at the short URL ([tinyurl.com/brc-oct22](https://tinyurl.com/brc-apr24)), the  GitHub URL ([https://github.com/ucb-rit/savio-training-slurm-conda-spring-2024](https://github.com/ucb-rit/savio-training-slurm-conda-spring-2024)), or simply as a [zip file](https://github.com/ucb-rit/savio-training-slurm-conda-spring-2024/archive/main.zip).

# Outline

[UNDER CONSTRUCTION]

This training session will cover the following topics:

- Slurm tips and tricks
  - Associations: Accounts, partitions and queues
  - Understanding the queue and getting jobs to start faster
  - Diagnosing Slurm submission errors
  - Using Slurm flags for parallelization
    - ntasks vs. cpus-per-task
    - per-node and per-core scheduling
    - MPI and ntasks
    - Gnu parallel
  - Using MPI and troubleshooting problems
  - Requesting GPUs, GPU types
  - Requesting particular features and including/excluding nodes
  - Diagnosing job run-time errors and monitoring jobs
- Working with Conda/Mamba environments
    - Setting up environments
      - Mamba and dependency resolution
      - Channels (conda-forge, anaconda, nvidia)
      - Using pip when needed to install within an environment
      - Creating and using export files
      - Best practices
    - Activating environments
      - source activate vs. conda activate
      - Environment variables, .env file 
    - Isolating environments 
      - Explicitly requesting a Python version to isolate from system base env
      - Avoiding use of pip packages in ~/.local
    - Using scratch vs. home
      - For a specific environment
      - For ~/.conda (`envs` and `pkgs`)
    - Setting up Jupyter kernels
    - Using mamba/conda for non-Python related software


# Submitting jobs: overview

All computations are done by submitting jobs to the scheduling software that manages jobs on the cluster, called SLURM.

Why is this necessary? Otherwise your jobs would be slowed down by other people's jobs running on the same node. This also allows everyone to share Savio in a fair way.

The basic workflow is:

 - login to Savio; you'll end up on one of the login nodes in your home directory
 - use `cd` to go to the directory from which you want to submit the job
 - submit the job using `sbatch` (or an interactive job using `srun`, discussed later)
    - when your job starts, the working directory will be the one from which the job was submitted
    - the job will be running on a compute node, not the login node

# Submitting jobs: accounts and partitions

When submitting a job, the main things you need to indicate are the project account you are using and the partition. Note that there is a default value for the project account, but if you have access to multiple accounts such as an FCA and a condo, it's good practice to specify it.

You can see what accounts you have access to and which partitions within those accounts as follows:

```
sacctmgr -p show associations user=$USER
```

Here's an example of the output for a user who has access to an FCA and a condo:
```
Cluster|Account|User|Partition|Share|GrpJobs|GrpTRES|GrpSubmit|GrpWall|GrpTRESMins|MaxJobs|MaxTRES|MaxTRESPerNode|MaxSubmit|MaxWall|MaxTRESMins|QOS|Def QOS|GrpTRESRunMins|
brc|fc_paciorek|paciorek|savio3_gpu|1|||||||||||||gtx2080_gpu3_normal,savio_lowprio,v100_gpu3_normal|gtx2080_gpu3_normal||
brc|fc_paciorek|paciorek|savio3_htc|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio3_bigmem|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio3|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_1080ti|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_knl|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_gpu|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_htc|1|||||||||||||savio_debug,savio_long,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_bigmem|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio_bigmem|1|||||||||||||savio_debug,savio_normal|savio_normal||
brc|co_stat|paciorek|savio3_htc|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio3_bigmem|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio3|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_1080ti|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_knl|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_bigmem|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_gpu|1|||||||||||||savio_lowprio,stat_gpu2_normal|stat_gpu2_normal||
brc|co_stat|paciorek|savio2_htc|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio_bigmem|1|||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2|1|||||||||||||savio_lowprio,stat_savio2_normal|stat_savio2_normal||
```

If you are part of a condo, you'll notice that you have *low-priority* access to certain partitions. For example, user 'paciorek' is part of the statistics condo *co_stat*, which purchased some savio2 nodes and savio2_gpu nodes and therefore has normal access to those, but he can also burst beyond the condo and use other partitions at low-priority (see below).

In contrast, through his FCA, 'paciorek' has access to the savio, savio2, and savio3 partitions as well as various big memory, HTC, and GPU partitions, all at normal priority.

# Submitting a batch job

Let's see how to submit a simple job. If your job will only use the resources on a single node, you can do the following.

Here's an example job script that I'll run. You'll need to modify the --account value and possibly the --partition value.

```bash
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=fc_paciorek
#
# Partition:
#SBATCH --partition=savio2
#
# Wall clock limit (5 minutes here):
#SBATCH --time=00:05:00
#
## Command(s) to run:
module load python/3.9.12
python calc.py >& calc.out
```

Now let's submit and monitor the job:

```
sbatch job.sh

squeue -j <JOB_ID>

wwall -j <JOB_ID>
```

After a job has completed (or been terminated/cancelled), you can review the maximum memory used via the sacct command.

```
sacct -j <JOB_ID> --format=JobID,JobName,MaxRSS,Elapsed
```

MaxRSS will show the maximum amount of memory that the job used in kilobytes.

You can also login to the node where you are running and use commands like *top* and *ps*:

```
srun --jobid=<JOB_ID> --pty /bin/bash
```

NOTE: except for the partitions named *_htc and *_gpu, all jobs are given exclusive access to the entire node or nodes assigned to the job (and your account is charged for all of the cores on the node(s)).


# Parallel job submission

If you are submitting a job that uses multiple nodes, you'll need to carefully specify the resources you need. The key flags for use in your job script are:

 - `--nodes` (or `-N`): indicates the number of nodes to use
 - `--ntasks-per-node`: indicates the number of tasks (i.e., processes) one wants to run on each node
 - `--cpus-per-task` (or `-c`): indicates the number of cpus to be used for each task

In addition, in some cases it can make sense to use the `--ntasks` (or `-n`) option to indicate the total number of tasks and let the scheduler determine how many nodes and tasks per node are needed. In general `--cpus-per-task` will be one except when running threaded code.  

Here's an example job script for a job that uses MPI for parallelizing over multiple nodes:

```bash
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=account_name
#
# Partition:
#SBATCH --partition=partition_name
#
# Number of MPI tasks needed for use case (example):
#SBATCH --ntasks=40
#
# Processors per task:
#SBATCH --cpus-per-task=1
#
# Wall clock limit:
#SBATCH --time=00:00:30
#
## Command(s) to run (example):
module load intel openmpi
mpirun ./a.out
```

When you write your code, you may need to specify information about the number of cores to use. SLURM will provide a variety of variables that you can use in your code so that it adapts to the resources you have requested rather than being hard-coded.

Here are some of the variables that may be useful: SLURM_NTASKS, SLURM_CPUS_PER_TASK, SLURM_NODELIST, SLURM_NNODES.

NOTE: when submitting GPU jobs [you need to request multiple CPUs per GPU](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/submitting-jobs/#gpu-jobs) (usually 2 GPUs, but for some of the GPU types in savio3_gpu, 4 or 8 GPUs).

# Parallel job submission patterns

Some common paradigms are:

 - 1 node, many CPUs
     - openMP/threaded jobs - 1 task, *c* CPUs for the task
     - Python/R/GNU parallel - many tasks, 1 per CPU at any given time
 - many nodes, many CPUs
     - MPI jobs that use 1 CPU per task for each of *n* tasks, spread across multiple nodes
     - Python/R/GNU parallel - many tasks, 1 per CPU at any given time
 - hybrid jobs that use *c* CPUs for each of *n* tasks
     - e.g., MPI+threaded code

We have lots more [examples of job submission scripts](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/scheduler-examples) for different kinds of parallelization (multi-node (MPI), multi-core (openMP), hybrid, etc.


# Interactive jobs

You can also do work interactively. This simply moves you from a login node to a compute node.

```
srun -A fc_paciorek -p savio2_htc  -c 1 -t 10:0 --pty bash

# note that you end up in the same working directory as when you submitted the job

# now execute on the compute node:
env | grep SLURM
module load matlab
matlab -nodesktop -nodisplay
```

To end your interactive session (and prevent accrual of additional charges to your FCA), simply enter `exit` in the terminal session.

NOTE: you are charged for the entire node when running interactive jobs (as with batch jobs) except in the HTC and GPU (*_htc and *_gpu) partitions.

# Running graphical interfaces interactively

If you are running a graphical interface, we recommend you use [Savio's Open OnDemand interface](https://ood.brc.berkeley.edu) (more in a later slide), e.g.,

 - Jupyter Notebooks
 - RStudio
 - the MATLAB GUI
 - VS Code
 - remote desktop

# Low-priority queue

Condo users have access to the broader compute resource that is limited only by the size of partitions, under the *savio_lowprio* QoS (queue). However this QoS does not get a priority as high as the general QoSs, such as *savio_normal* and *savio_debug*, or all the condo QoSs, and it is subject to preemption when all the other QoSs become busy.

More details can be found [in the *Low Priority Jobs* section of the user guide](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/submitting-jobs/#low-priority).

Suppose I wanted to burst beyond the Statistics condo to run on 20 nodes. I'll illustrate here with an interactive job though usually this would be for a batch job.


```
## First I'll see if there are that many nodes even available.
sinfo -p savio2
srun -A co_stat -p savio2 --qos=savio_lowprio --nodes=20 -t 10:00 --pty bash

## now look at environment variables to see my job can access 20 nodes:
env | grep SLURM
```

The low-priority queue is also quite useful for accessing specific GPU types in the `savio3_gpu` partition.

# HTC jobs (and long-running jobs)

There are multiple "HTC" partitions (savio2_htc, savio3_htc, savio4_htc [coming soon]) that allow you to request cores individually rather than an entire node at a time. In some cases the nodes in these partition are faster than the other nodes. Here is an example SLURM script:

```
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=account_name
#
# Partition:
#SBATCH --partition=savio3_htc
#
# Processors per task:
#SBATCH --cpus-per-task=2
#
# Wall clock limit -- 10 minutes
#SBATCH --time=00:10:00
#
## Command(s) to run (example):
module load python/3.9.12
python calc.py >& calc.out
```

One can run jobs up to 10 days (using four or fewer cores) in the *savio2_htc* partition if you include `--qos=savio_long`.

# Alternatives to the HTC partition for collections of serial jobs

You may have many serial jobs to run. It may be more cost-effective to collect those jobs together and run them across multiple cores on one or more nodes.

Here are some options:

  - using [GNU parallel](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/) to run many computational tasks (e.g., thousands of simulations, scanning tens of thousands of parameter values, etc.) as part of single Savio job submission
  - using [single-node or multi-node parallelism](https://berkeley-scf.github.io/tutorial-parallelization) in Python, R, and MATLAB
    - parallel R tools such as *future*, *foreach*, *parLapply*, and *mclapply*
    - parallel Python tools such as  *ipyparallel*, *Dask*, and *ray*
    - parallel functionality in MATLAB through *parfor*

# Monitoring jobs, the job queue, and overall usage

The basic command for seeing what is running on the system is `squeue`:
```
squeue
squeue -u $USER
squeue -A co_stat
```

To see what nodes are available in a given partition:
```
sinfo -p savio3
sinfo -p savio2_gpu
```

You can cancel a job with `scancel`.
```
scancel <YOUR_JOB_ID>
```

For more information on cores, QoS, and additional (e.g., GPU) resources, here's some syntax:
```
squeue -o "%.7i %.12P %.20j %.8u %.2t %.9M %.5C %.8r %.3D %.20R %.8p %.20q %b"
```

We provide some [tips about monitoring your jobs](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/monitoring-jobs/).

If you'd like to see how much of an FCA has been used:

```
check_usage.sh -a fc_rail
```

# When will my job start?

The new `sq` tool on Savio provides a bit more user-friendly way to understand why your job isn't running yet. Here's the basic usage:
```
# should be loaded by default, but if it isn't:
# module load sq
sq
```

```
Showing results for user paciorek
Currently 0 running jobs and 1 pending job (most recent job first):
+---------|------|-------------|-----------|--------------|------|---------|-----------+
| Job ID  | Name |   Account   |   Nodes   |     QOS      | Time |  State  |  Reason   |
+---------|------|-------------|-----------|--------------|------|---------|-----------+
| 7510375 | test | fc_paciorek | 1x savio2 | savio_normal | 0:00 | PENDING | Resources |
+---------|------|-------------|-----------|--------------|------|---------|-----------+

7510375:
This job is scheduled to run after 21 higher priority jobs.
    Estimated start time: N/A
    To get scheduled sooner, you can try reducing wall clock time as appropriate.

Recent jobs (most recent job first):
+---------|------|-------------|-----------|----------|---------------------|-----------+
| Job ID  | Name |   Account   |   Nodes   | Elapsed  |         End         |   State   |
+---------|------|-------------|-----------|----------|---------------------|-----------+
| 7509474 | test | fc_paciorek | 1x savio2 | 00:00:16 | 2021-02-09 23:47:45 | COMPLETED |
+---------|------|-------------|-----------|----------|---------------------|-----------+

7509474:
 - This job ran for a very short amount of time (0:00:16). You may want to check that the output was correct or if it exited because of a problem.
 ```

To see another user's jobs:

```
sq -u paciorek
```

The `-a` flag shows current and past jobs together, the `-q` flag suppresses messages about job issues, and the `-n` flag sets the limit on the number of jobs to show in the output (default = 8).

```
sq -u paciorek -aq -n 10
```

```
Showing results for user paciorek
Recent jobs (most recent job first):
+-----------|------|-------------|-----------|------------|---------------------|-----------+
|  Job ID   | Name |   Account   |   Nodes   |  Elapsed   |         End         |   State   |
+-----------|------|-------------|-----------|------------|---------------------|-----------+
| 7487633.1 | ray  |   co_stat   |    1x     | 1-20:19:03 |       Unknown       |  RUNNING  |
| 7487633.0 | ray  |   co_stat   |    1x     | 1-20:19:08 |       Unknown       |  RUNNING  |
|  7487633  | test |   co_stat   | 2x savio2 | 1-20:19:12 |       Unknown       |  RUNNING  |
|  7487879  | bash | ac_scsguest | 1x savio  |  00:00:27  | 2021-02-08 14:54:19 | COMPLETED |
| 7487633.2 | bash |   co_stat   |    2x     |  00:00:34  | 2021-02-08 14:53:38 |  FAILED   |
|  7487515  | test |   co_stat   | 2x savio2 |  00:04:53  | 2021-02-08 14:22:17 | CANCELLED |
| 7487515.1 | ray  |   co_stat   |    1x     |  00:00:06  | 2021-02-08 14:17:39 |  FAILED   |
| 7487515.0 | ray  |   co_stat   |    1x     |  00:00:05  | 2021-02-08 14:17:33 |  FAILED   |
|  7473988  | test |   co_stat   | 2x savio2 | 3-00:00:16 | 2021-02-08 13:33:40 |  TIMEOUT  |
|  7473989  | test | ac_scsguest | 2x savio  | 2-22:30:11 | 2021-02-08 11:47:54 | CANCELLED |
+-----------|------|-------------|-----------|------------|---------------------|-----------+
```

For help with `sq`:

```
sq -h
```

To learn more, see our page on understanding [when your jobs will run](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/why-job-not-run/).


# How to get additional help

 - Check the Status and Announcements page:
    - [https://research-it.berkeley.edu/services/high-performance-computing/status-and-announcements](https://research-it.berkeley.edu/services/high-performance-computing/status-and-announcements)
 - For technical issues and questions about using Savio:
    - brc-hpc-help@berkeley.edu
 - For questions about computing resources in general, including cloud computing:
    - brc@berkeley.edu
    - office hours: office hours: Wed. 1:30-3:00 and Thur. 9:30-11:00 [on Zoom](https://research-it.berkeley.edu/programs/berkeley-research-computing/research-computing-consulting)
 - For questions about data management (including HIPAA-protected data):
    - researchdata@berkeley.edu
    - office hours: office hours: Wed. 1:30-3:00 and Thur. 9:30-11:00 [on Zoom](https://research-it.berkeley.edu/programs/berkeley-research-computing/research-computing-consulting)
