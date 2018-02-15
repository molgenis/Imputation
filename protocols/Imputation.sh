#MOLGENIS walltime=2-00:00:00 mem=20gb ppn=1

#string outputPerChunk
#string imputeVersion
#string referenceGenome
#string intermediateDir
#string chrom
#string pathToPhasedReference1000G
#string pathToPhasedReferenceGoNL
#string pathToPhasedReferenceHRC
#string geneticMapImputation
#string fromChrPos
#string toChrPos

#Create tmp/tmp to save unfinished results
makeTmpDir "${outputPerChunk}"
tmpOutputPerChunk="${MC_tmpFile}"


#Load modules and list currently loaded modules
module load "${imputeVersion}"
module list


#Reference genome should be one of the following: 1000G, GoNL or HRC, otherwise exit script
if [ "${referenceGenome}" == "1000G" ]
then
	pathToPhasedReference="${pathToPhasedReference1000G}"

elif  [ "${referenceGenome}" == "gonl" ]
then
	pathToPhasedReference="${pathToPhasedReferenceGoNL}"

elif [ "${referenceGenome}" == "HRC" ]
then
	pathToPhasedReference="${pathToPhasedReferenceHRC}/"*"_HRC.r1-1.EGA.GRCh37.chr${chrom}"

else
	echo "WARN: Unsupported phased reference genome!"
	exit 1
fi


#Perform imputation
if $EBROOTIMPUTE4/impute4 \
	-no_maf_align \
	-g "${intermediateDir}/chr${chrom}.gh.haps" \
	-m "${geneticMapImputation}" \
	-h "${pathToPhasedReference}.hap.gz" \
	-l "${pathToPhasedReference}.legend.gz" \
	-int "${fromChrPos}" "${toChrPos}" \
	-o "${tmpOutputPerChunk}"
then
	echo -e "\nmv ${tmpOutputPerChunk}.gen ${intermediateDir}\n"
	mv "${tmpOutputPerChunk}.gen" "${intermediateDir}"

        echo -e "Imputation is finished, resulting chunk and info files can be found here: ${intermediateDir}\n"
else
	echo -e "Impute4 did not output any files. Usually this means that there were no SNPs found in this region\n"
fi
