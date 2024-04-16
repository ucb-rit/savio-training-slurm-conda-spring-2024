#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=fc_paciorek
#
# Partition:
#SBATCH --partition=savio3_htc
#
# Wall clock limit (45 seconds here):
#SBATCH --time=00:00:45
#
## Command(s) to run:
module load python/3.10.10    
python calc.py >& calc.out
