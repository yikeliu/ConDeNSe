function [] = spectral_fact(path)

addpath('graphpartition/')
A = load(path);
A = spconvert(A);
n = max(size(A,1),size(A,2));
A(n,n) = 0;
A = A+A';
A = A~=0;
A = A - diag(diag(A));
nclust = int32(sqrt(n/2));
map = grPartition(A,nclust);
[pathstr,name,ext] = fileparts(path);
dlmwrite(strcat(name,ext,'.spectralpart'),map);
copyfile( strcat(name,ext,'.spectralpart'), '../VariablePrecisionIntegers/VariablePrecisionIntegers/');

end
