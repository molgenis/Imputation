#MOLGENIS walltime=05:59:59 mem=30gb ppn=21
#string chr
#string shapeItVersion
#string geneticMapPhasing
#string studyData
#string intermediateDir
#string outputPerChr

set -e
set -u

makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}

#load modules
module load ${shapeItVersion}
ml

#Phasing the study data
shapeit -P ${intermediateDir}/chr${chr} \
        -M ${geneticMapPhasing} \
        -O ${tmpOutputPerChr}.phased \
	--output-log ${tmpOutputPerChr}.phasing.log \
	--thread 20

echo "mv ${tmpOutputPerChr}.{phased.sample,phased.haps,phasing.log,phasing.snp.mm,phasing.ind.mm} ${intermediateDir}"
mv ${tmpOutputPerChr}.{phased.sample,phased.haps,phasing.log,phasing.snp.mm,phasing.ind.mm} ${intermediateDir}

echo -e "\nPhasing is finished."

