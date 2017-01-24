#MOLGENIS walltime=23:59:59 mem=30gb ppn=21

#string outputPerChr
#string shapeItVersion
#string intermediateDir
#string chr
#string geneticMapPhasing


#Create tmp/tmp to save unfinished results
makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}


#load modules and list currently loaded modules
module load ${shapeItVersion}
ml


#Phasing study data
shapeit -P ${intermediateDir}/chr${chr} \
        -M ${geneticMapPhasing} \
        -O ${tmpOutputPerChr}.phased \
	--output-log ${tmpOutputPerChr}.phasing.log \
	--thread 20

echo "mv ${tmpOutputPerChr}.{phased.sample,phased.haps,phasing.log,phasing.snp.mm,phasing.ind.mm} ${intermediateDir}"
mv ${tmpOutputPerChr}.{phased.sample,phased.haps,phasing.log,phasing.snp.mm,phasing.ind.mm} ${intermediateDir}

echo -e "\nPhasing is finished, haps and sample files can be found here: ${intermediateDir}."

