#MOLGENIS walltime=05:59:59 mem=30gb ppn=1

#string outputPerChunk
#string imputeVersion
#string referenceGenome
#string intermediateDir
#string chrom
#string geneticMapImputation
#string pathToPhasedReference1000G
#string fromChrPos
#string toChrPos
#string pathToPhasedReferenceGoNL


#Create tmp/tmp to save unfinished results
makeTmpDir ${outputPerChunk}
tmpOutputPerChunk=${MC_tmpFile}


#Load modules and list currently loaded modules
module load ${imputeVersion}
module list


#Reference genome should be one of the following: 1000G or GoNL, otherwise exit script
if [ "${referenceGenome}" == "1000G" ]
then
	pathToPhasedReference=${pathToPhasedReference1000G}

elif  [ "${referenceGenome}" == "gonl" ]
then
	pathToPhasedReference=${pathToPhasedReferenceGoNL}

elif [ "${referenceGenome}" == "HRC" ]
then
	pathToPhasedReference=${pathToPhasedReferenceHRC}/*_HRC.r1-1.EGA.GRCh37.chr${chrom}

else
	echo "WARN: Unsupported phased reference genome!"
	exit 1
fi


#Perform imputation
if $EBROOTIMPUTE2/impute2 \
	-known_haps_g ${intermediateDir}/chr${chrom}.gh.haps \
	-m ${geneticMapImputation} \
	-h ${pathToPhasedReference}.hap.gz \
	-l ${pathToPhasedReference}.legend.gz \
	-int ${fromChrPos} ${toChrPos} \
	-o ${tmpOutputPerChunk} \
	-use_prephased_g
then
	#If there are no SNPs in the imputation interval, empty files will created
        if [ ! -f ${tmpOutputPerChunk}_info ]
        then
		echo "Impute2 did not output any files. Usually this means that there were no SNPs in this region. Generating empty files."
                touch ${tmpOutputPerChunk}
                touch ${tmpOutputPerChunk}_info
                touch ${tmpOutputPerChunk}_info_by_sample
        fi

#If there are no type 2 SNPs, empty files will be generated
elif [[ $(grep "ERROR: There are no type 2 SNPs after applying the command-line settings for this run" ${tmpOutputPerChunk}_summary) ]]
then
	echo "No type 2 SNPs were found. Generating empty files."
        touch ${tmpOutputPerChunk}
        touch ${tmpOutputPerChunk}_info
        touch ${tmpOutputPerChunk}_info_by_sample
else
	echo "Imputation cannot be performed..."
	exit 1
fi

echo -e "\nmv ${tmpOutputPerChunk}* ${intermediateDir}\n"
mv "${tmpOutputPerChunk}"* "${intermediateDir}"

echo "Imputation is finished, resulting chunk and info files can be found here: ${intermediateDir}\n"
