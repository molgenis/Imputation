#MOLGENIS walltime=05:59:59 mem=4gb ppn=1

#string githubdir
#string projectResultsDir
#string intermediateDir
#list chr
#list chrom
#list fromChrPos
#list toChrPos

# Make result directories
mkdir -p ${projectResultsDir}/liftOver/
mkdir -p ${projectResultsDir}/phasing
mkdir -p ${projectResultsDir}/genotypeHarmonizer/
mkdir -p ${projectResultsDir}/imputation_chunks/
mkdir -p ${projectResultsDir}/imputation/
mkdir -p ${projectResultsDir}/logs/

# Copy liftover files to project results directory
for i in ${chr[@]};
do
	echo "chr is : ${i}"
	echo "Copied project liftover files to project results directory.."
	rsync -a ${intermediateDir}/chr${i}.map ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.new.bed ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.new.Mappings.txt ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.new.unmappedSnps.txt ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.new.unmapped.txt ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.ped ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.ucsc.bed ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.unordered.map ${projectResultsDir}/liftOver/
	rsync -a ${intermediateDir}/chr${i}.unordered.ped ${projectResultsDir}/liftOver/
done

echo ".. finished (1/8)\n"

# Copy phasing files to project results directory
for i in ${chr[@]};
do
	echo "chr is : ${i}"
	echo "Copied project phasing files to project results directory.."
	rsync -a ${intermediateDir}/chr${i}.phased.haps ${projectResultsDir}/phasing/
	rsync -a ${intermediateDir}/chr${i}.phased.sample ${projectResultsDir}/phasing/
done

echo ".. finished (2/8)\n"

# Copy genotypeHarmonizer files to project results directory
for i in ${chr[@]};
do
	echo "chr is : ${i}"
	echo "Copied genotypeHarmonizer files to project results directory .."
	rsync -a ${intermediateDir}/chr${i}.gh.sample ${projectResultsDir}/genotypeHarmonizer/
	rsync -a ${intermediateDir}/chr${i}.gh.haps ${projectResultsDir}/genotypeHarmonizer/

done
echo  ".. finished (3/8)\n"

#Copy imputation_chunck files to project results directory
#Nog nadenken over info en sample files...

awk '{if (NR!=1){print "chr"$1"_"$2"-"$3}}' ${githubdir}/chunks_b37.csv > ${intermediateDir}/chunks.txt

for i in $(cat ${intermediateDir}/chunks.txt);
do
	echo ${i}
	rsync -a ${intermediateDir}/${i} ${projectResultsDir}/imputation_chunks/
done

echo ".. finished (4/8)\n"

exit 1

#Copy imputation files to project results directory
for i in ${chr[@]};
do
	echo "chr is : ${i}"
	echo "Copied imputation results to results directory .."
	rsync -a ${intermediateDir}/chr${i}_concatenated ${projectResultsDir}/imputation/
	rsync -a ${intermediateDir}/chr${i}_info_concatenated ${projectResultsDir}/imputation/
done


echo ".. finished (5/8)\n"

#Copy logfiles to the project log results directory
for i in ${chr[@]};
do
	echo "chr is : ${i}"
	echo "Copied all log files to results directory .."
	rsync -a ${intermediateDir}/chr${i}.gh.log ${projectResultsDir}/logs
	rsync -a ${intermediateDir}/chr${i}.gh_snpLog.log ${projectResultsDir}/logs
	rsync -a ${intermediateDir}/phasing_chr${i}.log ${projectResultsDir}/logs
done

for i in $(cat ${intermediateDir}/chunks.txt);
do
	echo ${i}
	rsync -a ${i}_info ${projectResultsDir}/logs
	rsync -a ${i}_info_by_sample ${projectResultsDir}/logs
	rsync -a ${i}_summary ${projectResultsDir}/logs
done
echo ".. finished (6/8)\n"

# Create tar.gz per chromosome
echo "Creating tar.gz file per chromosome"
for i in ${chr[@]};
do
	echo "CURRENT_DIR=`pwd`"
	tar -cvzf ${projectResultsDir}/chr${i} ${intermediateDir}/chr${i}.haps ${intermediateDir}/chr${i}.sample ${intermediateDir}/chr${i} ${intermediateDir}/chr${i}_info
done

echo " Tar.gz file created: ${projectResultsDir}/${chr}.tar.gz (7/8)"

# Create md5sum for all tar.gz files
for i in ${chr[@]};
do
	md5sum ${projectResultsDir}/${i}.tar.gz > ${projectResultsDir}/${i}.tar.gz.md5
done

echo "Made md5 files for tar.gz files per chromosome (8/8)"

echo "pipeline is finished"

touch ${studyData}.pipeline.finished

echo "${studyData}.pipeline.finished is created"

