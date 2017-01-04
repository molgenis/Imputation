#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string chrom
#string intermediateDir
#list fromChrPos
#list toChrPos

set -e
set -u

count=0
declare -a impute2ChunksMerged
declare -a impute2ChunksInfoMerged

length=${#fromChrPos[@]}-1

#Fill array with chunks
#Info files have headers, remove headers and leave first one
for ((i=0;i<=length;i++));
do
	echo "Processing: chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}"
	impute2ChunksMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}

	if [ $i -eq 0 ];
	then
		impute2ChunksInfoMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info

	elif [ $i > 0 ];
	then
		impute2ChunksInfoMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info
	fi
done

#Delete concatenated chunks in case a job has to be restarted
rm -f ${intermediateDir}/chr${chrom}_concatenated
rm -f ${intermediateDir}/chr${chrom}_info_concatenated

#Concatenate chunks and info files
cat ${impute2ChunksMerged[@]} >> ${intermediateDir}/chr${chrom}_concatenated
cat ${impute2ChunksInfoMerged[@]} >> ${intermediateDir}/chr${chrom}_info_concatenated

echo "Chunk and info files are merged."
