#!/bin/bash
#$ -S /bin/bash             # Use bash shell
#$ -cwd                     # Run the job in the current directory
#$ -j y                     # Merge standard output and error
#$ -l mem_free=16G           # Request 16 GB of RAM per slot
#$ -l scratch=100G           # Request 100 GB of local scratch space
#$ -l h_rt=08:00:00          # Request 8 hours of runtime
#$ -pe smp 4                 # Request 4 CPU cores
#$ -r y                      # Restart job if it fails

# qsub -cwd -pe smp 4 -l mem_free=16G -l scratch=100G -l h_rt=04:00:00 workflow/scripts/submit_epiclocks.sh

conda activate r_dnam

python workflow/scripts/epi_clocks.py

# date
# hostname

## End-of-job summary, if running as a job
[[ -n "$JOB_ID" ]] && qstat -j "$JOB_ID"  # This is useful for debugging and usage purposes,
                                          # e.g. "did my job exceed its memory request?"
