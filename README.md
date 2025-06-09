# Gene Hunter based on Gene-Level Association (GH-GLA)
A R-package for gene-based association study

on Linux
2025.6.9

## install
Need to install in advance: data.table, stringr, dplyr \
You can install GHGLA:
```R
install.packages("devtools")
devtools::install_github("gaze-abyss/GH-GLA")
``` 

## input data

The vcf files need to be converted using vcftools:
```shell
vcftools --gzvcf yourname.vcf.gz --012 --out yourname
```
The phenotype data must be in csv format(There can be multiple phenotypes in this csv, each phenotype is a separate column), and a gene interval file that requires a special processing. \
Phenotype data for the control group are also required. \
Project website of the vcftools: https://vcftools.github.io/

Model3 requires SnpEff results, and refer to the examples in the `/data` for specific requirements.
```shell
java -jar snpEff wheat yourname.chr2D.vcf.gz > yourname.snpEff.vcf
```
Project website of the SnpEff: https://pcingola.github.io/SnpEff/

## usage
You can choose to use gla_model2 or gla_model3(Model1 is test model, not available).

### start
Write the parameters into the function. The meanings of the parameters can be found in the annotation in the code below. The format of the input data can refer to the example in /data.

```R
rm(list=ls())
library(GHGLA)
gla_model2("chr2D",                                   #Some species' genomes are so large that they can only be counted in terms of chromosomes
            2,                                        #Which column of phenotype data is used
            "/path/data.gene.list",                   #Gene interval file
            "/path/chr2D.anno.txt",                   #SnpEff results
            "/path/control_group_phenotype.csv",      #Phenotype data for the control group
            "/path/vcftoolsres/yourname",             #Vcftools results
            "/path/phenotype.csv",                    #Phenotype data
            "/output_path/",                          #Output path
            1.05,                                     #The upper threshold of phenotypic variation, it can be adjusted according to different data characteristics
            0.95                                      #The lower threshold of phenotypic variation, it can be adjusted according to different data characteristics
            )
```
or
```R
rm(list=ls())
library(GHGLA)
gla_model3("chr2D",                                   #Some species' genomes are so large that they can only be counted in terms of chromosomes
            2,                                        #Which column of phenotype data is used
            "/path/data.gene.list",                   #Gene interval file
            "/path/chr2D.anno.txt",                   #SnpEff results
            "/path/control_group_phenotype.csv",      #Phenotype data for the control group
            "/path/vcftoolsres/yourname",             #Vcftools results
            "/path/phenotype.csv",                    #Phenotype data
            "/output_path/"                           #Output path
            )
```

### out
```R
pheno_column = 2 #Which column of phenotype data is used
data = readRDS(paste0("/output_path/model2",pheno_column,".rds"))
head(data)
```

```
     pvalue           genename
1 0.1161946 TraesKN2D01HG00010
2 0.8977729 TraesKN2D01HG00020
3 0.6568004 TraesKN2D01HG00030
4 0.8100888 TraesKN2D01HG00040
5 0.3255892 TraesKN2D01HG00050
6 0.1742378 TraesKN2D01HG00060
```

## Citation
If you make use of GH-GLA in your research, we would appreciate a citation of the following paper: 
> **Wang et al., (2025). A forward genetics strategy for high-throughput gene identification via precise image-based phenotyping of an indexed EMS mutant library** 

## about GH-GLA
> If you have any questions, please feel free to leave a message
