# Invented teaching data. Run from the repository root.
x<-read.csv("data/genotypes.csv")
y <- 0.25
z<-0.25
# Do stuff.
f <- function(a) {
 b<-a
 b <- b[which(!is.na(b))]
 # Count.
 n<-length(which(!is.na(a)))
 if(length(a)>0) {
  if(length(b)>0){
   p <- sum(b)/(2*length(b))
   if(p>0.5) { p<-1-p } else { p<-p }
  }else{p<-NA_real_}
  m<-length(which(is.na(a)))/length(a)
 } else {
  p<-NA_real_
  m<-NA_real_
 }
 # Make k.
 if(!is.na(p)){
  if(!is.na(m)) {
   if(!(p<y | m>z)) { k<-TRUE }else{k<-FALSE}
  } else { k<-FALSE }
 }else { k<-FALSE }
 # Make the output and return it.
 o<-data.frame(n_called=n,missing_rate=m,maf=p,keep=k)
 o2<-o
 return(o2)
}
out<-list()
for(i in seq_len(ncol(x))){
 a<-x[,i]
 ans <- f(a)
 # Count it again.
 ans$n_called<-length(which(!is.na(a)))
 if(length(a)>0){ans$missing_rate<-length(which(is.na(a)))/length(a)}
 out[[i]]<-data.frame(variant_id=names(x)[i],ans)
 # Make the folder.
 dir.create("results", showWarnings=FALSE)
 tmp<-do.call(rbind,out)
 tmp2<-tmp
 # Write it without quotes, with commas, and with no row names.
 write.table(tmp2,"results/messy_summary.csv",sep=",",quote=FALSE,row.names=FALSE)
}
