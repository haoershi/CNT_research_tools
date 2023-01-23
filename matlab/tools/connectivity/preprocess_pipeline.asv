function [show_values,show_labels,fs] = preprocess_pipeline(file_name,times,reference)

%% Add path to this codebase
addpath(genpath('./../..'))
assert(exist('IEEGToolbox','dir')==7,'CNTtools:dependencyUnavailable','IEEGToolbox not imported.')
assert(exist('tools','dir')==7,'CNTtools:dependencyUnavailable','Tools not imported.')

%% Read json login info
fname = '../../config.json';
login = read_json(fname);

%% Clip parameters
which_reference = reference;

%% Get patient name
ptnameC = strsplit(file_name,'_');
name = ptnameC{1}; 

%% Download data from ieeg.org
data = download_ieeg_data(file_name, login.usr, login.pwd, times);
oldLabels = data.chLabels; 
old_values = data.values;
fs = data.fs;

%% Decompose labels
[labels,elecs,numbers] = decompose_labels(oldLabels);%,name); 

%% Select Electrodes
keepElecs = [];
REGION = {'A','B','C'};
HEMI = {'L','R'};
for i = 1:length(HEMI)
    for j = 1:length(REGION)
        index = find(strcmp(labels,strcat([HEMI{i},REGION{j},'1'])));
        keepElecs = [keepElecs index:index+11];
    end
end
old_values = old_values(:,keepElecs);
labels = labels(keepElecs);
elecs = elecs(keepElecs);
numbers = numbers(keepElecs);
nchs = size(old_values,2);

%% Identify bad channels
bad = identify_bad_chs(old_values,fs);
%bad = logical(zeros(nchs,1)); % Uncomment this to see what happens if you
%don't remove bad channels!

%% Notch Filter
old_values = notch_filter(old_values,fs);

%% Common average reference (include only intra-cranial)
old_labels = labels;
switch which_reference
    case 'car'
        [values,labels] = common_average_reference(old_values,~bad,labels);
    case 'bipolar'
        [values,~,labels,chs_in_bipolar] = bipolar_montage(old_values,labels,[],[]);
        bad_ref = any(ismember(chs_in_bipolar,find(bad)),2);
    case 'laplacian'
        radius = 50;
        [values,close_chs,labels] = laplacian_reference(...
            old_values,~bad,locs,radius,labels);        
end

%% Remove bad channels
switch which_reference
    case 'car'
        show_values = values(:,~bad);
        show_labels = labels(~bad);
    case 'bipolar'
        show_values = values(:,~bad_ref);
        show_labels = labels(~bad_ref);
    case 'laplacian'
        show_values = values(:,~bad);
        show_labels = labels(~bad);
end

%% Pre-whiten data
%whitened_values = pre_whiten(show_values);

end
