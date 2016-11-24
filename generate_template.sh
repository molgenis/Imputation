#!/bin/bash

module load Molgenis-Compute/v16.08.1-Java-1.8.0_74
module list

PROJECT=PROJECTXX
RUNNUMBER=XX
WORKDIR=XX
WORKFLOW=${WORKDIR}/myfirst_workflow/workflow.csv

echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/

if [ -f ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/out.csv  ];
then
        rm -rf ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/out.csv
fi


perl /home/umcg-mbenjamins/Test/myfirst_workflow/convertParametersGitToMolgenis.pl /home/umcg-mbenjamins/Test/myfirst_workflow/parameters_liftOver.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/liftover.csv

perl /home/umcg-mbenjamins/Test/myfirst_workflow/convertParametersGitToMolgenis.pl /home/umcg-mbenjamins/Test/myfirst_workflow/parameters_phasing.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/phasing.csv



sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/liftover.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/phasing.csv \
-p ${WORKDIR}/Input/${PROJECT}.csv \
-p /home/umcg-mbenjamins/github/Imputation/chr.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/Projects/${PROJECT}/run_${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate


