function [show_values,show_labels,fs] = preprocess_pipeline(file_name,times,reference,selecElecs)

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
data = download_ieeg_data(file_name, login.usr, login.pwd, times,'selecElecs',selecElecs);
labels = data.chLabels; 
values = data.values;
fs = data.fs;
nchs = size(values,2);
%% Decompose labels
%[labels,elecs,numbers] = decompose_labels(oldLabels);%,name); 

%% Identify bad channels
bad = identify_bad_chs(values,fs);
%bad = logical(zeros(nchs,1)); % Uncomment this to see what happens if you
%don't remove bad channels!

%% Notch Filter
values = notch_filter(values,fs);

%% Common average reference (include only intra-cranial)
switch which_reference
    case 'car'
        [values,labels] = common_average_reference(values,~bad,labels);
    case 'bipolar'
        [values,~,labels,chs_in_bipolar] = bipolar_montage(values,labels,[],[]);
        bad_ref = any(ismember(chs_in_bipolar,find(bad)),2);      
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
