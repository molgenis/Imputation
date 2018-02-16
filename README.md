
# MOLGENIS Imputation 2.x

## The imputation pipeline consists of five main steps:

1) LiftOver
2) Phasing
3) GenotypeHarmonizer
4) Imputation
5) CreateStats

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

* IMPUTE4, version r265 


### Step 5, CreateStats

During this step, statistics are measured for the imputed data.

Tools used by the Imputation step:

* QCTOOL, version 1.4  


<br />

## Running the imputation pipeline


### 1) Create a directory for your project
```bash
mkdir /groups/${GROUP}/${tmpDir}/generatedscripts/${PROJECT}
```

### 2) Copy datasheet.csv to this directory and adjust the file to match your project
```bash
cp datasheet.csv /groups/${GROUP}/${tmpDir}/generatedscripts/${PROJECT}/
```
* study: Name of your project
* rawdata: Location of the input data (should be in .bed, .bim, .fam format per chromosome)
* genomeBuild: The genomebuild of your data
* referenceGenome: The reference genome used for imputation, currently supported: gonl and 1000G
* run: Name of the run (e.g. run01)

### 3) Copy generate_template.sh to this directory and change the settings to match your project
```bash
cp generate_template.sh /groups/${GROUP}/${tmpDir}/generatedscripts/${PROJECT}/
```

### 4) Generate your jobs
```bash
sh generate_template.sh
```
Your jobs are generated and can be found here:
/groups/${GROUP}/${tmpDir}/projects/${PROJECT}/${RUN}/jobs/

### 5) Submit your jobs
```bash
sh submit.sh
```
Your results can be found here:
/groups/${GROUP}/${tmpDir}/projects/${PROJECT}/${RUN}/results/

**_NOTE:_** In case of a crash, the temporary results can be found here:
/groups/${GROUP}/${tmpDir}/tmp/${PROJECT}/
