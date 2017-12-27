function [] = metis(path,destpath)

A = load(path);
if size(A,2) == 2
	A(:,3) = 1;
end
A = spconvert(A);
pSize=length(A);
%display(pSize);
if size(A,1) ~= pSize || size(A,2) ~= pSize
    A(pSize,pSize) = 0;
end
%display(size(A));
A = A+A';
A = A~=0;
A = A - diag(diag(A));
n = size(A,2);

%% install metismex
cd metis-5.1.0/metismex;
%make;
METIS_startup();

nclust = int32(sqrt(n/2));
map = PartSparseMat(A,nclust,1);
cd ../..;
[pathstr,name,ext] = fileparts(path);
dlmwrite(strcat(name,ext,'.metispart'),map);
copyfile(strcat(name,ext,'.metispart'),destpath);

%end

