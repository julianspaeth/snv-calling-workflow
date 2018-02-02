# SNP Calling - A Comparison of Tools and Methods

# The Project
SNV calling describes the act of detecting so-called SNVs, single nucleotide variants. These are variations in the genetic code, specified for a single nucleotide site, of individuals within a species, or within different cells from a single organism, for example by comparing healthy tissue to cancer tissue.
SNVs are therefore certain cases of the more generalized single nucleotide polymorphisms, [SNPs](https://www.nature.com/scitable/definition/single-nucleotide-polymorphism-snp-295). 
Considering the whole genome sequence of a virus, an organism or single tissue cells as reference, we can align the assembled result from NGS, next-generation sequencing, and then detect single nucleotide deletions, insertions, or substitutions. Before making diagnostic considerations, general statistical values can be extracted from SNV calling, e.g. frequencies and locations of variations. The whole process from NGS reads and reference genome to those statistical values could be simplified by calling the required applications in a scripting based approach, and keeping the applied tools and methods within the script file modular, we can then detect and interpret differences between those tools. Since there is quite a selection of assembly tools alone (e.g. bowtie-2, BWA, segemehl, ...), the same set of NGS reads and references could yield different results for each tool ([bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml), [bwa](http://bio-bwa.sourceforge.net/)}. 

Even though such an approach has already been done in a rather large format, the main goal of our project is supposed to present a simple overview of tools and their differences in regards of speed, error rate, and use-convenience, in order to provide an outline that could also be helpful to our fellow students, should they be confronted with the task of SNV calling in the future.  
Further, applying applications of phylogenetic tree generation, comparing the output of each run can be visualized.


# The Workflow

![5](docs/snp_workflow_graph/snp_workflow_final.jpg)

## Tools need to be installed:

+ Workflow "Language": [GNU Make](https://www.gnu.org/software/make/) - Version 4.1
+ Data accession: [SRAToolkit](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/) - Version 2.8.2
+ Quality Trimming: [Sickle](https://github.com/najoshi/sickle) - Version 1.33
+ Mapping:
    + [BWA](https://github.com/lh3/bwa) Version - 0.7.12
    + [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) Version 2.2.6
+ SNV Calling and preprocessing
    + [Samtools](http://www.htslib.org/) - Version 1.6
    + [bcftools](http://www.htslib.org/) - Version 1.6
    + [GATK](https://software.broadinstitute.org/gatk/) - Version 3.8
        + GenomeAnalysisTK.jar should be in the same location as the Makefile
    + [Picard](http://broadinstitute.github.io/picard/) - Version 2.17.1
        + picard.jar should be in the same location as the Makefile
    + [Java](https://java.com/de/download/) - Version 1.8

As well as wget and gunzip. The workflow was tested on a Ubuntu 16.04 environment. 

## Apply the workflow 
The workflow itself is based on GNU Make and can be easily called by: 

```
make -f Makefile MAPPER="name_of_the_mapper" CALLER="name_of_the_caller" SRA="sra_number" REF_URL="ref_genome_ftp_url" REF_GENOME_FILE="unzipped_ref_genome_file_name"
```

The user can choose between two mappers, bwa and bowtie2, as well as between two variant calling tools, samtools/bcftools and gatk. In the following example call you use bwa to do the mapping and gatk to do the variant calling. Therefore we take the e-coli genome as the reference genome and the raw reads contained in the SRA number SRR3736639:

```
make -f Makefile MAPPER="bwa" CALLER="bcftools" SRA="SRR3736639" REF_URL="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz" REF_GENOME_FILE="GCF_000005845.2_ASM584v2_genomic.fna"
```

Attention:
+ The SRA samples should contain both forward and reverse strands!
+ If files are already existing in the folders the workflow generates, they wont be computed again. This allows an easy continuation of the computations
    + BUT if you cancel the workflow right in between you should delete the corrupt files by hand!

## Apply the workflow on multiple samples
In this case an attached bash-script (run_workflow.sh) can be easily adjusted to perform the workflow on multiple SRA samples with different map and variant call tools. This is an example of how the adjustment could look like:

```
ref_url="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"

ref_file="GCF_000005845.2_ASM584v2_genomic.fna"

declare -a mappers=("bwa"
    "bowtie2"
    )

declare -a callers=("bcftools"
    "gatk"
    )

declare -a sras=("SRR3736622" "SRR3736623")
```

and finally run the bash script in the same folder as the Makefile of the workflow:
```
./run_workflow.sh
```

This would run the workflow for the two given samples four times: once with bwa und bcftools, once with bowtie2 and bcftools, once with bwa and gatk and last but not least with bowtie2 and gatk.

## The Output
The workflow delivers a .vcf file for the corresponding SRA sample and its reference genome. If you use gatk for the variant calling the resulting .vfc file only contains the snps! The .vfc file generated by bcftools contains everything.