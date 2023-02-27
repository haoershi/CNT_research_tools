function [values,newlabels,fs,newInd,keep] = preprocess(file_name,selecElecs,elecmat)
%%
% [filedir, ~, ~] = fileparts(mfilename('fullpath'));
% basedir = strsplit(filedir,'/');
%% Add path to this codebase
addpath(genpath('./../..'))
assert(exist('IEEGToolbox','dir')==7,'CNTtools:dependencyUnavailable','IEEGToolbox not imported.')
assert(exist('tools','dir')==7,'CNTtools:dependencyUnavailable','Tools not imported.')

%% Read json login info
login = read_json(which('config.json'));
%% Get patient name
ptnameC = strsplit(file_name,'_');
name = ptnameC{1}; 

%% Download data from ieeg.org
times = [20000,20060];
data = get_ieeg_data(file_name, login.usr, login.pwd, times,'selecElecs',selecElecs);
bad = identify_bad_chs(data.values,data.fs);
percent = sum(bad)/size(data.values,2);
count = 0;
while percent>=0.2 && count < 10
    try
        times = times+5000;
        tmp = get_ieeg_data(file_name, login.usr, login.pwd, times,'selecElecs',selecElecs);
        tmpBad = identify_bad_chs(tmp.values,tmp.fs);
        percentBad = sum(tmpBad)/size(data.values,2);
        disp(percentBad)
        if percentBad < 0.2
            data = tmp;
            percent = percentBad;
        elseif percentBad < percent
            data = tmp;
            percent = percentBad;
        end
        count = count + 1;
    catch ME
        break
    end
end
labels = data.chLabels; 
values = data.values;
fs = data.fs;
nchs = size(values,2);
%% Identify bad channels
[bad,~] = identify_bad_chs(values,fs);
%bad = logical(zeros(nchs,1)); % Uncomment this to see what happens if you
%don't remove bad channels!

%% Notch Filter
values = notch_filter(values,fs);

%% clean channs
[values,newlabels,newInd,keep] = updateLabel(values,labels,~bad);
end
