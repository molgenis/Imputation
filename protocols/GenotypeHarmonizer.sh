#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string genotypeHarmonizerVersion
#string outputPerChr
#string referenceGenome
#string tempDir
#string intermediateDir
#string chr
#string pathToReference1000G
#string pathToReferenceGoNL
#string pathToReferenceHRC

#Load modules and list currently loaded modules
module load ${genotypeHarmonizerVersion}
module list


#Create tmp/tmp to save unfinished results
makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}


#Reference genome should be one of the following: 1000G or GoNL, otherwise exit script
if [ "${referenceGenome}" == "1000G" ]
then
	pathToReference=${pathToReference1000G}

elif [ "${referenceGenome}" == "gonl" ]
then
	pathToReference=${pathToReferenceGoNL}

elif [ "${referenceGenome}" == "HRC" ]
then
        pathToReference=${pathToReferenceHRC}

else
	echo "Unsupported reference genome!"
	exit 1
fi


#Align study data to reference data (1000G or GoNL)
#tempDir to store Java output
java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar ${EBROOTGENOTYPEHARMONIZER}/GenotypeHarmonizer.jar \
	--input ${intermediateDir}/chr${chr}.phased \
	--inputType SHAPEIT2 \
	--ref ${pathToReference} \
	--refType VCF \
	--forceChr ${chr} \
	--output ${tmpOutputPerChr}.gh \
	--outputType SHAPEIT2


echo -e "\nmv ${tmpOutputPerChr}.{gh.sample,gh.haps,gh.log,gh_snpLog.log} ${intermediateDir}\n"
mv "${tmpOutputPerChr}".{gh.sample,gh.haps,gh.log,gh_snpLog.log} "${intermediateDir}"

echo -e "Alignment is finished, resulting new haps and sample files can be found here: ${intermediateDir}\n"
