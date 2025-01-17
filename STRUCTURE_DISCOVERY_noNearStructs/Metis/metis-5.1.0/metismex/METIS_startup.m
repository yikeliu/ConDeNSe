function METIS_startup()
% METIS_STARTUP  Startup file for MetisMex
%   MAKE adds paths of the MetisMex to Matlab.
%

%   Copyright (c) 2015 Yingzhou Li, Stanford University

file_path = mfilename('fullpath');
tmp = strfind(file_path,'METIS_startup');
file_path = file_path(1:(tmp(end)-1));
addpath([file_path 'src']);
addpath([file_path 'build/mex']);

end
