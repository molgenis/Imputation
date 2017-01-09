#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string chr
#string intermediateDir
#string referenceGenome
#string pathToReference1000G
#string pathToReferenceGoNL
#string genotypeHarmonizerVersion
#string tempDir

set -e
set -u

#Load modules
module load ${genotypeHarmonizerVersion}
ml

if [ "${referenceGenome}" == "1000G" ];
then
	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar ${EBROOTGENOTYPEHARMONIZER}/GenotypeHarmonizer.jar \
		--input ${intermediateDir}/chr${chr}.phased \
		--inputType SHAPEIT2 \
		--ref ${pathToReference1000G} \
		--refType VCF \
		--forceChr ${chr} \
		--output ${intermediateDir}/chr${chr}.gh \
		--outputType SHAPEIT2

elif [ "${referenceGenome}" == "gonl" ];
then
	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar ${EBROOTGENOTYPEHARMONIZER}/GenotypeHarmonizer.jar
                --input ${intermediateDir}/chr${chr}.phased \
                --inputType SHAPEIT2 \
                --ref ${pathToReferenceGoNL} \
                --refType VCF \
                --forceChr ${chr} \
                --output ${intermediateDir}/chr${chr}.gh \
                --outputType SHAPEIT2

else
	echo "WARN: Unsupported reference genome!"
fi
