#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string githubDir
#string projectResultsDir
#string intermediateDir
#list chr
#list chrom
#list fromChrPos
#list toChrPos
#string studyData

set -e
set -u

#Create result directories
mkdir -p ${projectResultsDir}/liftOver/
mkdir -p ${projectResultsDir}/phasing
mkdir -p ${projectResultsDir}/genotypeHarmonizer/
mkdir -p ${projectResultsDir}/imputation_chunks/
mkdir -p ${projectResultsDir}/imputation/
mkdir -p ${projectResultsDir}/logs/
mkdir -p ${projectResultsDir}/finalResults/

#Copy liftover files to results directory
#If genome builds are the same, only ped and map files are created.
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy liftover files to results directory.."

	if [[ $(grep "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}" s01_liftOver_*.out) ]];
	then
		rsync -a ${intermediateDir}/chr${i}.ped ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.map ${projectResultsDir}/liftOver/
	else
		rsync -a ${intermediateDir}/chr${i}.bed ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.bim ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.fam ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.map ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.new.bed ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.new.Mappings.txt ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.new.unmappedSnps.txt ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.new.unmapped.txt ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.ped ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.ucsc.bed ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.unordered.map ${projectResultsDir}/liftOver/
		rsync -a ${intermediateDir}/chr${i}.unordered.ped ${projectResultsDir}/liftOver/
	fi
done

echo -e ".. finished (1/8)\n"

#Copy phasing files to results directory
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy phasing files to results directory.."
	rsync -a ${intermediateDir}/chr${i}.phased.haps ${projectResultsDir}/phasing/
	rsync -a ${intermediateDir}/chr${i}.phased.sample ${projectResultsDir}/phasing/
done

echo -e ".. finished (2/8)\n"

#Copy genotypeHarmonizer files to results directory
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy genotypeHarmonizer files to results directory.."
	rsync -a ${intermediateDir}/chr${i}.gh.sample ${projectResultsDir}/genotypeHarmonizer/
	rsync -a ${intermediateDir}/chr${i}.gh.haps ${projectResultsDir}/genotypeHarmonizer/

done
echo  -e ".. finished (3/8)\n"

#Copy imputation_chunck files to results directory
#Create new file with chunks, based on parameter file with chunk notation: chr_pos-pos
awk '{if (NR!=1){print "chr"$1"_"$2"-"$3}}' FS="," ${githubDir}/chunks_b37.csv > ${intermediateDir}/chunks.txt

echo "Copy chunk files to results directory.."

for i in $(cat ${intermediateDir}/chunks.txt);
do
	rsync -a ${intermediateDir}/${i} ${projectResultsDir}/imputation_chunks/
done

echo -e ".. finished (4/8)\n"

#Copy imputation files to results directory
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy imputation files to results directory.."
	rsync -a ${intermediateDir}/chr${i}_concatenated ${projectResultsDir}/imputation/
	rsync -a ${intermediateDir}/chr${i}_info_concatenated ${projectResultsDir}/imputation/
done

echo -e ".. finished (5/8)\n"

#Copy logfiles to results directory
#If genome builds are the same, only one log file is created.
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy log files from each step to results directory.."

	if [[ $(grep "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}" s01_liftOver_*.out) ]];
        then
		rsync -a ${intermediateDir}/chr${i}.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.gh.log ${projectResultsDir}/logs
                rsync -a ${intermediateDir}/chr${i}.gh_snpLog.log ${projectResultsDir}/logs
                rsync -a ${intermediateDir}/chr${i}.phasing.log ${projectResultsDir}/logs
                rsync -a ${intermediateDir}/chr${i}.phasing.snp.mm ${projectResultsDir}/logs
                rsync -a ${intermediateDir}/chr${i}.phasing.ind.mm ${projectResultsDir}/logs
        else
		rsync -a ${intermediateDir}/chr${i}.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.unordered.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.gh.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.gh_snpLog.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.phasing.log ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.phasing.snp.mm ${projectResultsDir}/logs
		rsync -a ${intermediateDir}/chr${i}.phasing.ind.mm ${projectResultsDir}/logs
	fi
done

for i in $(cat ${intermediateDir}/chunks.txt);
do
	rsync -a ${intermediateDir}/${i}_info ${projectResultsDir}/logs
	rsync -a ${intermediateDir}/${i}_info_by_sample ${projectResultsDir}/logs
	rsync -a ${intermediateDir}/${i}_summary ${projectResultsDir}/logs
	rsync -a ${intermediateDir}/${i}_warnings ${projectResultsDir}/logs
done
echo -e ".. finished (6/8)\n"

#Create tar.gz per chromosome
echo "chr${chr}"
echo "Creating tar.gz file per chromosome in results directory.."

for i in ${chr[@]};
do
	tar -cvzf ${projectResultsDir}/finalResults/chr${i}.tar.gz ${intermediateDir}/chr${i}.phased.haps ${intermediateDir}/chr${i}.phased.sample ${intermediateDir}/chr${i}_concatenated ${intermediateDir}/chr${i}_info_concatenated
done

echo "Tar.gz file created: ${projectResultsDir}/chr${chr}.tar.gz"
echo -e ".. finished (7/8)\n"

#Create md5sum for tar.gz file per chromosome
echo "chr${chr}"
echo "Creating md5sums for tar.gz files in results directory.."

for i in ${chr[@]};
do
	md5sum ${projectResultsDir}/finalResults/chr${i}.tar.gz > ${projectResultsDir}/finalResults/chr${i}.tar.gz.md5
done

echo "md5sums created: ${projectResultsDir}/chr${chr}.tar.gz.md5"
echo -e ".. finished (8/8)\n"

echo "Checking if resultsdir and intermediatedir have the same amount of files.."

countIntermediateDir=$(ls ${intermediateDir}/* | wc -l)
countResultsDir=$(($(ls ${projectResultsDir}/liftOver/* | wc -l) + $(ls ${projectResultsDir}/phasing/* | wc -l) + $(ls ${projectResultsDir}/genotypeHarmonizer/* | wc -l) + $(ls ${projectResultsDir}/imputation_chunks/* | wc -l) + $(ls ${projectResultsDir}/imputation/* | wc -l) + $(ls ${projectResultsDir}/logs/* | wc -l)))

if [ ${countIntermediateDir} == ${countResultsDir}} ];
then
	echo "Amount of files is te same.."

	#Remove intermediateDir
	if [ -d ${intermediateDir:-} ]; then
		echo -n "INFO: Removing intermediateDir ${intermediateDir} ..."
		rm -rf ${intermediateDir}
		echo 'done.'

		echo "pipeline is finished"
		touch ${studyData}.pipeline.finished
		echo "${studyData}.pipeline.finished is created"
	fi
else
	echo -e "The amount of files is not the same:\nintermediateDir: ${countIntermediateDir}\nresultsDir: ${countResultsDir}"
fi


