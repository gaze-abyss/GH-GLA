#' Title Package GH-GLA_model2
#'
#' @param pheno_column numbers
#' @param gene_region path, txtfile
#' @param anno path,txtfile
#' @param wt path,csvfile
#' @param phenotype path,csvfile
#' @param filename character,vcftools output file
#' @param genotype_path path
#' @param outpath outpath
#' @param cutup up cutof
#' @param cutdown down cutof
#'
#' @return RDS
#' @export
#' 
#' @import data.table
#' @import stringr
#' @import dplyr
#'
#' @examples
#' gla_model3("chr4A",
#' 2,
#' "/path/data.gene.list",
#' "/path/chr4A.anno.txt",
#' "/path/wildtype.csv",
#' "/path/vcftoolsres/",
#' "/path/phenotype.csv",
#' "/respath/",
#' 1.05,
#' 0.95)
#'

gla_model2 = function(filename,
                      pheno_column,
                      gene_region,
                      anno,wt,
                      genotype_path,
                      phenotype,
                      outpath,
                      cutup,
                      cutdown){
  
  df = fread(paste0(genotype_path,"/",filename,".012"),header = F)
  df = df[,-1]
  pos = read.table(paste0(genotype_path,"/",filename,".012.pos"))
  indv = read.table(paste0(genotype_path,"/",filename,".012.indv"))
  colnames(df) = as.character(pos$V2)
  rownames(df) = indv$V1
  df = data.frame(t(as.matrix(df)))
  colnames(df) = indv$V1

  gene.region = read.table(gene_region)
  anno1 = gene.region[grep(names,gene.region$V1),]
  genename = str_split(anno1$V9,"=",simplify = T)[,2]
  genename = str_split(genename,";",simplify = T)[,1]
  
  snpeffect = read.table(anno)
  snpeffect = snpeffect[,c(2,3)]
  snpeffect = snpeffect[snpeffect$V2%in%as.numeric(rownames(df)),]
  snpeffect$score = snpeffect$V3
  snpeffect$score[grep("HIGH",snpeffect$V3)] = 5.001
  snpeffect$score[grep("MODERATE",snpeffect$V3)] = 4.001
  snpeffect$score[grep("LOW",snpeffect$V3)] = 3.001
  snpeffect$score[grep("MODIFIER",snpeffect$V3)] = 2.001

  pheno = read.csv(phenotype)
  rownames(pheno) = pheno[,1]
  df = df[,colnames(df)%in%pheno[,1]]
  wildtype = read.csv(wt,header = T)

  gc()
  res.score = data.frame(colnames(df))
  for (i in 1:dim(anno1)[1]) {
    l = anno1[i,c(4,5)]
    tmp = which(l$V4-2000 < pos$V2 & l$V5+2000 > pos$V2)
    if (length(tmp) == 0) {
      next
    }else{
      tmp.df = df[tmp,]
      tmp.eff = snpeffect[tmp,]
      tmp.dflength = dim(tmp.df)[2]+1
      tmp.df[,tmp.dflength] = 1:dim(tmp.df)[1]
      a = apply(tmp.df,1,givescore)
      asum = data.frame(apply(a,1,scoresum))
      asum$apply.a..1..scoresum.[which(asum$apply.a..1..scoresum. == 0)] = 1.001
      colnames(asum) = str_split(str_split(anno1$V9[i],"=",simplify = T)[,2],";",simplify = T)[,1]
      res.score = cbind(res.score,asum)
    }
  }
  
  ####asscoc calculate
  ###clean input data
  res.score = res.score[,-1]
  res.score[rownames(res.score)%in%wildtype[,1],] = 0
  res.score$pheno2 = pheno[rownames(res.score),pheno_column]
  if (length(which(is.na(res.score$pheno2) == T)) != 0) {
    res.score = res.score[-which(is.na(res.score$pheno2) == T),]
  }
  if (length(which(is.na(res.score$pheno2) == T)) != 0) {
    res.score = res.score[-which(is.na(res.score$pheno2) == T),]
  }
  ####mutation enrichment  
  pheno_wt = read.csv(wt)
  pheno_wt = pheno_wt[pheno_wt[,1] %in% rownames(res.score),]
  pheno_wt = pheno_wt[,pheno_column]
  cut_up = mean(pheno_wt)*cutup
  cut_down = mean(pheno_wt)*cutdown
  
  cut_up_sample = rownames(res.score)[which(res.score$pheno2 > cut_up)]
  cut_down_sample = rownames(res.score)[which(res.score$pheno2 < cut_down)]
  mutant_sample = c(cut_up_sample,cut_down_sample)
  
  wt_num = length(pheno_wt)
  chi.res = c()
  for (i in 1:(dim(res.score)[2]-1)){
    r1 = length(which(res.score[rownames(res.score)%in%mutant_sample,i] > 1.001))
    r2 = length(mutant_sample) -r1
    r3 = length(which(res.score[!rownames(res.score)%in%mutant_sample,i] > 1.001))
    r4 = dim(res.score)[1]- wt_num - length(mutant_sample) -r3
    enrichment = matrix(c(r1, r2, r3 ,r4),ncol=2, dimnames = list(c('mutation','nomutation'),
                                                                  c('yes','no')))
    chi = fisher.test(enrichment)
    chi.res = c(chi.res,chi$p.value)
  }
  chi.res = data.frame(pvalue = chi.res)
  chi.res$genename = colnames(res.score)[-dim(res.score)[2]]
  gc()
  saveRDS(chi_res,paste0(outpath,"/model2",pheno_column,".rds"))
}
