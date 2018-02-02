SHELL=/bin/bash
all: snpcalling
	@echo "------ FINISHED WORKFLOW -----"

# Create vcf file
snpcalling: bam
	@if [ $(CALLER) != bcftools ] && [ $(CALLER) != gatk ];\
	then\
		echo "Error! Please use bcftools or gatk as snp caller!";\
		exit 1;\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).bcf ] && [ $(CALLER) == bcftools ];\
	then\
		echo "Create bcf using samtools ...";\
		samtools mpileup --skip-indels --BCF -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE) -o $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).bcf $(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bam;\
	else\
		echo "BCF already created by bcftools or not needed ...";\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).vcf ] && [ $(CALLER) == bcftools ];\
	then\
		echo "Call SNPs using bcftools ...";\
		bcftools call -m --skip-variants indels -O v $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).bcf -o $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).vcf;\
	else\
		echo "SNPs already called or by bcftools or not needed ...";\
	fi;

	@if [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).fai ] && [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bai ] && [ $(CALLER) == gatk ];\
	then\
		echo "Index reference with samtools and bam with picard ...";\
		samtools faidx $(REF_GENOME_FILE)/$(REF_GENOME_FILE);\
		java -jar picard.jar BuildBamIndex I=$(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bam;\
	else\
		echo "Indexed file .fai/.bai already created by samtools/picard or not needed ...";\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sorted_with_readgroups.bam ] && [ $(CALLER) == gatk ];\
	then\
		echo "Add groups to bam and using picard ...";\
		java -jar picard.jar AddOrReplaceReadGroups I=$(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bam O=$(SRA)/$(MAPPER)/$(SRA)_aln.sorted_with_readgroups.bam RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20;\
	else\
		echo "Groups already added to bam by picard or not needed ...";\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bai ] && [ $(CALLER) == gatk ];\
	then\
		echo "Index bam with picard ...";\
		java -jar picard.jar BuildBamIndex I=$(SRA)/$(MAPPER)/$(SRA)_aln.sorted_with_readgroups.bam;\
	else\
		echo "Indexed bam already created by picard or not needed...";\
	fi;

	@if [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).dict ] && [ $(CALLER) == gatk ];\
	then\
		echo "Create dictionary using picard ... ...";\
		java -jar picard.jar CreateSequenceDictionary R=$(REF_GENOME_FILE)/$(REF_GENOME_FILE) O=$(REF_GENOME_FILE)/$(REF_GENOME_FILE).dict;\
	else\
		echo "Dict already created by picard or not needed ...";\
	fi;
	
	@if [ ! -f $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).vcf ] && [ $(CALLER) == gatk ];\
	then\
		echo "Call SNPs using GATK...";\
		java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R $(REF_GENOME_FILE)/$(REF_GENOME_FILE) -I $(SRA)/$(MAPPER)/$(SRA)_aln.sorted_with_readgroups.bam -stand_call_conf 20 -o $(SRA)/$(MAPPER)/$(CALLER)/$(SRA).vcf ;\
	else\
		echo "SNPs already called by GATK or not needed ...";\
	fi;

# Convert to bam and sort
bam: clean
	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bam ];\
	then\
		echo "Convert to bam and sort.";\
		samtools sort -O bam -o $(SRA)/$(MAPPER)/$(SRA)_aln.sorted.bam -T /tmp/aln.sorted $(SRA)/$(MAPPER)/$(SRA)_aln.fixmate.sam;\
	else\
		echo "Already sorted and converted to bam.";\
	fi;

# Clean up sam file
clean: map 
	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.fixmate.sam ];\
	then\
		echo "Clean up read pairing information and flags";\
		samtools fixmate -O bam $(SRA)/$(MAPPER)/$(SRA)_aln.sam $(SRA)/$(MAPPER)/$(SRA)_aln.fixmate.sam;\
	else\
		echo "SAM file already cleaned up.";\
	fi;

# Map trimmed reads
map: index trim
	@if [ $(MAPPER) != bwa ] && [ $(MAPPER) != bowtie2 ];\
	then\
		echo "Error! Please use bwa or bowtie2 as mapper!";\
		exit 1;\
	fi;

	@if [ -f $(SRA)/$(MAPPER)/$(SRA)_aln.sam ];\
	then\
		echo "Reads are already mapped ...";\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sam ] && [ $(MAPPER) == bwa ];\
	then\
		echo "Map reads to reference using bwa...";\
		bwa mem $(REF_GENOME_FILE)/$(REF_GENOME_FILE) $(SRA)/$(SRA)_1_trimmed.fastq $(SRA)/$(SRA)_2_trimmed.fastq > $(SRA)/$(MAPPER)/$(SRA)_aln.sam;\
	fi;

	@if [ ! -f $(SRA)/$(MAPPER)/$(SRA)_aln.sam ] && [ $(MAPPER) == bowtie2 ];\
	then\
		echo "Map reads to reference using bowtie2...";\
		bowtie2 -x $(REF_GENOME_FILE)/$(REF_GENOME_FILE) -1 $(SRA)/$(SRA)_1_trimmed.fastq -2 $(SRA)/$(SRA)_2_trimmed.fastq -S $(SRA)/$(MAPPER)/$(SRA)_aln.sam;\
	fi;

# Index reference genome
index: ref_genome
	@if [ $(MAPPER) != bwa ] && [ $(MAPPER) != bowtie2 ];\
	then\
		echo "Error! Please use bwa or bowtie2 as mapper!";\
		exit 1;\
	fi;

	@if [ $(MAPPER) == bowtie2 ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).1.bt2 ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).2.bt2 ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).3.bt2 ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).4.bt2 ];\
	then\
		echo "Index reference using bowtie2";\
		bowtie2-build -p $(REF_GENOME_FILE)/$(REF_GENOME_FILE) $(REF_GENOME_FILE)/$(REF_GENOME_FILE);\
	else\
		echo "Reference already indexed by bowtie2 or not needed.";\
	fi;

	@if [ $(MAPPER) == bwa ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).amb ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).ann ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).bwt ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).pac ] && [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE).sa ];\
	then\
		echo "Index reference using BWA ...";\
		bwa index $(REF_GENOME_FILE)/$(REF_GENOME_FILE);\
	else\
		echo "Reference already indexed by bwa or not needed.";\
	fi;

# Trim paired-end fast q files
trim: reads 
	@if [ ! -f $(SRA)/$(SRA)_1_trimmed.fastq ] && [ ! -f $(SRA)/$(SRA)_2_trimmed.fastq ];\
	then\
		echo "Trim reads ...";\
		sickle pe -f $(SRA)/$(SRA)_1.fastq -r $(SRA)/$(SRA)_2.fastq -t sanger -o $(SRA)/$(SRA)_1_trimmed.fastq -p $(SRA)/$(SRA)_2_trimmed.fastq -s $(SRA)/$(SRA)_trimmed_singles_file.fastq;\
	else\
		echo "Reads already trimmed.";\
	fi;
	

# Download files from SRA #SRR5817936
reads: dir
	@if [ ! -f $(SRA)/$(SRA)_1.fastq ] && [ ! -f $(SRA)/$(SRA)_2.fastq ];\
	then\
		echo "Download pair-end reads $(SRA) ...";\
		fastq-dump --split-files --outdir $(SRA) $(SRA);\
	else\
		echo "Reads already exist.";\
	fi;

# create directories if not already exists
dir: 
	@echo "SNP Calling Workflow"
	@echo "$(SRA)"
	@echo "Mapper: $(MAPPER)"
	@echo "SNP Calling Tool: $(CALLER)"
	@echo "Create necessary folders ..."
	mkdir -p $(SRA)
	mkdir -p $(SRA)/$(MAPPER)
	mkdir -p $(SRA)/$(MAPPER)/$(CALLER)
	mkdir -p $(REF_GENOME_FILE)

# Download ref genome
ref_genome: dir
	@if [ ! -f $(REF_GENOME_FILE)/$(REF_GENOME_FILE) ];\
	then\
		echo "Download reference ...";\
		wget -P $(REF_GENOME_FILE) $(REF_URL);\
		gunzip $(REF_GENOME_FILE)/$(REF_GENOME_ZIP);\
	else\
		echo "Reference genome already exists.";\
	fi;

# Internal Variables:
REF_GENOME_ZIP = $(REF_GENOME_FILE).gz