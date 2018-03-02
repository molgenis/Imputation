#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string outputPerChunk
#string qctoolVersion
#string intermediateDir
#string chrom
#string fromChrPos
#string toChrPos

#Create tmp/tmp to save unfinished results
makeTmpDir "${outputPerChunk}"
tmpOutputPerChunk="${MC_tmpFile}"

#Load modules and list currently loaded modules
module load "${qctoolVersion}"
module list


#Measure SNP stats on imputed chunks. Only if any SNPs were found during imputation, otherwise exit
if [[ -f "${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}.gen" ]]
then
	$EBROOTQCTOOL/qctool -g "${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}.gen" -snp-stats "${tmpOutputPerChunk}_info"

        echo -e "\nmv ${tmpOutputPerChunk}_info ${intermediateDir}\n"
        mv "${tmpOutputPerChunk}_info" "${intermediateDir}"

        echo -e "qctool is finished, resulting _info file can be found here: ${intermediateDir}\n"
else
	echo -e "No SNPs were found during imputation, so no info field is created either.\n"
fi
