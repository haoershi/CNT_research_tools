function output = get_elec_locs(chLabels,filename)
% Get electrode locations for specified channel labels from a file.

% Parameters:
% - chLabels (cell array): Channel labels for which to retrieve electrode locations.
% - filename (string, char): Path to the file containing electrode locations.

% Returns:
% - output (matrix): Matrix containing electrode locations corresponds to channel labels.
%                        Unavailable channel locations filled with nan.

% Example:
% chLabels = {'Fp1', 'Fp2', 'C3', 'C4'};
% filename = 'electrode_locations.csv';
% output = get_elec_locs(chLabels, filename);

p = inputParser;
addRequired(p, 'chLabels', @(x) iscell(x) || isstring(x) || ischar(x));
addRequired(p, 'filename', @(x) (isstring(x) || ischar(x)) && exist(x,'file') == 2);
parse(p, chLabels, filename);
chLabels = p.Results.chLabels;
filename = p.Results.filename;

if ~iscell(chLabels)
    try
        chLabels = cellstr(chLabels); 
    catch ME
        throw(MException('CNTtools:invalidInputType','Electrode labels should be a cell array.'))
    end
end

elec_locs = table2cell(readtable(filename));
% clean both
labels = clean_labels(elec_locs(:,1));
chLabels = clean_labels(chLabels);

[Lia,locb] = ismember(chLabels,labels);
output = nan(size(chLabels,1),size(elec_locs,2)-1);
output(Lia,:) = cell2mat(elec_locs(locb(Lia),2:end));
% output = chLabels;
% output = [output,num2cell(output_data)];

