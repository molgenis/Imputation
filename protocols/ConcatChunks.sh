#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string intermediateDir
#string chrom
#list fromChrPos
#list toChrPos
#string concatChunksFile
#string concatChunksInfoFile

declare -a impute2ChunksMerged
declare -a impute2ChunksInfoMerged

length=${#fromChrPos[@]}-1


#Fill array with chunks. The chunks where no SNPs were found during imputation are not taken into account.
#Info files have headers, remove headers and leave first one
for ((i=0;i<=length;i++))
do
        chunk="${intermediateDir}/chr${chrom}_${fromChrPos[${i}]}-${toChrPos[${i}]}"

        if [[ -f "${chunk}.gen" ]]
        then
                impute2ChunksMerged[${i}]="${chunk}.gen"

                echo "Processing: ${chunk}.gen"

                if [ "${i}" -eq 0 ]
                then
                        impute2ChunksInfoMerged[${i}]="${chunk}_info"

                elif [ "${i}" > 0 ]
                then
                        sed '1d' "${chunk}_info" > tmpfile; mv tmpfile "${chunk}_info"
                        impute2ChunksInfoMerged[${i}]="${chunk}_info"
                fi
	else
		echo "${chunk}.gen not found, proceeding..."
                continue
        fi
done

#Concatenate chunks and info files
cat "${impute2ChunksMerged[@]}" > "${concatChunksFile}"
cat "${impute2ChunksInfoMerged[@]}" > "${concatChunksInfoFile}"

echo -e "\nConcatenating is finished, resulting merged chunk and info files can be found here: ${intermediateDir}\n"
