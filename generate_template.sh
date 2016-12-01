#!/bin/bash

module load Molgenis-Compute/v16.08.1-Java-1.8.0_74
module list

PROJECT=XX
RUNNUMBER=XX
WORKDIR=/home/umcg-mbijlsma/test/
GITHUBDIR=/home/umcg-mbijlsma/github/Imputation/
WORKFLOW=${GITHUBDIR}/workflow.csv

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


perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/parameters_converted.csv


sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/parameters_converted.csv \
-p ${GITHUBDIR}/datasheet.csv \
-p ${GITHUBDIR}/chromosomes.csv \
-p ${GITHUBDIR}/chunks_b37.csv \
-w ${WORKFLOW} \
-header ${GITHUBDIR}/templates/slurm/header.ftl \
-rundir ${WORKDIR}/Projects/${PROJECT}/run_${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate


