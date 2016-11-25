#MOLGENIS walltime=05:59:59 mem=30gb ppn=21
#string chr
#string shapeItVersion
#string geneticMap
#string studyData
#string intermediateDir

set -e
set -u


#load modules

module load ${shapeItVersion}

###Phasing the study data

shapeit -P ${intermediateDir}/chr${chr} \
        -M ${geneticMap} \
        -O ${intermediateDir}/chr${chr}.phased \
	--output-log ${intermediateDir}/phasing_chr${chr}.log \
	--thread 20
