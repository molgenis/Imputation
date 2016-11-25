#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string chr
#string liftOverChainFile
#string intermediateDir
#string outputPerChr
#string liftOverInputFile
#string liftOverUcscVersion
#string plinkVersion


##TODO: Check if bed file is delivered per chromosome, if not, split bed file in 22 separate bed files.

makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}


#Load modules and list currently loaded modules
module load ${liftOverUcscVersion}
module load ${plinkVersion}
ml


#mkdir -p: Create output folder + parent directories if necessary.
#When -p option is used, no error is reported if a specified directory already exists.
mkdir -p  ${intermediateDir}


#Creating ped and map files from (plink) bed file
plink \
        --noweb \
        --bfile ${liftOverInputFile} \
        --recode \
        --out ${tmpOutputPerChr}

echo -e "mv ${tmpOutputPerChr}.{ped,map} ${intermediateDir}"
mv ${tmpOutputPerChr}.{ped,map} ${intermediateDir}


#Create new bed file (ucsc) from map file with different order of columns
awk '{$5=$2;$2=$4;$3=$4+1;$1="chr"$1;print $1,$2,$3,$5}' OFS="\t" ${intermediateDir}/chr${chr}.map > ${intermediateDir}/chr${chr}.ucsc.bed


#Map to b37 (get chainfile from samplesheet)
#-bedPlus=N: File is bed N+ format (in this case only 4 columns are needed)
#NOTE: ucsc bed format is different from plink bed format!
liftOver \
	-bedPlus=4 ${intermediateDir}/chr${chr}.ucsc.bed \
	${liftOverChainFile} \
	${tmpOutputPerChr}.new.bed \
	${tmpOutputPerChr}.new.unmapped.txt


echo -e "mv ${tmpOutputPerChr}.new.{bed,unmapped.txt} ${intermediateDir}"
mv ${tmpOutputPerChr}.new.{bed,unmapped.txt} ${intermediateDir}


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


echo -e "mv ${tmpOutputPerChr}.{unordered.ped,unordered.map,new.Mappings.txt} ${intermediateDir}"
mv ${tmpOutputPerChr}.{unordered.ped,unordered.map,new.Mappings.txt} ${intermediateDir}


#get return code from last program call
returnCode=$?


#Reorder of snps in case liftOver step  produces unordered positions
echo -e "returnCode Plink: ${returnCode}\n"

if [ ${returnCode} -eq 0 ]
then
	plink \
		--noweb \
		--file ${intermediateDir}/chr${chr}.unordered  \
		--recode \
		--make-bed \
		--out ${tmpOutputPerChr}
fi

echo -e "mv ${tmpOutputPerChr}.{bed,bim,fam,ped,map} ${intermediateDir}"
mv ${tmpOutputPerChr}.{bed,bim,fam,ped,map} ${intermediateDir}


#If everything went right, the ped and map files needed for the phasing step will be moved to the output folder
if [ ${returnCode} -eq 0 ]
then
	echo -e "Finishing liftOver step, resulting ped and map files can be found here: ${intermediateDir}"
fi
