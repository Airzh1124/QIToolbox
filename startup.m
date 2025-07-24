% Add QIToolbox source and examples independent of the current directory.
rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir, 'src')));
addpath(genpath(fullfile(rootDir, 'examples')));
disp('QIToolbox paths loaded.');