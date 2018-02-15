#MOLGENIS walltime=05:59:59 mem=5gb ppn=21

#string pigzVersion
#string liftOverResultsDir
#string logsResultsDir
#string finalResultsDir
#list chr
#string intermediateDir
#string projectDir
#string study


#Load modules and list currently loaded modules
#module load ${pipelineVersion}
module load "${pigzVersion}"
module list


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
mkdir -p "${liftOverResultsDir}"
mkdir -p "${logsResultsDir}"
mkdir -p "${finalResultsDir}"


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
	if [[ -f "s01_LiftOver_"*".out" ]]
	then
		if [[ $(grep "Genome builds of study data and reference data are the same, ped and map files are created and can be found here: ${intermediateDir}" "s01_LiftOver_"*".out") ]]
		then
			rsync -a "${intermediateDir}/chr${i}."{ped,map} "${liftOverResultsDir}"
		fi
	elif [[ -f "${intermediateDir}/chr${i}."{bed,bim,fam,ped,map} ]]
	then
		rsync -a "${intermediateDir}/chr${i}."{bed,bim,fam,ped,map} "${liftOverResultsDir}"
	else
		echo "No liftover files found, proceeding..."
	fi

	printf "."
done

printf " finished (1/4)\n"


#Copy logfiles to results directory
printf "Copy log files from each step to results directory "

for i in ${CHRS[@]}
do
	#Copy LiftOver log
	if [[ -f "${intermediateDir}/chr${i}.log" ]]
	then
		rsync -a "${intermediateDir}/chr${i}.log" "${logsResultsDir}"
	else
		echo "No liftover logfile found, proceeding..."
	fi

	#Copy GH logs
	if [[ -f "${intermediateDir}/chr${i}.gh"{.log,_snpLog.log} ]]
	then
		rsync -a "${intermediateDir}/chr${i}.gh"{.log,_snpLog.log} ${logsResultsDir}
	else
		echo "No GH logfile found, proceeding..."
	fi

	#Copy phasing logs
	if [[ -f "${intermediateDir}/chr${i}.phasing."{log,snp.mm,ind.mm} ]]
	then
		rsync -a "${intermediateDir}/chr${i}.phasing."{log,snp.mm,ind.mm} "${logsResultsDir}"
	else
		echo "No phasing log files found, proceeding..."
	fi

	printf "."
done

printf " finished (2/4)\n"

#Rename to create consistency in finalresult
#Print message when files are already renamed (restart of job)
for i in ${CHRS[@]}
do
	if ! [[ -f "${intermediateDir}/chr${i}.haps" ]]
	then
		rename '.gh'  '' "${intermediateDir}/chr${i}.gh.haps"
	else
		echo "Haps file of chr${i} is already renamed..."
	fi

	if ! [[ -f "${intermediateDir}/chr${i}.sample" ]]
	then
		rename '.gh'  '' "${intermediateDir}/chr${i}.gh.sample"
	else
		echo "Sample file of chr${i} is already renamed..."
	fi

	if ! [[ -f "${intermediateDir}/chr${i}" ]]
	then
		rename '_concatenated'  '' "${intermediateDir}/chr${i}_concatenated"
	else
		echo "Concatenated file of chr${i} is already renamed..."
	fi

	if ! [[ -f "${intermediateDir}/chr${i}_info" ]]
	then
		rename '_concatenated'  '' "${intermediateDir}/chr${i}_info_concatenated"
	else
		echo "Info file of chr${i} is already renamed..."
	fi
done


#Create tar.gz per chromosome
printf "Creating tar.gz file per chromosome in results directory\n"

for i in ${CHRS[@]}
do
	tar -cvf - "${intermediateDir}/chr${i}.haps" "${intermediateDir}/chr${i}.sample" "${intermediateDir}/chr${i}" "${intermediateDir}/chr${i}_info" | pigz -p 20 > "${finalResultsDir}/chr${i}.tar.gz"

	printf "."
done

printf " finished (3/4)\n"


#Create md5sum for tar.gz file per chromosome
printf "Creating md5sums for tar.gz files in results directory\n"


#Change directory to results directory to perform md5sum
cd "${finalResultsDir}"

for i in ${CHRS[@]}
do
	md5sum "${finalResultsDir}/chr${i}.tar.gz" > "${finalResultsDir}/chr${i}.tar.gz.md5"

	printf "."
done


#Change directory back
cd -

printf " finished (4/4)\n"


#Remove intermediateDir
if [ -d ${intermediateDir:-} ]
then
	printf "Removing intermediateDir: ${intermediateDir}\n"
	rm -rf "${intermediateDir}"
fi

printf "Done copying files, pipeline is finished. Results can be found here: ${projectDir}/results/\n"
touch "${study}.pipeline.finished"
