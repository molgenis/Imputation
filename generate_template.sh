#!/bin/bash

module load Molgenis-Compute/v16.08.1-Java-1.8.0_74
module list

#TODO change GITHUBDIR in EBROOTMOLGENISMINIMPUTATION
PROJECT=XX
RUNID=XX
WORKDIR=/groups/umcg-gaf/tmp04/generatedscripts/${PROJECT}/
GITHUBDIR=/home/umcg-mbijlsma/github/Imputation/
INTERMEDIATEDIR=/groups/umcg-gaf/tmp04/tmp/${PROJECT}/
RUNDIR=${WORKDIR}/projects/${PROJECT}/run${RUNID}/jobs/


echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p  ${INTERMEDIATEDIR}

if [ -f ${WORKDIR}/parameters_converted.csv  ];
then
        rm -rf ${WORKDIR}/parameters_converted.csv
fi


perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${WORKDIR}/parameters_converted.csv


sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/parameters_converted.csv \
-p ${WORKDIR}/datasheet.csv \
-p ${GITHUBDIR}/chromosomes.csv \
-p ${GITHUBDIR}/chunks_b37.csv \
-w ${GITHUBDIR}/workflow.csv \
-rundir ${RUNDIR} \
-b slurm \
--weave \
--generate


