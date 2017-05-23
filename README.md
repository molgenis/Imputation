# MOLGENIS Imputation 1.x

## The imputation pipeline consists of four main steps:

1) LiftOver
2) Phasing
3) GenotypeHarmonizer
4) Imputation

### Step 1, LiftOver

During this step, the genomic assembly of the data is converted from one genomebuild to another.
At this moment, there are two LiftOver options:

* hg18 -> hg19
* hg38 -> hg19

Tools used by the LiftOver step:

* LiftOver, version 20161011
* PLINK, version 1.9


### Step 2, Phasing

During this step, the haplotype structure of the data is determined.

Tools used by the Phasing step:

* SHAPEIT, v2.r837-static


### Step 3, GenotypeHarmonizer 

During this step, quality control is performed and the data is aligned to the reference data.

Tools used by the GenotypeHarmonizer step:

* GenotypeHarmonizer, version 1.4.18


### Step 4, Imputation

During this step, the data is split into many chunks, in order to impute the data properly.

Tools used by the Imputation step:

* IMPUTE2, version 2.3.0_x86_64_static 







## Running the imputation pipeline

**_NOTE:_** Change this line in the parameters file in order to match the group you are running the pipeline in:
gafTmp,/groups/umcg-gaf/tmp04/ --> gafTmp,/groups/${YOUR_GROUP_NAME}/tmp04/

### 1) Create a directory for your project
```bash
mkdir /groups/${GROUP}/tmp04/generatedscripts/${PROJECT}
```

### 2) Copy datasheet.csv to this directory and adjust the file to match your project
```bash
cp datasheet.csv /groups/${GROUP}/tmp04/generatedscripts/${PROJECT}/
```
* studyData: name of your project
* genomeBuild: The genomebuild of your data
* referenceGenome: The reference genome to phase against, currently supported: gonl and 1000G
* run: name of the run

### 3) Copy generate_template.sh to this directory and change the default settings to match your project
```bash
cp generate_template.sh /groups/${GROUP}/tmp04/generatedscripts/${PROJECT}/
```

### 4) Create a folder called "input" and copy your data (.bed, .bim, .fam per chromosome) there
```bash
cp ${YOUR_DATA_FILES} /groups/${GROUP}/tmp04/generatedscripts/${PROJECT}/input/
```

### 5) Submit generate_template.sh
```bash
sh generate_template.sh
```
Your jobs are generated and can be found in this folder:
/groups/${GROUP}/tmp04/projects/${PROJECT}/${RUNID}/jobs/

### 6) Submit your jobs
```bash
sh submit.sh
```
Your results can be found here:
/groups/${GROUP}/tmp04/projects/${PROJECT}/${RUNID}/results/

**_NOTE:_** In case of a crash, the temporary results can be found here:
/groups/${GROUP}/tmp04/tmp/${PROJECT}/
