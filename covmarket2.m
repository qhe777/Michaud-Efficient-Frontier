function  sigma = covmarket2( x )
% Ledoit covariance matrix
% Shrinke Sample Covariance Matrix



[t,n] = size(x);
meanx = mean(x);
x = x-meanx(ones(t,1),:); %remove mean
xmkt=mean(x')'; %weight_average return

sample = cov([x xmkt]); %n+1*n+1
covmkt = sample(1:n,n+1);
varmkt = sample(n+1,n+1);
sample(:,n+1)=[]; 
sample(n+1,:)=[]; % sample=cov(x)
prior = covmkt*covmkt'./varmkt; %prior(i,j)=cov(i,n+1)*cov(j,n+1)/var(n+1)
prior(logical(eye(n))) = diag(sample); %prior(i,i)=var(i)

d = 1/n*norm(sample-prior,'fro')^2;
y = x.^2;
r2 = 1/n/t^2*sum(sum(y'*y))-1/n/t*sum(sum(sample.^2));
phidiag = 1/n/t^2*sum(sum(y.^2))-1/n/t*sum(diag(sample).^2);
z = x.*xmkt(:,ones(1,n));
v1 = 1/t^2*y'*z-1/t*covmkt(:,ones(1,n)).*sample;
phioff1 = 1/n*sum(sum(v1.*covmkt(:,ones(1,n))'))/varmkt ...
    -1/n*sum(diag(v1).*covmkt)/varmkt;
v3 = 1/t^2*z'*z-1/t*varmkt*sample;
phioff3 = 1/n*sum(sum(v3.*(covmkt*covmkt')))/varmkt^2 ...
    -1/n*sum(diag(v3).*covmkt.^2)/varmkt^2;
phioff = 2*phioff1-phioff3;
phi = phidiag+phioff;

shrinkage = max(0,min(1,(r2-phi)/d));
sigma = shrinkage*prior+(1-shrinkage)*sample;
return


