clear; clc;

% set up the unmodified inps.
jobDef = '/home/xiaohan/abaqus/6.14-1/code/bin/abq6141 noGUI job=';
abaqusPath = '/home/xiaohan/Desktop/Temp/AbaqusModels';
inpNameUnmo = 'l9h2SingleInc_forceMod';
inpPathUnmo = [abaqusPath '/fixBeam/'];

% set up the output .dat file path, same path for all output files.
iterStr = '_iter';
datName = [inpNameUnmo iterStr];
inpPathMo = [abaqusPath '/iterModels/'];

% read the original unmodified .inp file.
inpTextUnmo = fopen([inpPathUnmo, inpNameUnmo, '.inp']);
rawInpStr = textscan(inpTextUnmo, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(inpTextUnmo);

% define the strings to find. 
fceStr = {'*Nset, nset=Set-af'; '*Nset, nset=Set-lc'; '*Amplitude'; ...
    '** MATERIALS'; '*Cload, amplitude'; '** OUTPUT REQUESTS'};

loc = zeros(length(fceStr), 1);

for iFce = 1:length(fceStr)
    
    loc(iFce) = find(strncmp(rawInpStr{1}, fceStr{iFce}, length(fceStr{iFce})));
    
end
