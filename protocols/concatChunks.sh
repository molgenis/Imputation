#MOLGENIS walltime=05:59:59 mem=30gb ppn=1

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

#Concat all chunks
#Info files have headers, remove headers and leave first one
for ((i=0;i<=length;i++));
do
	impute2ChunksMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]} 

	if [ $i -eq 0 ];
	then
		impute2ChunksInfoMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info

	elif [ $i > 0 ];
	then
		echo "sed '1d' ${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info > tmpfile; mv tmpfile ${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info"
		impute2ChunksInfoMerged[${i}]=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}_info
	fi
done

#echo -e "Concatenate files: \ncat ${impute2ChunksMerged[@]} >> ${intermediateDir}/chr${chrom}_concatenated"
cat ${impute2ChunksMerged[@]} >> ${intermediateDir}/chr${chrom}_concatenated
#echo -e "\nConcatenate info files: \ncat ${impute2ChunksInfoMerged[@]} >> ${intermediateDir}/chr${chrom}_info_concatenated"
cat ${impute2ChunksMerged[@]} >> ${intermediateDir}/chr${chrom}_concatenated
