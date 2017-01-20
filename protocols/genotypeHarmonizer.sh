#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string genotypeHarmonizerVersion
#string outputPerChr
#string referenceGenome
#string tempDir
#string intermediateDir
#string chr
#string pathToReference1000G
#string pathToReferenceGoNL


#Load modules and list currently loaded modules
module load ${genotypeHarmonizerVersion}
ml

#Create tmp/tmp to save unifinished results
makeTmpDir ${outputPerChr}
tmpOutputPerChr=${MC_tmpFile}


#Align study data to reference data (1000G or GoNL)
#tempDir to store Java output
if [ "${referenceGenome}" == "1000G" ];
then
	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar ${EBROOTGENOTYPEHARMONIZER}/GenotypeHarmonizer.jar \
		--input ${intermediateDir}/chr${chr}.phased \
		--inputType SHAPEIT2 \
		--ref ${pathToReference1000G} \
		--refType VCF \
		--forceChr ${chr} \
		--output ${tmpOutputPerChr}.gh \
		--outputType SHAPEIT2

elif [ "${referenceGenome}" == "gonl" ];
then
	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar ${EBROOTGENOTYPEHARMONIZER}/GenotypeHarmonizer.jar
                --input ${intermediateDir}/chr${chr}.phased \
                --inputType SHAPEIT2 \
                --ref ${pathToReferenceGoNL} \
                --refType VCF \
                --forceChr ${chr} \
                --output ${intermediateDir}/${tmpOutputPerChr}.gh \
                --outputType SHAPEIT2

else
	echo "WARN: Unsupported reference genome!"
fi

echo "mv ${tmpOutputPerChr}.{gh.sample,gh.haps,gh.log,gh_snpLog.log} ${intermediateDir}"
mv ${tmpOutputPerChr}.{gh.sample,gh.haps,gh.log,gh_snpLog.log} ${intermediateDir}

echo "Alignment finished, new haps and sample files can be found here: ${intermediateDir}."
