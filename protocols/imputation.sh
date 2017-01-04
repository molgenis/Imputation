#MOLGENIS walltime=05:59:59 mem=30gb ppn=21

#string geneticMapImputation
#string referenceGenome
#string pathToPhasedReference1000G
#string pathToPhasedReference1000G
#string chrom
#string fromChrPos
#string toChrPos
#string intermediateDir
#string imputeVersion

set -e
set -u

module load ${imputeVersion}

if [ "${referenceGenome}" == "1000G" ];
then
	if $EBROOTIMPUTE2/impute2 \
		-known_haps_g ${intermediateDir}/chr${chrom}.gh.haps \
		-m ${geneticMapImputation} \
		-h ${pathToPhasedReference1000G}/ALL_${referenceGenome}_phase1integrated_v3_chr${chrom}_impute.hap.gz \
		-l ${pathToPhasedReference1000G}/ALL_${referenceGenome}_phase1integrated_v3_chr${chrom}_impute.legend.gz \
		-int ${fromChrPos} ${toChrPos} \
		-o ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos} \
		-use_prephased_g
	then
		#If there are no SNPs in the imputation interval, empty files will created
                if [ ! -f ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info ];
                then
			echo "Impute2 did not output any files. Usually this means that there were no SNPs in this region. Generating empty files."
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info_by_sample
                fi

	#If there are no type 2 SNPs, empty files will be generated
        elif [[ $(grep "ERROR: There are no type 2 SNPs after applying the command-line settings for this run" ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_summary) ]];
        then
		echo "No type 2 SNPs were found. Generating empty files."
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info_by_sample
        fi

elif [ "${referenceGenome}" == "gonl" ];
then
	if $EBROOTIMPUTE2/impute2 \
		-known_haps_g ${intermediateDir}/chr${chrom}.gh.haps \
		-m ${geneticMapImputation} \
		-h ${pathToPhasedReferenceGoNL}/chr${chrom}.hap.gz \
		-l ${pathToPhasedReferenceGoNL}/chr${chrom}.legend.gz \
		-int ${fromChrPos} ${toChrPos} \
		-o ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos} \
		-use_prephased_g
	then
                #If there are no SNPs in the imputation interval, empty files will created
                if [ ! -f ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info ];
                then
                        echo "Impute2 did not output any files. Usually this means that there were no SNPs in this region. Generating empty files."
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info
                        touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info_by_sample
                fi

        #If there are no type 2 SNPs, empty files will be generated
        elif [[ $(grep "ERROR: There are no type 2 SNPs after applying the command-line settings for this run" ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_summary) ]];
        then
                echo "No type 2 SNPs were found. Generating empty files."
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info
                touch ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos}_info_by_sample
        fi

else
	echo "WARN: Unsupported phased reference genome!"
fi
