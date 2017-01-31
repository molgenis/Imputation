#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string liftOverResultsDir
#string logsResultsDir
#string finalResultsDir
#list chr
#string intermediateDir
#string githubDir
#string studyData


#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}


#Create result directories
mkdir -p ${liftOverResultsDir}
mkdir -p ${logsResultsDir}
mkdir -p ${finalResultsDir}


#Create string with chromosomes
#This check needs to be performed because Compute generates duplicate values in array
CHRS=()

for chromosome in "${chr[@]}"
do
	array_contains CHRS "${chromosome}" || CHRS+=("${chromosome}")    # If chr does not exist in array, add it
done


#Copy liftover files to results directory
#If genome builds are the same, only ped and map files are created and copied.
printf "Copy liftover files to results directory "

for i in ${CHRS[@]}
do
	if [[ $(grep "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}" s01_liftOver_*.out) ]]
	then
		rsync -a ${intermediateDir}/chr${i}.{ped,map} ${liftOverResultsDir}
	else
		rsync -a ${intermediateDir}/chr${i}.{bed,bim,fam,ped,map} ${liftOverResultsDir}
	fi

	printf "."
done

printf " finished (1/5)\n"


#Copy logfiles to results directory
printf "Copy log files from each step to results directory "

for i in ${CHRS[@]}
do
	#Copy LiftOver log
	rsync -a ${intermediateDir}/chr${i}.log ${logsResultsDir}

	#Copy GH logs
	rsync -a ${intermediateDir}/chr${i}.gh{.log,_snpLog.log} ${logsResultsDir}

	#Copy phasing logs
	rsync -a ${intermediateDir}/chr${i}.phasing.{log,snp.mm,ind.mm} ${logsResultsDir}

	printf "."
done

printf " finished (2/5)\n"

#Create new file with chunks, based on parameter file with chunk notation: chr_pos-pos
awk '{if (NR!=1){print "chr"$1"_"$2"-"$3}}' FS="," ${githubDir}/chunks_b37.csv > ${intermediateDir}/chunks.txt


#Copy chunk file statistics to results directory
printf "Copy chunks statistics to results directory "

for i in $(cat ${intermediateDir}/chunks.txt)
do
	rsync -a ${intermediateDir}/${i}_{info_by_sample,summary} ${logsResultsDir}

	printf "."
done

printf " finished (3/5)\n"


#Rename to create consistency in finalresult
#Print message when files are already renamed (restart of job)
for i in ${CHRS[@]}
do
	if ! [[ -f ${intermediateDir}/chr${i}.haps ]]
	then
		rename '.gh'  '' ${intermediateDir}/chr${i}.gh.haps
	else
		echo "Haps file of chr${i} is already renamed..."
	fi

	if ! [[ -f ${intermediateDir}/chr${i}.sample ]]
	then
		rename '.gh'  '' ${intermediateDir}/chr${i}.gh.sample
	else
		echo "Sample file of chr${i} is already renamed..."
	fi

	if ! [[ -f ${intermediateDir}/chr${i} ]]
	then
		rename '_concatenated'  '' ${intermediateDir}/chr${i}_concatenated
	else
		echo "Concatenated file of chr${i} is already renamed..."
	fi

	if ! [[ -f ${intermediateDir}/chr${i}_info ]]
	then
		rename '_concatenated'  '' ${intermediateDir}/chr${i}_info_concatenated
	else
		echo "Info file of chr${i} is already renamed..."
	fi
done

#Create tar.gz per chromosome
#Remove tar.gz first, in case a job needs to be restarted
printf "Creating tar.gz file per chromosome in results directory\n"

for i in ${CHRS[@]}
do
	rm -rf ${finalResultsDir}/chr${i}.tar.gz
	tar -cvzf ${finalResultsDir}/chr${i}.tar.gz ${intermediateDir}/chr${i}.haps ${intermediateDir}/chr${i}.sample ${intermediateDir}/chr${i} ${intermediateDir}/chr${i}_info

	printf "."
done

printf " finished (4/5)\n"

#Create md5sum for tar.gz file per chromosome
#Remove md5sum first, in case a job needs to be restarted
printf "Creating md5sums for tar.gz files in results directory "

#Change directory to results directory to perform md5sum
cd ${finalResultsDir}

for i in ${CHRS[@]}
do
	rm -rf chr${i}.tar.gz.md5
	md5sum chr${i}.tar.gz > chr${i}.tar.gz.md5

	printf "."
done

#Change directory back
cd -

printf " finished (5/5)\n"

printf "Done copying files, pipeline is finished. Results can be found here: ${projectDir}/results/"
touch ${studyData}.pipeline.finished


