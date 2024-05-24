# Gene Hunter based on Gene-Level Association (GH-GLA)
A R package for gene-based association study

on Linux
2024.5.22

## install
Need to install in advance: data.table, stringr, dplyr \
You can install gbas:
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
Model3 requires SnpEff results.
```shell
snpEff wheat yourname.chr2D.vcf.gz > yourname.chr2D.annotesplit.vcf
```

## usage
You can choose to use model2 or model3(Model1 is a test model, not available).

```R
rm(list=ls())
library(GHGLA)
gbas_model3("chr2D",                                  #Some species' genomes are so large that they can only be counted in terms of chromosomes
            2,                                        #Which column of phenotype data is used
            "/path/data.gene.list",                   #gene interval file
            "/path/yourname.chr2D.annotesplit.vcf",   #SnpEff results
            "/path/control_group_phenotype.csv",      #Phenotype data for the control group
            "/path/vcftoolsres/yourname",             #vcftools results
            "/path/phenotype.csv",                    #phenotype data
            "/output_path/")
```

## about gbas
> It is currently in beta and the features are not complete
