#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string outputPerChr
#string liftOverUcscVersion
#string plinkVersion
#string intermediateDir
#string genomeBuild
#string liftOverInputFile
#string chr
#string liftOverChainFileDir


#Create tmp/tmp to save unfinished results
makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}


#Load modules and list currently loaded modules
module load ${liftOverUcscVersion}
module load ${plinkVersion}
module list


#If genome build is not one of the following, exit script
if ! [[ "${genomeBuild}" == "hg19" ]] &&
   ! [[ "${genomeBuild}" == "GRCh37" ]] &&
   ! [[ "${genomeBuild}" == "hg18" ]] &&
   ! [[ "${genomeBuild}" == "GRCh36" ]] &&
   ! [[ "${genomeBuild}" == "hg38" ]] &&
   ! [[ "${genomeBuild}" == "GRCh38" ]]
then
	echo "Unsupported genome build: ${genomeBuild}"
	exit 1
fi


#Creating ped and map files from (plink) bed file
plink \
	--noweb \
	--bfile ${liftOverInputFile} \
	--recode \
	--out ${tmpOutputPerChr}

echo -e "\nmv ${tmpOutputPerChr}.{ped,map} ${intermediateDir}"
mv "${tmpOutputPerChr}".{ped,map,log} "${intermediateDir}"


#If genome build of study data is the same as the genome build of the reference data, the script stops here.
#All data with other genome builds will continue with the liftover step.
if ! [[ "${genomeBuild}" == "hg19" ]] && ! [[ "${genomeBuild}" == "GRCh37" ]]
then

	if [[ "${genomeBuild}" == "hg18" ]] || [[ "${genomeBuild}" == "GRCh36" ]]
	then
		chainFile="hg18ToHg19.over.chain"
		echo "ChainFile used: ${chainFile}"

	elif [[ "${genomeBuild}" == "hg38" ]] || [[ "${genomeBuild}" == "GRCh38" ]]
	then
		chainFile="hg38ToHg19.over.chain"
		echo "ChainFile used: ${chainFile}"
	else
		echo "Something went wrong..."
		exit 1
	fi

	#Create new bed file (ucsc) from map file with different order of columns
	awk '{$5=$2;$2=$4;$3=$4+1;$1="chr"$1;print $1,$2,$3,$5}' OFS="\t" ${intermediateDir}/chr${chr}.map > ${intermediateDir}/chr${chr}.ucsc.bed


	#-bedPlus=N: File is bed N+ format (in this case only 4 columns are needed)
	#NOTE: ucsc bed format is different from plink bed format!
	liftOver \
		-bedPlus=4 ${intermediateDir}/chr${chr}.ucsc.bed \
		${liftOverChainFileDir}/${chainFile} \
		${tmpOutputPerChr}.new.bed \
		${tmpOutputPerChr}.new.unmapped.txt


	echo -e "mv ${tmpOutputPerChr}.new.{bed,unmapped.txt} ${intermediateDir}\n"
	mv "${tmpOutputPerChr}".new.{bed,unmapped.txt} "${intermediateDir}"


	#Create list of unmapped snps (delete rows with hash and get column 4 which contains the snps)
	awk '/^[^#]/ {print $4}' ${intermediateDir}/chr${chr}.new.unmapped.txt > ${intermediateDir}/chr${chr}.new.unmappedSnps.txt


	#Create mappings file used by plink (get columns 4 and 2, snps and positions)
	#NOTE: put new.Mappings.txt first to tmpPerChr, because it is later used for --update-map and will be written to intermediateDir afterwards
	awk '{print $4, $2}' OFS="\t" ${intermediateDir}/chr${chr}.new.bed > ${tmpOutputPerChr}.new.Mappings.txt


	#Create new plink data without the unmapped snps
	plink \
		--noweb \
		--file ${intermediateDir}/chr${chr} \
		--recode \
		--out ${tmpOutputPerChr}.unordered \
		--exclude ${intermediateDir}/chr${chr}.new.unmappedSnps.txt \
		--update-map ${tmpOutputPerChr}.new.Mappings.txt


	echo -e "mv ${tmpOutputPerChr}.{unordered.ped,unordered.map,new.Mappings.txt} ${intermediateDir}\n"
	mv "${tmpOutputPerChr}".{unordered.ped,unordered.map,unordered.log,new.Mappings.txt} "${intermediateDir}"


	#Reorder of snps in case liftOver step produces unordered positions
	plink \
		--noweb \
		--file ${intermediateDir}/chr${chr}.unordered  \
		--recode \
		--make-bed \
		--out ${tmpOutputPerChr}

	echo -e "mv ${tmpOutputPerChr}.{bed,bim,fam,ped,map} ${intermediateDir}\n"
	mv "${tmpOutputPerChr}".{bed,bim,fam,ped,map,log} "${intermediateDir}"

	echo -e "LiftOver is finished, resulting ped and map files can be found here: ${intermediateDir}\n"

else
	echo -e "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}\n"
fi
