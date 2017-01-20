#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string liftOverResultsDir
#string logsResultsDir
#string finalResultsDir
#list chr
#string intermediateDir
#string githubDir
#string studyData


#Create result directories
mkdir -p ${liftOverResultsDir}
mkdir -p ${logsResultsDir}
mkdir -p ${finalResultsDir}


#Copy liftover files to results directory
#If genome builds are the same, only ped and map files are created and copied.
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy liftover files to results directory.."

	if [[ $(grep "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}" s01_liftOver_*.out) ]];
	then
		rsync -a ${intermediateDir}/chr${i}.ped ${liftOverResultsDir}
		rsync -a ${intermediateDir}/chr${i}.map ${liftOverResultsDir}
	else
		rsync -a ${intermediateDir}/chr${i}.bed ${liftOverResultsDir}
		rsync -a ${intermediateDir}/chr${i}.bim ${liftOverResultsDir}
		rsync -a ${intermediateDir}/chr${i}.fam ${liftOverResultsDir}
		rsync -a ${intermediateDir}/chr${i}.map ${liftOverResultsDir}
		rsync -a ${intermediateDir}/chr${i}.ped ${liftOverResultsDir}
	fi
done

echo -e ".. finished (1/4)\n"


#Copy logfiles to results directory
for i in ${chr[@]};
do
	echo "chr${i}"
	echo "Copy log files from each step to results directory.."

	rsync -a ${intermediateDir}/chr${i}.log ${logsResultsDir}
	rsync -a ${intermediateDir}/chr${i}.gh.log ${logsResultsDir}
        rsync -a ${intermediateDir}/chr${i}.gh_snpLog.log ${logsResultsDir}
        rsync -a ${intermediateDir}/chr${i}.phasing.log ${logsResultsDir}
        rsync -a ${intermediateDir}/chr${i}.phasing.snp.mm ${logsResultsDir}
        rsync -a ${intermediateDir}/chr${i}.phasing.ind.mm ${logsResultsDir}
done


#Create new file with chunks, based on parameter file with chunk notation: chr_pos-pos
awk '{if (NR!=1){print "chr"$1"_"$2"-"$3}}' FS="," ${githubDir}/chunks_b37.csv > ${intermediateDir}/chunks.txt


#Copy chunk file statistics to results directory
for i in $(cat ${intermediateDir}/chunks.txt);
do
	rsync -a ${intermediateDir}/${i}_info_by_sample ${logsResultsDir}
	rsync -a ${intermediateDir}/${i}_summary ${logsResultsDir}
done
echo -e ".. finished (2/4)\n"


#Create tar.gz per chromosome
echo "chr${chr}"
echo "Creating tar.gz file per chromosome in results directory.."


#Rename to create consistency in finalresult
rename '.gh'  '' ${intermediateDir}/chr${i}.{haps,sample}

for i in ${chr[@]};
do
	tar -cvzf ${finalResultsDir}/chr${i}.tar.gz ${intermediateDir}/chr${i}.haps ${intermediateDir}/chr${i}.sample ${intermediateDir}/chr${i}_concatenated ${intermediateDir}/chr${i}_info_concatenated
done

echo "Tar.gz file created: ${finalResultsDir}/chr${chr}.tar.gz"
echo -e ".. finished (3/4)\n"


#Create md5sum for tar.gz file per chromosome
echo "chr${chr}"
echo "Creating md5sums for tar.gz files in results directory.."

for i in ${chr[@]};
do
	md5sum ${finalResultsDir}/chr${i}.tar.gz > ${finalResultsDir}/chr${i}.tar.gz.md5
done

echo "md5sums created: ${finalResultsDir}/chr${chr}.tar.gz.md5"
echo -e ".. finished (4/4)\n"


#Remove intermediateDir
if [ -d ${intermediateDir:-} ]; then
	echo -n "INFO: Removing intermediateDir ${intermediateDir} ..."
	rm -rf ${intermediateDir}
	echo 'done.'

	echo "pipeline is finished"
	touch ${studyData}.pipeline.finished
	echo "${studyData}.pipeline.finished is created"
fi


