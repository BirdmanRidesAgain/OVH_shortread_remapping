#!/bin/bash
# This is script to produce process raw short-read data to vcfs.


################################################################################################
THIERRY CODE
################################################################################################
# Modules

# Load config file
source /mnt/lustre/users/kcollier/TEST_SZFRP_2023/SCRIPTS/data_processing/config_TEST_SZFRP_2023.cfg

# create directories
mkdir -p -- ${readQ_SCR}
echo "create the directory ${readQ_SCR}"

# List of individuals
ls -d ${fqdir}/*/ | sed 's/.$//' | awk '{print $NF}' FS=/ > ${list_ind}

# Mapping and sorting reads
while read line; do 
        sed "s/XXXX/${line}/g" ${proc_SCR}/10_std_read_quality_check_TEST_SZFRP_2023.sh > ${readQ_SCR}/${line%/*}_readQcheck.sh
done < ${list_ind}

echo "$SECONDS seconds - mapping script created for ${list_ind}"
################################################################################################
################################################################################################



### SOURCING CONDA TOOLS
source  ~/mambaforge/etc/profile.d/mamba.sh
conda activate process-shortread
		## process-shortread contains Picard, bwa and fastp. Maybe GATK


### DEFINING VARIABLES ###
# Variables to be edited
PROJECT_NAME="Falco-cherrug"
ARRAY_IND=("0092" "0155" "1546" "319" "SZFRP-S-251" "SZFRP-S-256" "SZFRP-S-259" "0103" "1543" "1754" "320" "SZFRP-S-252" "SZFRP-S-257" "0149" "1544" "184" "AV.24000" "SZFRP-S-254" "SZFRP-S-258")
REFSEQ_BASE="falco-rusticolus"

# Variables not to be edited
	# Standard directories
	WD="/mnt/data-2/${PROJECT_NAME}" 
	READS="${WD}/reads"	
	REFSEQ_DIR="${WD}/refseq"
	OUTPUT="${WD}/inds"

	# Globbing/file endings
	R1="1.fq.gz"
	R2="2.fq.gz"
	REFSEQ_END=".fna"
	BAM1=".bam"
	BAM2="_CL.bam"
	BAM3="_CL-SO.bam"
	BAM4="_CL-SO-RG.bam"
	BAM5="_CL-SO-RG-MD.bam"


### CREATING DIRECTORY STRUCTURE ###
mkdir -p ${WD}
cd ${WD}
	mkdir -p ${REFSEQ_DIR}
	mkdir -p ${OUTPUT}


### BIOINFORMATICS

# Loop command to trim individuals
for str in ${ARRAY_IND[@]};
do
cd ${OUTPUT}


# Loop command to map individuals
for str in ${ARRAY_IND[@]};
do
cd ${OUTPUT}
	mkdir $str && cd $str
		bwa mem -t 10 ${REFSEQ_DIR}/${REFSEQ_BASE}${REFSEQ_END} \
		${READS}/${str}${R1} ${READS}/${str}${R2} | samtools view -bS > ${str}${BAM1}
	echo "${str} has finished mapping."
	
		picard CleanSam -I $str${BAM1} -O $str${BAM2}
		picard SortSam -I $str${BAM2} -O $str${BAM3} --SORT_ORDER coordinate
		picard AddOrReplaceReadGroups -I $str${BAM3} -O $str${BAM4} --RGID 1 --RGLB library1 --RGPL illumina --RGPU unit1 --RGSM $str
		picard MarkDuplicates -I $str${BAM4} -O $str${BAM5}

	echo "$str has finished Picard post-processing."
cd ${OUTPUT}	
done
