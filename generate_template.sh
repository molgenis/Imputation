#!/bin/bash

module load Molgenis-Compute/v16.11.1-Java-1.8.0_74
module load Imputation/1.0.0
module list

PROJECT=XX
RUNID=XX

TMPDIRECTORY=$(basename $(cd ../../ && pwd ))
GROUP=$(basename $(cd ../../../ && pwd ))

HOMEDIR=/groups/${GROUP}/${TMPDIRECTORY}/
WORKDIR=${HOMEDIR}/generatedscripts/${PROJECT}/
INTERMEDIATEDIR=${HOMEDIR}/tmp/${PROJECT}/
RUNDIR=${HOMEDIR}/projects/${PROJECT}/run${RUNID}/jobs/


echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${INTERMEDIATEDIR}

if [ -f ${WORKDIR}/parameters_converted.csv  ];
then
        rm -rf ${WORKDIR}/parameters_converted.csv
fi


perl ${EBROOTIMPUTATION}/convertParametersGitToMolgenis.pl ${EBROOTIMPUTATION}/parameters.csv > \
${WORKDIR}/parameters_converted.csv


sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${WORKDIR}/parameters_converted.csv \
-p ${WORKDIR}/datasheet.csv \
-p ${EBROOTIMPUTATION}/chromosomes.csv \
-p ${EBROOTIMPUTATION}/chunks_b37.csv \
-w ${EBROOTIMPUTATION}/workflow.csv \
-rundir ${RUNDIR} \
-b slurm \
--weave \
--generate
