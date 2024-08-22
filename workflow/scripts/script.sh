#!/bin/bash           # the shell language when run outside of the job scheduler
#                     # lines starting with #$ is an instruction to the job scheduler
#$ -S /bin/bash       # the shell language when run via the job scheduler [IMPORTANT]
#$ -cwd               # job should run in the current working directory
#$ -j y               # STDERR and STDOUT should be joined
#$ -l mem_free=1G     # job requires up to 1 GiB of RAM per slot
#$ -l scratch=2G      # job requires up to 2 GiB of local /scratch space
#$ -l h_rt=00:30:00   # job requires up to 24 hours of runtime
##$ -t 1-10           # array job with 10 tasks (remove first '#' to enable)
#$ -r y               # if job crashes, it should be restarted

# qsub -cwd -pe smp 4 -l mem_free=16G -l scratch=1G -l h_rt=04:00:00 workflow/scripts/script.sh

conda activate r_dnam

# Rscript workflow/scripts/targets.R
# Rscript workflow/scripts/create_RGset.R
# Rscript workflow/scripts/normalized_betas.R
Rscript workflow/scripts/probe_qc.R
Rscript workflow/scripts/sample_qc.R
Rscript workflow/scripts/genomic_ranges.R
Rscript workflow/scripts/summarized_experiment.R

mv script* logs

# date
# hostname

## End-of-job summary, if running as a job
[[ -n "$JOB_ID" ]] && qstat -j "$JOB_ID"  # This is useful for debugging and usage purposes,
                                          # e.g. "did my job exceed its memory request?"
