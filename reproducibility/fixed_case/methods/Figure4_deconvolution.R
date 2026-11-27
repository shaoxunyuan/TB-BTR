# Offline re-estimation from platform gene matrices, not CIBERSORT/CIBERSORTx.
# Weighted non-negative least squares; the stored platform profiles fail a
# near-rank-one diagnostic and are retained only for provenance/QC comparison.
reference_nnls <- function(expr, sig, mapping_path) {
 common <- intersect(rownames(expr),rownames(sig))
 if(length(common)<100)stop('Insufficient reference gene overlap')
 S<-sig[common,,drop=FALSE];E<-expr[common,,drop=FALSE]
 if(max(E,na.rm=TRUE)<50 && min(E,na.rm=TRUE)>=0) E<-2^E-1
 good<-apply(S,1,function(v)all(is.finite(v)))&apply(E,1,function(v)all(is.finite(v)))&rowSums(S)>0&rowSums(E)>0
 S<-S[good,,drop=FALSE];E<-E[good,,drop=FALSE]
 stopifnot(all(S>=0),all(E>=0))
 S<-sweep(S,2,colSums(S),'/');E<-sweep(E,2,colSums(E),'/')
 weight<-1/pmax(sqrt(rowMeans(S^2)),quantile(sqrt(rowMeans(S^2)),.10))
 A<-S*weight;Es<-E*weight
 norm<-sqrt(colSums(A^2));A<-sweep(A,2,norm,'/')
 results<-list();qc<-list()
 for(j in seq_len(ncol(E))){
  y<-Es[,j];AtA<-crossprod(A);Aty<-as.vector(crossprod(A,y))
  fn<-function(b) .5*sum((as.vector(A%*%b)-y)^2)
  gr<-function(b) as.vector(AtA%*%b)-Aty
  # Lawson-Hanson active-set NNLS; solve each active least-squares problem by QR.
  beta<-rep(0,ncol(A));active<-rep(FALSE,ncol(A));w<-Aty;iterations<-0
  while(any(!active&w>1e-8)){
   iterations<-iterations+1;if(iterations>ncol(A)*20)stop('NNLS active-set iteration limit')
   candidate<-which.max(ifelse(!active,w,-Inf));active[candidate]<-TRUE
   z<-rep(0,ncol(A));z[active]<-qr.solve(A[,active,drop=FALSE],y,tol=1e-10)
   while(any(z[active]<=0)){
    bad<-which(active&z<=0);alpha<-min(beta[bad]/(beta[bad]-z[bad]));beta<-beta+alpha*(z-beta)
    active[active&beta<1e-10]<-FALSE;z<-rep(0,ncol(A));if(any(active))z[active]<-qr.solve(A[,active,drop=FALSE],y,tol=1e-10)
   }
   beta<-z;w<-Aty-as.vector(AtA%*%beta)
  }
  fit<-list(par=beta,value=fn(beta),convergence=0)
  grad<-gr(fit$par);kkt<-max(abs(pmin(grad,0)),abs(grad[fit$par>1e-7]),0)
  if(fit$convergence!=0||kkt>1e-4)stop('NNLS convergence/KKT failure')
  b<-fit$par/norm;stopifnot(sum(b)>0);b<-b/sum(b);names(b)<-colnames(S)
  mapped<-.mc_apply_mapping(b,mapping_path)
  results[[j]]<-data.frame(SampleID=colnames(E)[j],t(mapped),check.names=FALSE)
  qc[[j]]<-data.frame(sample=colnames(E)[j],overlap_genes=nrow(S),convergence=fit$convergence,kkt=kkt,weighted_residual=sqrt(2*fit$value),fit_cor=cor(as.vector(S%*%b),E[,j]))
 }
 list(matrix=do.call(rbind,results),qc=do.call(rbind,qc))
}
