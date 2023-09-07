function [full_data,full_labels,fs,keep,times] = preprocess5(Info,chans_to_use)
global params
% read in a meta info item correspond to a file
% return the preprocessed data, labels, fs, new electrode Ind file, if keep
% this file, and other sample info
%% Add path to this codebase
% mname = mfilename('fullpath');
% [filedir, ~, ~] = fileparts(fileparts(mname));
% addpath(genpath(filedir))
% if ~exist('IEEGToolbox','dir')==7 || ~exist('tools','dir')==7
%     try
%         addpath(genpath(strcat(fileparts(filedir),'/matlab')))
%     catch ME
%         assert(exist('IEEGToolbox','dir')==7,'CNTtools:dependencyUnavailable','IEEGToolbox not imported.')
%         assert(exist('tools','dir')==7,'CNTtools:dependencyUnavailable','Tools not imported.')
%     end
% end
%% Read json login info
login = read_json(which('config.json'));
%% Get patient name
file_name = Info.filename;
ptname = Info.patient;
%% Download data from ieeg.org
% rand time
init_2pm = 14*3600-Info.startTime;
ind_2pms = init_2pm:24*3600:Info.duration;
ind_2pms(find(ind_2pms<1)) = [];
if isempty(ind_2pms)
    ind_2pms = randi([3601,floor(Info.duration)-3601],1);
end
ranges = [max(1,ind_2pms'-3600),min(ind_2pms'+3600,floor(Info.duration)-120)]; % 1-3 pm index
nSession = size(ranges,1);
% get chans
selecElecs = eval(['Info.chan_',chans_to_use]);
% fetch data
full_data = {};
for i = 1:params.nSeg
    time = randi(ranges(randi(min(nSession,3)),:),1);
    time = [time,time+120];
    disp(time)
    data = get_ieeg_data(file_name, login.usr, login.pwd, time,'selecElecs',selecElecs);
    bad = identify_bad_chs(data.values,data.fs);
    percent = sum(bad)/size(data.values,2);
    count = 0;
    while percent >= 0.2 && count < 10
        tmp_time = randi(ranges(randi(min(nSession,3)),:),1);
        tmp_time = [tmp_time,tmp_time+120];
        % time for different 2pm
        tmp = get_ieeg_data(file_name, login.usr, login.pwd, tmp_time,'selecElecs',selecElecs);
        tmpBad = identify_bad_chs(tmp.values,tmp.fs);
        percentBad = sum(tmpBad)/size(data.values,2);
        if percentBad < percent
            data = tmp;
            percent = percentBad;
            time = tmp_time;
        end
        count = count + 1;
    end
    full_data{i} = data;
    times(i,:) = time;
end
fs = full_data{1}.fs;
full_labels = {};
keep = [];
for i = 1:params.nSeg
    % Identify bad channels
    labels = full_data{i}.chLabels; 
    values = full_data{i}.values;
    [bad,~] = identify_bad_chs(values,fs);
    % Notch Filter
    values = notch_filter(values,fs);
    if chans_to_use == 'LR'
        % find bad channels, set the ind in elecInd to 0
        num_chan = length(labels);
        % update labels
        badLeft = bad(1:num_chan/2);
        badRight = bad(num_chan/2+1:end);
        badFull = badLeft | badRight;
        badFull = [badFull;badFull];
        newlabels = labels(~badFull);
        values = values(:,~badFull);
    else
        % clean channs
        newlabels = labels(~bad);
        values = values(:,~bad);
    end
    keep(i) = 1;
    if isempty(newlabels)
        keep(i) = 0;
    end
    full_data{i} = values;
    full_labels{i} = newlabels;
end
keep = any(keep);
