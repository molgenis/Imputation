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
	$EBROOTIMPUTE2/impute2 \
		-known_haps_g ${intermediateDir}/chr${chrom}.gh.haps \
		-m ${geneticMapImputation} \
		-h ${pathToPhasedReference1000G}/ALL_${referenceGenome}_phase1integrated_v3_chr${chrom}_impute.hap.gz \
		-l ${pathToPhasedReference1000G}/ALL_${referenceGenome}_phase1integrated_v3_chr${chrom}_impute.legend.gz \
		-int ${fromChrPos} ${toChrPos} \
		-o ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos} \
		-use_prephased_g

elif [ "${referenceGenome}" == "gonl" ];
then
	$EBROOTIMPUTE2/impute2 \
		-known_haps_g ${intermediateDir}/chr${chrom}.gh.haps \
		-m ${geneticMapImputation} \
		-h ${pathToPhasedReferenceGoNL}/chr${chrom}.hap.gz \
		-l ${pathToPhasedReferenceGoNL}/chr${chrom}.legend.gz \
		-int ${fromChrPos} ${toChrPos} \
		-o ${intermediateDir}/chr${chrom}_${fromChrPos}-${toChrPos} \
		-use_prephased_g

else
	echo "WARN: Unsupported phased reference genome!"
fi
