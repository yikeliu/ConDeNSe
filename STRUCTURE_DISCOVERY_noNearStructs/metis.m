function [] = metis(path)

A = load(path);
if size(A,2) == 2
	A(:,3) = 1;
end
A = spconvert(A);
A = A+A';
A = A~=0;
A = A - diag(diag(A));
n = size(A,2);
cd metis-5.0.2/metismex;
make;
nclust = int32(sqrt(n/2));
map = metisdice(A,nclust);
cd ../..
[pathstr,name,ext] = fileparts(path);
dlmwrite(strcat(name,ext,'.metispart'),map);

end

