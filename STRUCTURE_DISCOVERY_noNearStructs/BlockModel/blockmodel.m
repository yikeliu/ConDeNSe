function [] = blockmodel(path)

addpath('WSBM_v1.2/');
A = load(path);
A = spconvert(A);
n = max(size(A,1),size(A,2));
A(n,n) = 0;
A = A+A';
A = A~=0;
A = A - diag(diag(A));
nclust = double((int32(sqrt(sqrt(n/2))))^2);
map = wsbm(A, nclust, 'numTrials', 10);
[pathstr,name,ext] = fileparts(path);
dlmwrite(strcat(name,ext,'.blockmodelpart'),map);
%copyfile( strcat(name,ext,'.spectralpart'), '../VariablePrecisionIntegers/VariablePrecisionIntegers/');

end
