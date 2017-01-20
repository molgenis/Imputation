#!/bin/bash

module load Molgenis-Compute/v16.08.1-Java-1.8.0_74
module list

PROJECT=XX
RUNID=XX
WORKDIR=/home/umcg-mbijlsma/test/
GITHUBDIR=/home/umcg-mbijlsma/github/Imputation/
WORKFLOW=${GITHUBDIR}/workflow.csv

echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p  /groups/umcg-gaf/tmp04//projects/tmp/${PROJECT}
mkdir -p ${WORKDIR}/generatedscripts/

if [ -f ${WORKDIR}/generatedscripts/converted_parameters.csv  ];
then
        rm -rf ${WORKDIR}/generatedscripts/converted_parameters.csv
fi


perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${WORKDIR}/generatedscripts/parameters_converted.csv


sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/parameters_converted.csv \
-p ${WORKDIR}/datasheet.csv \
-p ${GITHUBDIR}/chromosomes.csv \
-p ${GITHUBDIR}/chunks_b37.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/Projects/${PROJECT}/run_${RUNID}/jobs \
-b slurm \
-weave \
--generate


