function data = download_ieeg_data(fname, login_name, pwfile, run_times, extras)

% This function download data from ieeg portal with filename, time range,
% and user information provided
% Inputs:
%       fname: name of to be downloaded file
%       login_name: user name of ieeg portal account
%       pwfile: password file of ieeg portal account
%       run_times: time range of to be pulled data within file, in seconds
%       extras: whether to assign other data attributes to output var
% Output:
%       data: a struct of field 'fs', 'values', 'file_name', 'chLabels',
%       'duration', and 'ann'

%% Added 11/12, Haoer
% think if need test for login file, lack no meta data version check

% Assert input type
assert((isstring(fname) || ischar(fname)),'CNTtools:invalidInputType','Invalid input type.')
assert(isa(run_times,'numeric'),'CNTtools:invalidInputType','Invalid input type.')

% remove potential blanks/quotes
fname = strip(fname);
fname = strip(fname,'"');
fname = strip(fname,"'");

% If with meta data file, metaData can be fetched through the tool/fetch_metadata 
% function, don't know how to effectively fetch yet
if exist('meta_data.csv')
    
    % Import metaData
    metaData = readtable('meta_data.csv','Delimiter',',','Format','auto');% read meta data
    
    % test if filename valid, obtain other info from metadata
    assert(ismember(fname,metaData.filename),'CNTtools:invalidFileName','Invalid filename.')
    cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    assert(~isempty(metaData.chans{cellfun(cellfind(fname),metaData.filename)}),'CNTtools:emptyFile','No channels.')
    dura = metaData.duration(cellfun(cellfind(fname),metaData.filename));

else
    % without meta data file, in case ob different data base
    try
        session = IEEGSession(fname, login_name, pwfile); % check if can fetch this file
        assert(~isempty(session.data.channelLabels),'CNTtools:emptyFile','No channels.'); % check file is not empty
        dura = session.data.rawChannels(1).get_tsdetails.getDuration/1e6;  % get duration info
        % Delete session
        session.delete;
        clearvars -except data
    catch ME
        throw(MException('CNTtools:failedFetch','Invalid filename or login info.'));
    end
end

% test if time range valid
assert(run_times(2) > run_times(1),'CNTtools:invalidTimeRange','Stop before start.')
assert(run_times(1) >= 0 && run_times(2) <= dura, 'CNTtools:invalidTimeRange', 'Time outrange.')


% -----end of added code-----

%% original code

attempt = 1;

% Wrap data pulling attempts in a while loop
while 1
    
    try
        session = IEEGSession(fname, login_name, pwfile);
        channelLabels = session.data.channelLabels;
        nchs = size(channelLabels,1);

        % get fs
        data.fs = session.data.sampleRate;

        % Convert times to indices
        run_idx = round(run_times(1)*data.fs):round(run_times(2)*data.fs);

        if ~isempty(run_idx)
            % Break the number of channels in half to avoid wacky server errors
            values1 = session.data.getvalues(run_idx,1:floor(nchs/4));
            values2 = session.data.getvalues(run_idx,floor(nchs/4)+1:floor(2*nchs/4));
            values3 = session.data.getvalues(run_idx,floor(2*nchs/4)+1:floor(3*nchs/4)); 
            values4 = session.data.getvalues(run_idx,floor(3*nchs/4)+1:nchs); 

            values = [values1,values2,values3,values4];
        else
            values = [];
        end

        data.values = values;

        if extras == 1

            % get file name
            data.file_name = session.data.snapName;

            % Get ch labels
            data.chLabels = channelLabels;

            % get duration (convert to seconds)
            data.duration = session.data.rawChannels(1).get_tsdetails.getDuration/1e6;

            % Get annotations
            n_layers = length(session.data.annLayer);

            for ai = 1:n_layers
                a=session.data.annLayer(ai).getEvents(0);
                n_ann = length(a);
                for i = 1:n_ann
                    event(i).start = a(i).start/(1e6);
                    event(i).stop = a(i).stop/(1e6); % convert from microseconds
                    event(i).type = a(i).type;
                    event(i).description = a(i).description;
                end
                ann.event = event;
                ann.name = session.data.annLayer(ai).name;
                data.ann(ai) = ann;
            end 

        end
        
        % break out of while loop
        break
        
    % If server error, try again (this is because there are frequent random
    % server errors).
    catch ME
        if contains(ME.message,'503') || contains(ME.message,'504') || ...
                contains(ME.message,'502') || contains(ME.message,'500')
            attempt = attempt + 1;
            fprintf('Failed to retrieve ieeg.org data, trying again (attempt %d)\n',attempt); 
        else
            ME
            error('Non-server error');
            
        end
        
    end
end

%% Delete session
session.delete;
clearvars -except data

end