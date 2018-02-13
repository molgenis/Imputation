#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string outputPerChunk
#string qctoolVersion
#string intermediateDir
#string chrom
#string fromChrPos
#string toChrPos

#Create tmp/tmp to save unfinished results
makeTmpDir ${outputPerChunk}
tmpOutputPerChunk=${MC_tmpFile}


module load ${qctoolVersion}
module list


if [[ -f "${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}.gen" ]]
then
	$EBROOTQCTOOL/qctool -g chr${chrom}_${fromChrPos}-${toChrPos}.gen -snp-stats ${tmpOutputPerChunk}_info

        echo -e "\nmv ${tmpOutputPerChunk}_info ${intermediateDir}\n"
        mv "${tmpOutputPerChunk}_info" "${intermediateDir}"

        echo -e "qctool is finished, resulting _info file can be found here: ${intermediateDir}\n"
else
	echo "No SNPs were found during imputation, so no info field is created either."
fi
