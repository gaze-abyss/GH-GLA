#' @title Package GH-GLA_model3
#'
#' @param pheno_column numbers
#' @param gene_region path, txtfile
#' @param anno path,txtfile
#' @param wt path,csvfile
#' @param phenotype path,csvfile
#' @param filename character,vcftools output file
#' @param genotype_path path
#' @param outpath outpath
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
#' "/respath/")
#'

gla_model3 = function(filename,
                      pheno_column,
                      gene_region,
                      anno,
                      wt,
                      genotype_path,
                      phenotype,
                      outpath){
  ####inputdata
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
  snpeffect$score[grep("MODERATE",snpeffect$V3)] = 4.0001
  snpeffect$score[grep("LOW",snpeffect$V3)] = 3.00001
  snpeffect$score[grep("MODIFIER",snpeffect$V3)] = 2.000001

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
      asum$apply.a..1..scoresum.[which(asum$apply.a..1..scoresum. == 0)] = 1.0000001
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
  ###run
  y_chi = res.score$pheno2
  chi_res = c()
  for (i in 1:(dim(res.score)[2]-1)) {
    x = res.score[,i]
    a = summary(glm(y_chi~x))
    output = a$coefficients[dim(a$coefficients)[1],4]
    chi_res = c(chi_res,output)
  }
  gc()
  chi_res = data.frame(pvalue = chi_res)
  chi_res$genename = colnames(res.score)[1:(dim(res.score)[2]-1)]

  saveRDS(chi_res,paste0(outpath,"/model3_",filename,"_",pheno_column,".rds"))
}
