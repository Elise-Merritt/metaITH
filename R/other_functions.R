library(ggplot2)
library(reshape2)
library(ape)
library(phylobase)
library(dplyr)
library(matrixStats)

############################################################################### SNV heatmaps #####################################################################
#' Outputs a heatmap of variant allele frequency.
#' 
#' Takes in text file containing list of sample files.  
#' Outputs a heatmap of variant allele frequency (vaf) of all variations for each sample. 
#' @usage snv_heatmaps(dna_dendro_list_file)
#' @param dna_dendro_list_file A text file containing a list of sample files, one file name per line. Each file contains a matrix with variant allele frequency of all the variations in each tumor region and normal.
#' @example snv_heatmaps("~/input_files/dendro_inputs/DNA_dendro_list.txt")
#' @export
snv_heatmaps=function(dna_dendro_list_file){
file <- read.table(dna_dendro_list_file, header=F, sep="\n")
for (m in 1:length(file[,1])) 
{

x <- read.table(as.character(file[m,1]), header=T,sep="\t",stringsAsFactors=FALSE)

x1<-x[, which(names(x) != "N")]
x2<-melt(x1, id=c("coords"))
x3<-x2[x2$value != 0, ]
x4<-merge(x3, data.frame(table(coords = x3$coords)), by = c("coords"))
x5<-arrange(x4, Freq, value, variable)


tiff(filename=paste0("SNV_heatmap_",as.character(file[m,1]),".tiff"), height=8, width=8, res=300, units="in")
print(ggplot(x5,aes(variable, coords))+
     geom_tile(aes(fill = value))+ 
     scale_fill_gradient(low = "beige", high = "red") + 
     scale_y_discrete(limits=unique(x5$coords)) + 
     theme(axis.text.y = element_blank(), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank()))
dev.off()

}

}


############################################################################### Dendrograms #####################################################################
#' Creates DNA dendrogram
#' 
#' Takes in a text file containing list of sample files. Each file contains a matrix with variant allele frequency of all the variations in each tumor region and normal.
#' Creates a DNA distance matrix, containing the distance between all the tumor regions and normal, a DNA tree topology file, and an unrooted DNA dendrogram.
#' @usage dna_dendrograms(dna_dendro_list_file)
#' @param dna_dendro_list_file A text file containing a list of sample files, one file name per line. Each file contains a matrix with variant allele frequency of all the variations in each tumor region and normal.
#' @example dna_dendrograms(DNA_dendro_list.txt)
#' @export
dna_dendrograms=function(dna_dendro_list_file){
file <- read.table(dna_dendro_list_file)
for (m in 1:length(file[,1])) 
{

x <- read.table(as.character(file[m,1]), header=T,sep="\t",stringsAsFactors=FALSE)
x1<- x[,2:ncol(x)]
nCols=ncol(x1)
nRows=nrow(x1)
distMat=matrix(nrow=nCols,ncol=nCols)

for(i in 1:(nCols-1)){
    for(j in (i+1):nCols){
        d1=abs(x1[,i]-x1[,j])
#       k=sum(d1)
        k=sum(d1)/(2*nRows)
        distMat[i,j]=k
        distMat[j,i]=k
    }
}

dimnames(distMat) <- list(colnames(x1), colnames(x1))
diag(distMat) <- 0
tree <- nj(distMat)

write.table(distMat, file=paste0("DNA_distance_matrix_",as.character(file[m,1])), sep="\t", quote=F)
write.nexus(tree,file=paste0("DNA_tree_", as.character(file[m,1])))
tiff(filename=paste0("DNA_unrooted_dendrogram_",as.character(file[m,1]),".tiff"), height=8, width=8, res=300, units="in")
plot(tree, type="unrooted", main=as.character(file[m,1]), edge.width = 8, label.offset = 1.3, cex = 2)
dev.off()


}

}



# RNA Dendrograms
# ==============
#' Creates RNA dendrogram
#' 
#' Takes in a text file containing list of sample files. 
#' Creates a RNA distance matrix, containing the distance between all the tumor regions and normal, a RNA tree topology file, and a RNA unrooted dendrogram.
#' @usage rna_dendrograms(rna_phylo_list_file)
#' @param rna_dendro_list_file A text file containing a list of sample files, one file name per line. Each file contains a matrix with expression values (preferably log2(TPM+1)) of all the genes in each tumor region and normal.
#' @example rna_dendrograms(RNA_dendro_list.txt)
#' @export
rna_dendrograms=function(rna_dendro_list_file){
file <- read.table(rna_dendro_list_file)
for (m in 1:length(file[,1])) 
{
  
  x <- read.table(as.character(file[m,1]), header=T,sep="\t",stringsAsFactors=FALSE)
  x1<- x[,2:ncol(x)]
  nCols=ncol(x1)
  nRows=nrow(x1)
  distMat=matrix(nrow=nCols,ncol=nCols)
  
  for(i in 1:(nCols-1)){
    for(j in (i+1):nCols){
      d1=abs(x1[,i]-x1[,j])
      #       k=sum(d1)
      k=sum(d1)/(2*nRows)
      distMat[i,j]=k
      distMat[j,i]=k
    }
  }
  
  dimnames(distMat) <- list(colnames(x1), colnames(x1))
  diag(distMat) <- 0
  tree <- nj(distMat)
  
  write.table(distMat, file=paste0("RNA_distance_matrix_",as.character(file[m,1])), sep="\t", quote=F)
  write.nexus(tree,file=paste0("RNA_tree_", as.character(file[m,1])))
  tiff(filename=paste0("RNA_unrooted_dendrogram_",as.character(file[m,1]),".tiff"), height=8, width=8, res=300, units="in")
  plot(tree, type="unrooted", main=as.character(file[m,1]), edge.width = 8, label.offset = 1.3, cex = 2)
  dev.off()
  
  
}

}
 
# Immune Dendrograms
# =================
#' Creates Immune dendrogram
#' 
#' Takes in a text file containing list of sample files. 
#' Creates an immune distance matrix, containing the distance between all the tumor regions and normal, an immune tree topology file, and an unrooted phylogram.
#' @usage immune_dendrograms(immune_dendro_list_file)
#' @param immune_dendro_list_file A text file containing a list of sample files, one file name per line. Each file contains a matrix with proportion of immune cells (inferred by CIBERSORT) of all immune cell types in each tumor region and normal. 
#' @example immune_dendrograms(immune_dendro_list.txt)
#' @export
immune_dendrograms=function(immune_dendro_list_file){
file <- read.table(immune_dendro_list_file)
for (m in 1:length(file[,1])) 
{
  
  x <- read.table(as.character(file[m,1]), header=T,sep="\t",stringsAsFactors=FALSE)
  x1<- x[,2:ncol(x)]
  nCols=ncol(x1)
  nRows=nrow(x1)
  distMat=matrix(nrow=nCols,ncol=nCols)
  
  for(i in 1:(nCols-1)){
    for(j in (i+1):nCols){
      d1=abs(x1[,i]-x1[,j])
      #       k=sum(d1)
      k=sum(d1)/(2*nRows)
      distMat[i,j]=k
      distMat[j,i]=k
    }
  }
  
  dimnames(distMat) <- list(colnames(x1), colnames(x1))
  diag(distMat) <- 0
  tree <- nj(distMat)
  
  write.table(distMat, file=paste0("Immune_distance_matrix_",as.character(file[m,1])), sep="\t", quote=F)
  write.nexus(tree,file=paste0("Immune_tree_", as.character(file[m,1])))
  tiff(filename=paste0("Immune_unrooted_dendrogram_",as.character(file[m,1]),".tiff"), height=8, width=8, res=300, units="in")
  plot(tree, type="unrooted", main=as.character(file[m,1]), edge.width = 8, label.offset = 1.3, cex = 2)
  dev.off()
  
  
}

}



############################################################################### multi-level Divergence and diversity #####################################################################
#' Performs a multi-level divergence and diversity analysis
#' 
#' Takes in text file containing list of samples, one sample per line, and distance matrix files generated by dna_phylograms, rna_phylograms, and immune_phylograms methods.
#' Outputs a png file containing 6 plots, 3 diversity/divergence plots and 3 diversity plots.
#' NOTE: Requires output of functions dna_dendrograms, rna_dendrograms, and immune_dendrograms to be in same folder
#' @usage multi_level_divergence_diversity(sample_names_file)
#' @param sample_names_file A text file containing list of sample names, one file name per line
#' @example multi_level_divergence_diversity(sample_names.txt)
#' @export
multi_level_divergence_diversity=function(sample_names_file){
  dendrodist=c()
  divg.DNA=c()
  divs.DNA=c()
  divg.RNA=c()
  divs.RNA=c()
  divg.immune=c()
  divs.immune=c()
  sum.length.DNA=c()
  sum.length.RNA=c()
  sum.length.immune=c()
  
  
  samnames <- read.table(sample_names_file)
  
  dN_DNA=c()
  dN_RNA=c()
  dN_immune=c()
  dN_color=c()
  colz=c("brown3","darkgoldenrod3","darkgreen","deepskyblue","purple","hotpink")
  
  for(i in 1:length(samnames)) {
    dnafile=paste0("DNA_distance_matrix_DNA_",samnames[i,1], "_frequency_matrix.txt")
    rnafile=paste0("RNA_distance_matrix_",samnames[i,1],"_RNA_expression_matrix.txt")
    immunefile=paste0("Immune_distance_matrix_",samnames[i,1],"_Immune_CIBERSORT_matrix.txt")
    
    z1<-read.table(dnafile,sep="\t",skip=1,fill=TRUE,header=F)
    z2<-read.table(rnafile,sep="\t",skip=1,fill=TRUE,header=F)
    z3<-read.table(immunefile,sep="\t",skip=1,fill=TRUE,header=F)
    rownames(z1)=z1[,1]
    rownames(z2)=z2[,1]
    rownames(z3)=z3[,1]
    z1=z1[,-c(1)]
    z2=z2[,-c(1)]
    z3=z3[,-c(1)]
    
    tr1=nj(as.dist(z1))
    tr2=nj(as.dist(z2))
    tr3=nj(as.dist(z3))
    dendrodist=c(dendrodist,dist.topo(tr1,tr2, method="score"))
    print(tr1)
    print(tr2)
    print(tr3)
    
    divg.DNA=c(divg.DNA,tr1$edge.length[which(tr1$edge[,2]==match("N",tr1$tip.label))])
    sum.length.DNA=c(sum.length.DNA,sum(tr1$edge.length))
    divg.RNA=c(divg.RNA,tr2$edge.length[which(tr2$edge[,2]==match("N",tr2$tip.label))])
    sum.length.RNA=c(sum.length.RNA,sum(tr2$edge.length))
    divg.immune=c(divg.immune,tr3$edge.length[which(tr3$edge[,2]==match("N",tr3$tip.label))])
    sum.length.immune=c(sum.length.immune,sum(tr3$edge.length))
    
    
    dN_DNA=c(dN_DNA,t(z1["N",-c(length(z1[1,]))]))
    dN_RNA=c(dN_RNA,t(z2["N",-c(length(z2[1,]))]))
    dN_immune=c(dN_immune,t(z3["N",-c(length(z3[1,]))]))
    dN_color=c(dN_color,t(rep(colz[i],length(z3[1,])-1)))
  }
  
  
  divs.DNA=sum.length.DNA-divg.DNA
  divs.RNA=sum.length.RNA-divg.RNA
  divs.immune=sum.length.immune-divg.immune
  
  
  png(filename="png_multiomics_ITH_comparison.png", height=1200, width=760)
  par(mfcol=c(3,2))
  plot(divs.DNA/sum.length.DNA, divs.RNA/sum.length.RNA, xlim=c(0,1),ylim=c(0,1), pch=19, col=colz, las=1, cex=2.5, cex.axis=2, main="DNA: RNA divs/divg", ylab="")
  arrows(0,0,1,1, col="grey", length=0, lwd=1.5, lty=2)
  text(divs.DNA/sum.length.DNA+0.02, divs.RNA/sum.length.RNA+0.05,  cex=2, font=1)
  
  plot(divs.DNA/sum.length.DNA, divs.immune/sum.length.immune, xlim=c(0,1),ylim=c(0,1), pch=19, col=colz, las=1, cex=2.5, cex.axis=2, main="DNA: immune divs/divg", ylab="")
  arrows(0,0,1,1, col="grey", length=0, lwd=1.5, lty=2)
  text(divs.DNA/sum.length.DNA+0.04, divs.immune/sum.length.immune+0.04,  cex=2, font=1)
  
  plot(divs.RNA/sum.length.RNA, divs.immune/sum.length.immune, xlim=c(0,1),ylim=c(0,1), pch=19, col=colz, las=1, cex=2.5, cex.axis=2, main="RNA: immune divs/divg", ylab="")
  arrows(0,0,1,1, col="grey", length=0, lwd=1.5, lty=2)
  text(divs.RNA/sum.length.RNA-c(-0.04,0.04,0.04,0.04,0.04,0.04), divs.immune/sum.length.immune+0.04,  cex=2, font=1)
  
  plot(dN_DNA,dN_RNA, col=dN_color, las=1, main="dN_DNA:dN_RNA", xlab="DNA", ylab="", cex=2.5, cex.axis=2, pch=19)
  plot(dN_DNA,dN_immune, col=dN_color, las=1, main="dN_DNA:dN_immune", xlab="DNA", ylab="", cex=2.5, cex.axis=2, pch=19)
  plot(dN_RNA,dN_immune, col=dN_color, las=1, main="dN_RNA:dN_immune", xlab="RNA", ylab="", cex=2.5, cex.axis=2, pch=19)
  dev.off()
  
}



############################################################################### Signatures #####################################################################
# z-score calculations
# ====================
#' Generates a matrix containing z-scores
#' 
#' Takes in RNA expression matrix containing the expression level of all genes in all tumor samples and normals.
#' Creates a matrix(tab-delimited text file) containing z-scores for all genes in all of the tumor samples or regions and normals.
#' @usage z_score_calculations(rna_expression_matrix_file)
#' @param rna_expression_matrix_file File containing expression level of all genes in all tumor samples. Header of first column should be "Gene" and each normal file should end in ".nr"
#' @example z_score_calculations(RNA_matrix.txt)
#' @export 
z_score_calculations=function(rna_expression_matrix_file){
orimatrix=read.table(rna_expression_matrix_file, sep="\t", header=T)
nr_matrix=dplyr::select(orimatrix, ends_with(".nr"))
orimatrix=dplyr::select(orimatrix, -ends_with(".nr"))
names(orimatrix)[1]="Gene"
nr_matrix$Gene=orimatrix$Gene
nr_matrix=nr_matrix[c("Gene", setdiff(names(nr_matrix), "Gene"))]

# For normal file, find mean and standard deviation
Mean=rowMeans(nr_matrix[,2:ncol(nr_matrix)])
SD=rowSds(data.matrix(nr_matrix), cols=2:ncol(nr_matrix))
nr_matrix=cbind(nr_matrix,Mean,SD)
nmatrix=data.frame(nr_matrix$Gene, nr_matrix$Mean, nr_matrix$SD)
names(nmatrix)=c("Gene","Mean", "SD")

# Join normal file calculations to tumor matrix
orimatrix=dplyr::left_join(orimatrix, nmatrix, by="Gene")

# Find z-scores and make new file for output
zscore_matrix=data.frame(matrix(ncol=ncol(orimatrix)-2, nrow=nrow(orimatrix)))
zscore_matrix[,1]=orimatrix$Gene
names(zscore_matrix)[1]="Gene"
for(i in 2:(ncol(orimatrix)-2)){
  sample_name=colnames(orimatrix)[i]
  names(zscore_matrix)[i]=paste0(sample_name, ".")
  zscore_matrix[,i]=(orimatrix[,i]-orimatrix$Mean)/orimatrix$SD
}
write.table(zscore_matrix, "z-scores_matrix.txt", sep="\t", quote=F, row.names=F, col.names=T)

}

#Signatures for specified geneset
#==================
#' Runs a signature analysis using a user-supplied geneset
#' 
#' Takes in a z-score matrix created by function z_score_calculations and a geneset
#' Outputs a table of geneset scores and a geneset scores heatmap
#' @usage specified_geneset_signature(z_score_matrix_file, geneset)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @param geneset A text file containing a list of genes supplied by the user, one gene per line.
#' @example specified_geneset_signature(z_score_matrix.txt, proliferation_geneset.txt)
#' @export
specified_geneset_signature=function(z_score_matrix_file, geneset){
  x <- read.table(z_score_matrix_file, header=T, sep="\t")
  hyp <- read.table(geneset, header=T, sep="\t") 
  y<-inner_join(x,hyp, by="Gene")
  z<-colMeans(y[,2:ncol(y)])
  z2<-cbind(Gene="Geneset score", t(z))
  write.table(z2, "Geneset_score.txt", quote=F, sep="\t", row.names=F)
  
  x<-read.table("Geneset_score.txt", header=T, sep="\t")
  x1<-melt(x,id="Gene")
  tiff("Geneset_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
  print(ggplot(x1, aes(variable, Gene, fill=value))+ 
    geom_tile() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
    scale_fill_gradient(low = "white", high = "darkorchid4") + 
    coord_equal())
  dev.off()
  
}
# Hypoxia signature
# =================
#' Runs a hypoxia signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of hypoxia scores for each tumor sample or region and a heatmap of the hypoxia scores
#' @usage hypoxia_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example hypoxia_signature(z_score_matrix.txt)
#' @export
hypoxia_signature=function(z_score_matrix_file){
x <- read.table(z_score_matrix_file, header=T, sep="\t")
hyp <- metaITH:::hyppoxia_geneset 
y<-inner_join(x,hyp, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="Hypoxia score", t(z))
write.table(z2, "Hypoxia_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("Hypoxia_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("Hypoxia_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "darkorchid4") + 
  coord_equal())
dev.off()

}


# Proliferation signature
# =======================
#' Runs a proliferation signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of proliferation scores for each tumor sample or region and a heatmap of the proliferation scores
#' @usage proliferation_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example proliferation_signature(z_score_matrix.txt)
#' @export
proliferation_signature=function(z_score_matrix_file){
x <- read.table(z_score_matrix_file, header=T, sep="\t")
prol <- metaITH:::proliferation_geneset
y<-inner_join(x,prol, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="Proliferation score", t(z))
write.table(z2, "Proliferation_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("Proliferation_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("Proliferation_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "deeppink3") + 
  coord_equal())
dev.off()
}



# Apoptosis signature
# ===================
#' Runs an apoptosis signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of apoptosis scores for each tumor sample or region and a heatmap of the apoptosis scores
#' @usage apoptosis_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example apoptosis_signature(z_score_matrix.txt)
#' @export
apoptosis_signature=function(z_score_matrix_file){
x <- read.table(z_score_matrix_file, header=T, sep="\t")
apop <- metaITH:::apoptosis_geneset 
y<-inner_join(x,apop, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="Apoptosis score", t(z))
write.table(z2, "Apoptosis_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("Apoptosis_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("Apoptosis_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "deeppink3") + 
  coord_equal())
dev.off()

}


# Drug resistance signature
# =========================
drug_resistance_signature=function(z_score_matrix_file){
#' Runs a drug-resistance signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of drug-resistance scores for each tumor sample or region and a heatmap of the drug-resistance scores
#' @usage drug_resistance_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example drug_resistance_signature(z_score_matrix.txt)
#' @export  
x <- read.table(z_score_matrix_file, header=T, sep="\t")
resist <-metaITH:::pemetrexed_resistance_geneset
y<-inner_join(x,resist, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="Pemetrexed resistance score", t(z))
write.table(z2, "Pemetrexed_resistance_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("Pemetrexed_resistance_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("Pemetrexed_resistance_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "cyan3") + 
  coord_equal())
dev.off()

}


# EMT signature
# =============
emt_signature=function(z_score_matrix_file){
#' Runs an emt signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of emt(epithelial-mesenchymal transition) scores for each tumor sample or region and a heatmap of the emt scores
#' @usage emt_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example emt_signature(z_score_matrix.txt)
#' @export
x <- read.table(z_score_matrix_file, header=T, sep="\t")
epi <- metaITH:::epithelial_geneset 
y<-inner_join(x,epi, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="Epithelial score", t(z))

mesen <- metaITH:::mesenchymal_geneset
a<-inner_join(x,mesen, by="Gene")
b<-colMeans(a[,2:ncol(a)])
b2<-cbind(Gene="Mesenchymal score", t(b))

q <- rbind(z2,b2)
ME <- b-z
ME2 <- cbind(Gene="M-E score", t(ME))

write.table(q, "Epithelial_Mesenchymal_scores.txt", quote=F, sep="\t", row.names=F)
write.table(ME2, "Mesenchymal-Epithelial_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("Mesenchymal-Epithelial_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("Mesenchymal-Epithelial_score_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "yellow3") + 
  coord_equal())
dev.off()

}

# anti-PD1 favor signature
# ========================
#' Runs an anti-PD1 favor signature analysis
#' 
#' Takes in a z-score matrix created by function z_score_calculations
#' Outputs a table of anti-PD1 favor scores for each tumor sample or region and a heatmap of the anti-PD1 favor scores
#' @usage anti_pd1_favor_signature(z_score_matrix_file)
#' @param z_score_matrix_file A matrix of z-scores for all genes in all tumor samples and regions. Can be created using function z_score_calculations.
#' @example anti_pd1_favor_signature(z_score_matrix.txt)
#' @export
anti_pd1_favor_signature=function(z_score_matrix_file){
x <- read.table(z_score_matrix_file, header=T, sep="\t")
pd1 <- metaITH:::anti_PD1_favor_geneset 
y<-inner_join(x,pd1, by="Gene")
z<-colMeans(y[,2:ncol(y)])
z2<-cbind(Gene="anti-PD1 favor score", t(z))
write.table(z2, "anti-PD1_favor_score.txt", quote=F, sep="\t", row.names=F)

x<-read.table("anti-PD1_favor_score.txt", header=T, sep="\t")
x1<-melt(x,id="Gene")
tiff("anti-PD1_favor_scores_heatmap.tiff", units="in", height = 8, width = 8, res=300)
print(ggplot(x1, aes(variable, Gene, fill=value))+ 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size= 10),axis.text.y = element_text(size =10,color ="black"), plot.title = element_blank(),axis.title.x = element_blank(), axis.title.y = element_blank(), legend.position="bottom") + 
  scale_fill_gradient(low = "white", high = "darkgreen") + 
  coord_equal())
dev.off()

}


