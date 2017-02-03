#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string intermediateDir
#string chrom
#list fromChrPos
#list toChrPos
#string concatChunksFile
#string concatChunksInfoFile

declare -a impute2ChunksMerged
declare -a impute2ChunksInfoMerged

length=${#fromChrPos[@]}-1


#Fill array with chunks
#Info files have headers, remove headers and leave first one
for ((i=0;i<=length;i++))
do

        chunk=${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}
        impute2ChunksMerged[${i}]=${chunk}

	echo "Processing: ${chunk}"

	if [ "${i}" -eq 0 ]
	then
		impute2ChunksInfoMerged[${i}]=${chunk}_info

	elif [ "${i}" > 0 ]
	then
		sed '1d' ${chunk}_info > tmpfile; mv tmpfile ${chunk}_info
		impute2ChunksInfoMerged[${i}]=${chunk}_info
	fi
done


#Concatenate chunks and info files
cat "${impute2ChunksMerged[@]}" > "${concatChunksFile}"
cat "${impute2ChunksInfoMerged[@]}" > "${concatChunksInfoFile}"

echo -e "\nConcatenating is finished, resulting merged chunk and info files can be found here: ${intermediateDir}\n"
