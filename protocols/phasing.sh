#MOLGENIS walltime=64:00:00 mem=2gb
#string chr
#string shapeIt
#string shapeItVersion
#string geneticMap
#string studyData
#string intermediateDir
#string liftOverOutputDir
#string phasingOutputDir


set -e
set -u

#Checking if Phasing directory is Present or not
if [ -d ${phasingOutputDir}}/ ]
then
	rm -rf ${phasingOutputDir}
	mkdir -p ${phasingOutputDir}
else
	mkdir -p ${phasingOutputDir}/
fi

#load modules

module load ${shapeIt}/${shapeItVersion}

###Phasing the study data

shapeit -P ${liftOverOutputDir}/chr${chr} \
        -M ${geneticMap} \
        -O ${phasingOutputDir}/chr${chr}_gwas.phased \
	--output-log ${intermediateDir}/phasing_chr${chr}.log \
	--thread 4
