# gbas
A R package for gene-based association study

on Linux
2024.3.24

## install
you can install gbas:
```R
devtools::install_github("gaze-abyss/gbas")
```

## input data

The vcf files need to be converted using vcftools:
```shell
vcftools --gzvcf your.vcf.gz --012 --out your
```
The phenotype data must be in csv format, and a gene interval file that requires a special processing. \
Phenotypic data for the control group are also required.

## usage


## about gbas
> It is currently in beta and features are not complete
