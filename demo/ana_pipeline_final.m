%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis Pipeline for                            %
% Re-reference and Connectivity Methods Evaluation % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This pipeline conducted a thorough evaluation of various re-reference and 
% connectivity methouds. The results may offer suggestions and recommendations 
% for method selection. 
% 
% Specific evaluation aspects include:
% Method similarity 
% Spurious correlation
% Sensitivity to electrode removal
% SOZ lateralization
%
% Table of Contents
% 0 | Settings 🤖
% 1 | Download Data ⬇️
% 2 | Re-ref and Calculate Connectivity 🔣 
% 3 | Methods Similarity 🔍
% 4 | Spurious correlation 📈
% 5 | Sensitivity to electrode removal 📉
% 6 | SOZ lateralization 🧠

%% set path
filename = which('ana_pipeline_final.m');
[filedir, ~, ~] = fileparts(filename);
cd(filedir);
addpath(genpath('.')); % this should add analysis and matlab folder
addpath(genpath(['..',filesep,'matlab'])); % this should add analysis and matlab folder
%% 0 | Settings 🤖
% This part finish the basic setting for the pipeline, including 
% select the methods to be evaluated and the dataset to use.

% initialize params
global params
% 🟡ref
allRefMethods = {'car','bipolar','laplacian'}; 
allRefSymbols = {'CAR','BR','LAPR'};
allRefNames = {'Common average re-referencing', 'Bipolar re-referencing','Laplacian re-referencing'};
params.refMap = containers.Map(allRefMethods, {@car, ...
                                        @bipolar, ...
                                        @laplacian});
allRefCols = hex2rgb({'#51b8bd','#de7862','#63804f'});
ifRef = logical([1, 1, 0]); % <- make change here
params.refMethods = allRefMethods(ifRef);
params.refSymbols = allRefSymbols(ifRef);
params.refNames = allRefNames(ifRef);
params.nRef = length(find(ifRef));
params.refCols = allRefCols(ifRef,:);
clear allRefMethods allRefSymbols allRefNames allRefCols ifRef
% 🟡conn
allConnMeasures = {'pearson','squaredPearson','crossCorr','coh','plv','relaEntropy'};
allConnSymbols = {'Pearson','SquareP','CrossCorr','COH','PLV','RE'};
allConnMeasureNames = {'Pearson','Squared Pearson','Cross Corr','Coherence','PLV','Relative Entropy'};
params.connMap = containers.Map(allConnMeasures, {@new_pearson_calc, ...
                                           @new_pearson_calc, ...
                                           @cross_correlation, ...
                                           @faster_coherence_calc, ...
                                           @plv_calc, ...
                                           @relative_entropy});
allConnCols = hex2rgb({'#B4CE99','#789264','#506D31',...
    '#E59595','#A5474E','#3C5488'});
ifConn = logical([1, 1, 1, 1, 1, 1]); % <- make change here
params.connMeasures = allConnMeasures(ifConn);
params.connSymbols = allConnSymbols(ifConn);
params.connMeasureNames = allConnMeasureNames(ifConn);
params.nConn = length(find(ifConn));
params.connCols = allConnCols(ifConn,:);
numFeats = [1,1,1,7,7,7];
params.numFeats = numFeats(ifConn);
params.nMethod = params.nRef*sum(params.numFeats);
clear allConnMeasures allConnSymbols allConnMeasureNames allConnCols ifConn numFeats
% 🟡freq
params.freqBands = {'\delta','\theta','\alpha','\beta','\gamma','Ripple','Broad'};
params.freqBandNames = {'Delta','Theta','Alpha','Beta','Gamma','Ripple','Broad'};
params.nFreq = length(params.freqBands);

% build method list
longConnNames = {};shortConnNames = {};
for i = 1:params.nConn
    if params.numFeats(i) == 1
        longConnNames = [longConnNames, params.connMeasureNames(i)];
        shortConnNames = [shortConnNames, params.connSymbols(i)];
    elseif params.numFeats(i) == params.nFreq
        tmpShort = strcat(params.connSymbols(i),{'-'},params.freqBandNames);
        tmpLong = strcat(params.connMeasureNames(i),{'-'},params.freqBandNames);
        longConnNames = [longConnNames, tmpLong];
        shortConnNames = [shortConnNames, tmpShort];
    end
end
shortNames = [];longNames = [];
for i = 1:params.nRef
    shortNames = [shortNames,strcat(params.refSymbols{i},'-',shortConnNames)];
    longNames = [longNames,strcat(params.refNames{i},'-',longConnNames)];
end
params.shortList = shortNames;
params.longList = longNames;
clear longConnNames shortConnNames tmpShort tmpLong shortNames longNames

% 🟡num segments
params.nSeg = 5; % <- make change here
% 🟡dataset
allDataset = {'HUP','MUSC'};
params.dataset = 'HUP'; % <- make change here
if exist(params.dataset,'dir') == 0
    mkdir(params.dataset);
end
params.chans_to_use = 'gw'; % <- make change here, options gw, gray, white, LR
clear allDataset

% print some basic characteristics
fprintf('There are:\n');
fprintf('%d Re-ref methods ✖ %d Connectivity Mesures\n',params.nRef,params.nConn)
fprintf('Due to calculation over different frequency bands,\n')
fprintf('The %d Connectivit Measures translates to %d total methods\n',params.nConn,sum(params.numFeats))

% 🟡paths
global paths
paths.resultDir = strcat(params.dataset,filesep,params.chans_to_use);
paths.rawPath = strcat(paths.resultDir,filesep,'raw');
paths.resultPath = strcat(paths.resultDir,filesep,'result');
paths.dataPath = strcat(paths.resultDir,filesep,'data');
paths.figPath = strcat(paths.resultDir,filesep,'figs');
paths.MLPath = strcat(paths.resultDir,filesep,'ML');
for path = struct2cell(paths)'
    if exist(path{1},'dir') == 0
        mkdir(path{1});
    end
end
addpath(genpath(params.dataset));
clear path

% Dataset processing
% Create a patientList file containing selected patients, if not already
% exising

% Set to true if want to force redownload data.
params.force_download = false;
% Set to true if allow use of downloaded data
params.use_exist_data = true;

if exist(strcat(paths.resultDir,filesep,'patientList.mat'),'file') == 2
    % indicates have run before
    load(strcat(paths.resultDir,filesep,'patientList.mat'));
    numFile = length(patientList);
else
    if exist(strcat('meta',filesep,params.dataset,'_subMeta.mat'),'file') ~= 2
        % haven't run before
        select_chan(params.dataset);
    else
        load(strcat('meta',filesep,params.dataset,'_subMeta.mat'));
        numFile = length(patientList);
    end
end

if (strcmp(params.chans_to_use,'gray') || strcmp(params.chans_to_use,'white')) && params.use_exist_data
    path_gw = strcat(params.dataset,filesep,'gw');
    path_gw_raw = strcat(path_gw,filesep,'raw');
    if exist(path_gw_raw) == 7 && length(dir(path_gw_raw)) > 2 
        paths.rawPath = path_gw_raw;
        load(strcat(path_gw,filesep,'patientList.mat'))
        numFile = length(patientList);
        fprintf('There are %d unique patients included\n',numFile);
    else
        fprintf('Please run gw from section 1 to use data!\n')
    end
end

% colors/figs setting
params.darkCols = hex2rgb({'#3c5488','#a5474e','#367068'}); % blue, red, green
params.lightCols = hex2rgb({'#51b8bd','#de7862','#63804f'});
params.font = 'Calibri';
params.fontsize = 16;

%% 1 | Download Data ⬇️
% This part downloads data clips from the specified dataset and 
% finish initial pre-processing, including bad-channel rejection 
% and notch filtering. This step can be skipped if the data were 
% already downloaded.
if params.force_download
    load(strcat('meta',filesep,params.dataset,'_subMeta.mat'));
    numFile = length(patientList);
end
keepPatient = zeros(numFile,1);
patients = {patientList.patient};
if length(dir(paths.rawPath)) <= 2 || params.force_download
    bar = waitbar(0, 'Processing...');
    for i = 1:numFile 
        waitbar(i/numFile, bar, sprintf('Processing %d of %d...', i, numFile));
        % skip the file if don't have file start time
        if isnan(patientList(i).ind_2pm) || isempty(eval(['patientList(i).chan_',params.chans_to_use]))
            continue
        else
            % start from the first file available
            if patientList(i).fileNo == 1
                patient = patientList(i).patient;
                fileInds = find(cellfun(@(x) strcmp(x,patient),patients));
                nFile = length(fileInds);
                for k = 1:nFile
                    [data,labels,fs,keepPatient(fileInds(k)),times] = preprocess5(patientList(fileInds(k)),params.chans_to_use);
                    if keepPatient(fileInds(k)) ~= 0
                        patientList(fileInds(k)).time = times;
                        save(strcat(paths.rawPath,filesep,'',patient,'.mat'),'data','labels','fs','times')
                        break
                    end
                end
            end
        end
        patientList(i).keep = keepPatient(i);
    end
    close(bar);
    patientList(~keepPatient) = [];
    patients = {patientList.patient};
    [~,idx] = sort(patients);
    patientList = patientList(idx);
    save(strcat(paths.resultDir,filesep,'patientList.mat'),'patientList');
    numFile = length(patientList);
    fprintf('There are %d unique patients included\n',numFile);
else
    fprintf('Data already downloaded\n');
    fprintf('Set force download to true to redownload\n')
end
clearvars -except numFile patientList params paths 
%% 2 | Re-ref and Calculate Connectivity 🔣 
% This part conduct re-ref processing and calculate connectivity 
% for all methods.
% connectivity parameters
do_tw = true;
tw = 2; % time windown in sec
bar = waitbar(0, 'Processing...');
for i = 2% 1:numFile
    waitbar(i/numFile, bar, sprintf('Processing %d of %d...', i, numFile));
    filename = strcat(paths.rawPath,filesep,'',patientList(i).patient,'.mat');
    if exist(filename,'file')
        load(filename)
    end
    data_full = data;
    label_full = labels;
    for n = 1:params.nSeg
        data = data_full{n};
        labels = label_full{n};
        % additional step to select only gray/white electrodes
        if strcmp('gray',params.chans_to_use) || strcmp('white',params.chans_to_use)
            ind = ismember(labels,clean_labels(eval(['patientList(i).chan_',params.chans_to_use])));
            data = data(:,ind);
            labels = labels(ind);
        end
        % end of additional step
        nchan = size(data,2);
        if strcmp('LR',params.chans_to_use)
            results = NaN(params.nRef,sum(params.numFeats),36,36,2);
        else
            results = NaN(params.nRef,sum(params.numFeats),nchan,nchan);
        end
        for j = 1:params.nRef
            func = params.refMap(params.refMethods{j});
            [values,newlabels] = func(data,labels);
            ind = ~cellfun(@(x) strcmp(x,'-'),newlabels);
            newlabels = cellfun(@(x) x(1:regexp(x,'-')-1),newlabels,'UniformOutput',false);
            if strcmp('LR',params.chans_to_use)
                newlabels = newlabels(ind);
                values = values(:,ind);
                half = size(values,2)/2;
                toFill = get_ind(newlabels(1:half));
                leftData = values(:,1:half);
                rightData = values(:,half+1:end);
                for k = 1:params.nConn
                    func = params.connMap(params.connMeasures{k});
                    out = NaN(36,36,params.numFeats(k),2);
                    out(toFill,toFill,:,1) = func(leftData,fs,tw,do_tw);
                    out(toFill,toFill,:,2) = func(rightData,fs,tw,do_tw);
                    results(j,sum(params.numFeats(1:k-1))+1:sum(params.numFeats(1:k-1))+params.numFeats(k),:,:,:) = permute(out,[3,1,2,4]);
                end
                tmp = false(36,1);
                tmp(toFill) = true;
                full_ind{j} = tmp;
            else
                toFill = find(ind);
                values = values(:,toFill);
                for k = 1:params.nConn
                    func = params.connMap(params.connMeasures{k});
                    out = NaN(nchan,nchan,params.numFeats(k));
                    out(toFill,toFill,:) = func(values,fs,tw,do_tw);
                    results(j,sum(params.numFeats(1:k-1))+1:sum(params.numFeats(1:k-1))+params.numFeats(k),:,:) = permute(out,[3,1,2]);
                end
                full_ind{j} = ind;
            end
        end
        save(strcat(paths.resultPath,filesep,'',patientList(i).patient,'_',num2str(n),'.mat'),'results','full_ind');
    end
end
close(bar);
fprintf('Finished calculation\n');
clearvars -except numFile patientList params paths 
%% 3 | Methods Similarity 🔍
% This part evaluate which methods are more similar to each other
% calculate measure correlation
% load results
filelist = dir(paths.resultPath);
isdir = [filelist.isdir];
filelist(isdir) = [];
filelist(cellfun(@(x) strcmp(x,'.DS_Store'),{filelist.name})) = [];
numFile = length(filelist);
% patient list
patients = {filelist.name}';
patients = cellfun(@(x) x(1:end-4),patients,'UniformOutput',false);
networkCorr = [];
nodeCorr = [];
globalStr = [];
for i = 1:numFile
    % for each patient, reshape
    load(strcat(paths.resultPath,filesep,'',filelist(i).name))
    nchan = size(results,3);
    ind = find(triu(ones(nchan,nchan),1)); 
    nodeStr = NaN(params.nMethod,nchan);
    if strcmp(params.chans_to_use,'LR')
        results = permute(results,[2,1,3,4,5]);
        results = reshape(results,[params.nMethod,36,36,2]);
        tmpNet = reshape(results,[params.nMethod,36*36,2]);
        tmpNet = tmpNet(:,ind,:);
        tmpNet = reshape(tmpNet,[params.nMethod,length(ind)*2]);
        % node level
        for j = 1:nchan
            nodeStr(:,j,1) = nanmean(results(:,j,[1:(j-1),(j+1):end],1),3);
            nodeStr(:,j,2) = nanmean(results(:,j,[1:(j-1),(j+1):end],2),3);
        end
        nodeStr = reshape(nodeStr,[params.nMethod,36*2]); 
    else
        results = permute(results,[2,1,3,4]);
        results = reshape(results,[params.nMethod,nchan,nchan]);
        %  network level
        tmpNet = reshape(results,[params.nMethod,nchan*nchan]);
        tmpNet = tmpNet(:,ind,:);
        % node level
        for j = 1:nchan
            nodeStr(:,j) = nanmean(results(:,j,[1:(j-1),(j+1):end]),3);
        end
    end
    networkCorr(i,:,:) = corrcoef(tmpNet','Rows','complete');
    nodeCorr(i,:,:) = corrcoef(nodeStr','Rows','complete');
    % global level
    globalStr(:,i) = nanmean(nodeStr,2);
end
globalCorr = corrcoef(globalStr','Rows','complete');
save(strcat(paths.dataPath,filesep,'corrs.mat'),'networkCorr','nodeCorr','globalStr','globalCorr','patients')
clearvars -except numFile patientList params paths 
%% plot for section 3
% Run this part if you would like to generate plots for section 3.
 
% load results
if exist(strcat(paths.dataPath,filesep,'corrs.mat'),'file') ~= 2
    error('No results file exist, please make sure to run section 3.')
else
    load(strcat(paths.dataPath,filesep,'corrs.mat'));
end

% clustering plot
plot_clustergram(globalCorr,'Global');
plot_clustergram(squeeze(mean(networkCorr,1,'omitnan')),'Network');
plot_clustergram(squeeze(mean(nodeCorr,1,'omitnan')),'Nodal');

% tsne plot
tsne_plot(networkCorr);
%% supplement for 3
% abs of results
% load results
if exist(strcat(paths.dataPath,filesep,'corrs.mat'),'file') ~= 2
    error('No results file exist, please make sure to run section 3.')
else
    load(strcat(paths.dataPath,filesep,'corrs.mat'));
end
% taking abs
globalCorr = abs(globalCorr);
networkCorr = abs(networkCorr);
nodeCorr = abs(nodeCorr);
% clustering plot
plot_clustergram(globalCorr,'Global','abs');
plot_clustergram(squeeze(mean(networkCorr,1,'omitnan')),'Network','abs');
plot_clustergram(squeeze(mean(nodeCorr,1,'omitnan')),'Nodal','abs');

% tsne plot
tsne_plot(networkCorr,'abs');

% inv of 1+RE
if ismember('RE',params.connSymbols)
    % load results
    filelist = dir(paths.resultPath);
    isdir = [filelist.isdir];
    filelist(isdir) = [];
    filelist(cellfun(@(x) strcmp(x,'.DS_Store'),{filelist.name})) = [];
    numFile = length(filelist);
    % patient list
    patients = {filelist.name}';
    patients = cellfun(@(x) x(1:end-4),patients,'UniformOutput',false);
    networkCorr = [];
    nodeCorr = [];
    globalStr = [];
    for i = 1:numFile
        % for each patient, reshape
        load(strcat(paths.resultPath,filesep,'',filelist(i).name))
        nchan = size(results,3);
        ind = find(triu(ones(nchan,nchan),1)); 
        nodeStr = NaN(params.nMethod,nchan);
        if strcmp(params.chans_to_use,'LR')
            results = permute(results,[2,1,3,4,5]);
            results = reshape(results,[params.nMethod,36,36,2]);
            tmpNet = reshape(results,[params.nMethod,36*36,2]);
            tmpNet = tmpNet(:,ind,:);
            tmpNet = reshape(tmpNet,[params.nMethod,length(ind)*2]);
            % node level
            for j = 1:nchan
                nodeStr(:,j,1) = nanmean(results(:,j,[1:(j-1),(j+1):end],1),3);
                nodeStr(:,j,2) = nanmean(results(:,j,[1:(j-1),(j+1):end],2),3);
            end
            nodeStr = reshape(nodeStr,[params.nMethod,36*2]); 
        else
            results(:,18:24,:,:) = 1./(1+results(:,18:24,:,:)); % added for test
            results = permute(results,[2,1,3,4]);
            results = reshape(results,[params.nMethod,nchan,nchan]);
            %  network level
            tmpNet = reshape(results,[params.nMethod,nchan*nchan]);
            tmpNet = tmpNet(:,ind,:);
            % node level
            for j = 1:nchan
                nodeStr(:,j) = nanmean(results(:,j,[1:(j-1),(j+1):end]),3);
            end
        end
        networkCorr(i,:,:) = corrcoef(tmpNet','Rows','complete');
        nodeCorr(i,:,:) = corrcoef(nodeStr','Rows','complete');
        % global level
        globalStr(:,i) = nanmean(nodeStr,2);
    end
    globalCorr = corrcoef(globalStr','Rows','complete');
    
    % clustering plot
    plot_clustergram(globalCorr,'Global','inv');
    plot_clustergram(squeeze(mean(networkCorr,1,'omitnan')),'Network','inv');
    plot_clustergram(squeeze(mean(nodeCorr,1,'omitnan')),'Nodal','inv');
    
    % tsne plot
    tsne_plot(networkCorr,'inv');
end
%% 4 | Spurious correlation 📈
% This part evaluate which re-ref method may introduce spurious correlation
% Note: This part is dependent on fieldtrip toolbox, so please specify your fieldtrip toolbox folder
 
% load toolbox
ftpath = "/Users/meow/Downloads/fieldtrip-20230118"; % <- change directory here
addpath(ftpath);
ft_defaults
% simulate data, 8 chans
% uncorrelated, without recording reference
params.num_chans = 8;
params.condition = 'uc';
params.div_fac = 3; % for correlated condition
params.num_trials = 100;
cfg = [];
cfg.method = 'linear_mix';
cfg.ntrials = params.num_trials;
cfg.triallength = 2;
cfg.fsample = 512;
cfg.nsignal = params.num_chans;
cfg.bpfilter = 'yes';
cfg.bpfreq = [8 80];
cfg.blc = 'yes';
cfg.delay = zeros(params.num_chans,params.num_chans);
switch params.condition
    case 'uc'
        cfg.mix = eye(params.num_chans);
    case 'c'
        mat = zeros(params.num_chans,params.num_chans);
        for i = 1:params.num_chans
            for j = 1:params.num_chans
                mat(i,j) = exp(-abs(j-i)/params.div_fac);
            end
        end
        cfg.mix = mat;
end
cfg.absnoise = 1;
data1 = ft_connectivitysimulation(cfg); % uncorrelated data
% with recording reference
cfg.mix = [cfg.mix,ones(params.num_chans,1)];
cfg.delay = zeros(params.num_chans,params.num_chans+1);
data2 = ft_connectivitysimulation(cfg); % machine reference data
% re-reference
labels = strcat({'LA'},string(num2cell([1:params.num_chans]))); % fake labels 
for i = 1:params.nRef
    data1(i+1) = data1(1);
    data2(i+1) = data2(1);
end
for j = 1:params.nRef
    func = params.refMap(params.refMethods{j});
    for i = 1:params.num_trials
        data = data1(1).trial{1,i}';
        [values,newlabels] = func(data,labels);
        ind = ~cellfun(@(x) strcmp(x,'-'),newlabels);
        newlabels = cellfun(@(x) x(1:regexp(x,'-')-1),newlabels,'UniformOutput',false);
        newlabels = newlabels(ind);
        data1(j+1).trial{1,i} = values(:,ind)';
        data = data2(1).trial{1,i}';
        [values,~] = func(data,labels);
        data2(j+1).trial{1,i} = values(:,ind)';
    end
    data1(j+1).label = newlabels;
    data2(j+1).label = newlabels;
end
save(strcat(paths.dataPath,filesep,'spurcorrdata_',params.condition,'.mat'),'data1','data2');
% analysis
for i = 1:params.nRef+1
    cfg = [];
    cfg.method = 'mtmfft';
    cfg.taper = 'dpss';
    cfg.output = 'fourier';
    cfg.tapsmofrq = 3;
    cfg.foilim = [0 100];
    freq1 = ft_freqanalysis(cfg, data1(i));
    freq2 = ft_freqanalysis(cfg, data2(i));
    cfg = [];
    cfg.method = 'coh';
    cfg.complex = 'abs';
    coh1(i) = ft_connectivityanalysis(cfg, freq1);
    coh2(i) = ft_connectivityanalysis(cfg, freq2);
end
save(strcat(paths.dataPath,filesep,'spurcorr_',params.condition,'.mat'),'coh1','coh2');
%% plot for section 4
if exist(strcat(paths.dataPath,filesep,'spurcorr_',params.condition,'.mat'),'file') ~= 2
    error('No results file exist, please make sure to run section 4.')
else
    load(strcat(paths.dataPath,filesep,'spurcorr_',params.condition,'.mat'));
end
% imagesc plot
for i = 1:params.nRef+1
    coh1plot{i} = mean(coh1(i).cohspctrm,3);
    coh2plot{i} = mean(coh2(i).cohspctrm,3);
end

% Customize the appearance of the heatmap
white = [1,1,1]; red = params.refCols(2,:);
colors = [white;red];
positions = [0, 1];
mycolormap = interp1(positions, colors, linspace(0, 1, 256), 'pchip');
titles = ['Machine reference',params.refSymbols];
% without recording ref
figure('Position',[0 0 1300 300]);
for i = 1:params.nRef+1
    subplot(1,params.nRef+1,i)
    imagesc(coh1plot{i});colorbar;caxis([0,1]);
    set(gca,'FontName',params.font,'FontSize',params.fontsize)
    title(titles{i},'FontName',params.font,'FontSize',params.fontsize)
end
colormap(mycolormap);
exportgraphics(gcf, strcat(paths.figPath,filesep,'spurcorr1_',params.condition,'.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'spurcorr1_',params.condition,'.svg'))
% with recording ref
figure('Position',[0 0 1300 300]);
for i = 1:params.nRef+1
    subplot(1,params.nRef+1,i)
    imagesc(coh2plot{i});colorbar;caxis([0,1]);
    set(gca,'FontName',params.font,'FontSize',params.fontsize)
    title(titles{i},'FontName',params.font,'FontSize',params.fontsize)
end
colormap(mycolormap);
exportgraphics(gcf, strcat(paths.figPath,filesep,'spurcorr2_',params.condition,'.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'spurcorr2_',params.condition,'.svg'))
close all
% average plot
cols = [hex2rgb('#63804f');params.refCols];
mycolormap = [reshape(cols,[1,params.nRef+1,3]);
              reshape(cols,[1,params.nRef+1,3])];
data = []; error = [];
for i = 1:params.nRef+1
    tmp = coh1plot{i};
    cons_ind = ~logical(triu(ones(size(tmp,1)), 2))&logical(triu(ones(size(tmp,1)), 1));
    noncon_ind = logical(triu(ones(size(tmp,1)), 2));
    data = [data,[mean(tmp(cons_ind),'all');
                  mean(tmp(noncon_ind),'all')]];
    error = [error,[std(tmp(cons_ind),0,'all');
                  std(tmp(noncon_ind),0,'all')]];
end
bar_error_plot(data,error,mycolormap,{'Consecutive contacts','Non-consecutive contacts'});
set(gcf,'Position',[0 0 600 400]);
legend(titles)
title('Averaged Correlation')
exportgraphics(gcf, strcat(paths.figPath,filesep,'spurcorr1_average_',params.condition,'.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'spurcorr1_average_',params.condition,'.svg'))

data = []; error = [];
for i = 1:params.nRef+1
    tmp = coh2plot{i};
    cons_ind = ~logical(triu(ones(size(tmp,1)), 2))&logical(triu(ones(size(tmp,1)), 1));
    noncon_ind = logical(triu(ones(size(tmp,1)), 2));
    data = [data,[mean(tmp(cons_ind),'all');
                  mean(tmp(noncon_ind),'all')]];
    error = [error,[std(tmp(cons_ind),0,'all');
                  std(tmp(noncon_ind),0,'all')]];
end
bar_error_plot(data,error,mycolormap,{'Consecutive contacts','Non-consecutive contacts'});
set(gcf,'Position',[0 0 600 400]);
legend(titles)
title('Averaged Correlation')
exportgraphics(gcf, strcat(paths.figPath,filesep,'spurcorr2_average_',params.condition,'.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'spurcorr2_average_',params.condition,'.svg'))

close all
clearvars -except numFile patientList params paths 
%% 5 | Sensitivity to electrode removal 📉
% settings
params.perc = [0.2 0.4 0.6 0.8];
params.nPerc = length(params.perc);

%% This part evaluate which method is most robust to sparse sampling
filelist = dir(paths.resultPath);
isdir = [filelist.isdir];
filelist(isdir) = [];
filelist(cellfun(@(x) strcmp(x,'.DS_Store'),{filelist.name})) = [];
numFile = length(filelist);

n_trial = 1000;
var_error = NaN(numFile,params.nMethod,params.nPerc);% for each patient X 48 method X 4 percent has one reliability score;
var_true= NaN(numFile,params.nMethod,params.nPerc);% for each patient X 48 method X 4 percent has one reliability score;
bar = waitbar(0, 'Processing...');
for i = 1:numFile
    waitbar(i/numFile, bar, sprintf('Processing %d of %d...', i, numFile));
    load(strcat(paths.resultPath,filesep,'',filelist(i).name))
    nchan = size(results,3);
    if nchan < 10 || any(cellfun(@(x) length(find(x))<10,full_ind))
        continue
    end
    permResult = NaN(params.nMethod,params.nPerc,n_trial,nchan);%for each patient X 48 methods X 4 percent X 500 trials  X n contacts
    for k = 1:params.nPerc
        for n = 1:n_trial
            tmp = results;
            nodeStr = [];
            if strcmp(params.chans_to_use,'LR')
                for r = 1:params.nRef
                    chans = find(full_ind{r});
                    n_chan = length(chans);
                    n_remove = round(n_chan*params.perc(k));
                    chans_remove = chans(randperm(n_chan,n_remove));
                    tmp(r,:,chans_remove,chans_remove,:) = NaN;
                end
                tmp = permute(tmp,[2,1,3,4,5]);
                tmp = reshape(tmp,[params.nMethod,36,36,2]);
                for j = 1:nchan
                    nodeStr(:,j,:) = mean(tmp(:,j,[1:(j-1),(j+1):end],:),3,'omitnan');
                end
                nodeStr = reshape(nodeStr,[params.nMethod,36*2]);
            else
                for r = 1:params.nRef
                    chans = find(full_ind{r});
                    n_chan = length(chans);
                    n_remove = round(n_chan*params.perc(k));
                    chans_remove = chans(randperm(n_chan,n_remove));
                    tmp(r,:,chans_remove,chans_remove) = NaN;
                end
                tmp = permute(tmp,[2,1,3,4]);
                tmp = reshape(tmp,[params.nMethod,nchan,nchan]);
                for j = 1:nchan
                    nodeStr(:,j) = nanmean(tmp(:,j,[1:(j-1),(j+1):end]),3);
                end
            end
            permResult(:,k,n,:) = nodeStr;
        end
    end
    var_error(i,:,:) = nanmean(squeeze(nanstd(permResult,0,3).^2),3);
    var_true(i,:,:) = nanmean((nanstd(permResult,0,4).^2),3);
end
close(bar)
permReliability = var_true./(var_true + var_error);
permReliability = reshape(permReliability,params.nSeg,[],params.nMethod,params.nPerc);
permReliability = squeeze(nanmean(permReliability,1));
save(strcat(paths.dataPath,filesep,'perm.mat'),'permReliability','var_true','var_error')
clearvars -except numFile patientList params paths 
%% plot for section 5
if exist(strcat(paths.dataPath,filesep,'perm.mat'),'file') ~= 2
    error('No results file exist, please make sure to run section 5.')
else
    load(strcat(paths.dataPath,filesep,'perm.mat'));
end
labels = cellstr(num2str(params.perc'*100,'%.0f%%'))';
% SPLIT BY REF
% plot
ref = reshape(permReliability,[size(permReliability,1),sum(params.numFeats),params.nRef,size(permReliability,3)]);
ref = squeeze(nanmean(ref,2));
boxdata = {};
for i = 1:params.nRef
    boxdata{i} = squeeze(ref(:,i,:));
end
plot_paired_line(boxdata);
title('Re-reference Methods','FontSize',16,'FontWeight','bold','FontName','Avenir')
exportgraphics(gcf, strcat(paths.figPath,filesep,'robustRef_line.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'robustRef_line.svg'))
close all
% box plot
groupCenters = @(nGroups,nMembers,interGroupSpace) ...
    nGroups/2+.5 : nGroups+interGroupSpace : (nGroups+interGroupSpace)*nMembers-1;
col = brighten(params.refCols,0.2);
fig = figure('Position',[0,0,800,400]);
hold on
b = boxplotGroup(boxdata,'primaryLabels',repmat({''}, params.nRef, 1), ...
    'Colors',col,'GroupType','betweenGroups', ...
    'PlotStyle','traditional','BoxStyle','outline', ...
    'Symbol','o','Widths',0.7);
title('Re-reference Methods','FontSize',16,'FontWeight','bold')
ylabel('Reliability')
xlabel('% Electrode Removed')
set(gca,'FontName','Helvetica','FontSize',14)
ticks = groupCenters(numel(boxdata), size(boxdata{1},2), 1);
set(gca,'XTick',ticks,'XTickLabels',labels)
exportgraphics(gcf, strcat(paths.figPath,filesep,'robustRef.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'robustRef.svg'))
close all
% SPlit by method
method = [];
boxdata = {};
for i = 1:params.nConn
    tmp = permReliability(:,sum(params.numFeats(1:i-1))+1:sum(params.numFeats(1:i)),:);
    tmp = (tmp + permReliability(:,sum(params.numFeats(1:i-1))+1+24:sum(params.numFeats(1:i))+24,:))/2;
    method(:,i,:) = nanmean(tmp,2);
    boxdata{i} = squeeze(method(:,i,:));
end
figure('Position',[0,0,800,400])
hold on
b = boxplotGroup(boxdata,'primaryLabels',repmat({''}, params.nConn, 1), ...
    'Colors',params.connCols,'GroupType','betweenGroups', ...
    'PlotStyle','traditional','BoxStyle','outline', ...
    'Symbol','o','Widths',0.7);
title('Connectivity Methods','FontSize',16,'FontWeight','bold')
ylabel('Reliability')
xlabel('% Electrode Removed')
set(gca,'FontName','Avenir','FontSize',14)
ticks = groupCenters(numel(boxdata), size(boxdata{1},2), 1);
set(gca,'XTick',ticks,'XTickLabels',labels)
exportgraphics(gcf, strcat(paths.figPath,filesep,'robustMethod.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'robustMethod.svg'))
close all
% SPlit by freq
ini = [];
for i = 1:params.nConn
    if params.numFeats(i) == 1
        continue
    else
        ini = [ini, sum(params.numFeats(1:i-1))];
    end
end
freq = [];
boxdata = {};
for i = 1:params.nFreq
    tmp = permReliability(:,ini+i,:);
    tmp = (tmp + permReliability(:,ini+i+sum(params.numFeats),:))/2;
    freq(:,i,:) = nanmean(tmp,2);
    boxdata{i} = squeeze(freq(:,i,:));
end
dark = hex2rgb('#a5474e');
bright = hex2rgb('#ead8da');
position = [0,1];
mycolormap = interp1(position, [bright;dark], linspace(0, 1, params.nFreq), 'pchip');
figure('Position',[0,0,800,400])
hold on
b = boxplotGroup(boxdata,'primaryLabels',repmat({''}, params.nFreq, 1), ...
    'Colors',mycolormap,'GroupType','betweenGroups', ...
    'PlotStyle','traditional','BoxStyle','outline', ...
    'Symbol','o','Widths',0.7);
title('Frequency Bands','FontSize',16,'FontWeight','bold')
ylabel('Reliability')
xlabel('% Electrode Removed')
set(gca,'FontName','Avenir','FontSize',14)
ticks = groupCenters(numel(boxdata), size(boxdata{1},2), 1);
set(gca,'XTick',ticks,'XTickLabels',labels)
exportgraphics(gcf, strcat(paths.figPath,filesep,'robustFreq.png'), 'Resolution', 300);
saveas(gcf,strcat(paths.figPath,filesep,'robustFreq.svg'))
close all
% add test
% ref
refmean = squeeze(nanmean(ref,1));
methodmean = squeeze(nanmean(method,1));
freqmean = squeeze(nanmean(freq,1));
for i = 1:params.nPerc
    [p,h] = signrank(ref(:,1,i),ref(:,2,i));
    statsRef{i} = p;
    tmp = squeeze(method(:,:,i));
    tmp(any(isnan(tmp),2),:) = [];
    [p,tbl,stats] = friedman(tmp);
    statsMethod{i} = tbl;
    resultsMethod{i} = multcompare(stats,'CType','dunn-sidak');
    tmp = squeeze(freq(:,:,i));
    tmp(any(isnan(tmp),2),:) = [];
    [p,tbl,stats] = friedman(tmp);
    statsFreq{i} = tbl;
    resultsFreq{i} = multcompare(stats,'CType','dunn-sidak');
end
close all
for i = 1:size(ref,3)
    tmp = resultsRef{i};
    sigRef{i} = tmp(tmp(:,6)<=0.05,:);
    tmp = resultsMethod{i};
    sigMethod{i} = tmp(tmp(:,6)<=0.05,:);
    tmp = resultsFreq{i};
    sigFreq{i} = tmp(tmp(:,6)<=0.05,:);
end

for n = 1:params.nPerc
    sigMat = NaN(params.nConn);
    results = resultsMethod{1,n};
    for i = 1:params.nConn-1
        for j = i+1:params.nConn
            sigMat(i,j) = results(find(results(:,1) == i & results(:,2) == j),6);
        end
    end
    sigMatMethod{n} = sigMat;
end

for n = 1:params.nPerc
    sigMat = NaN(params.nFreq);
    results = resultsFreq{1,n};
    for i = 1:params.nFreq-1
        for j = i+1:params.nFreq
            sigMat(i,j) = results(find(results(:,1) == i & results(:,2) == j),6);
        end
    end
    sigMatFreq{n} = sigMat;
end
save(strcat(paths.dataPath,filesep,'permstats.mat'),'resultsRef','resultsMethod','resultsFreq', ...
                                        'statsRef','statsMethod','statsFreq', ...
                                        'ref','method','freq', ...
                                        'refmean','methodmean','freqmean', ...
                                        'sigRef','sigMethod','sigFreq', ...
                                        'sigMatMethod','sigMatFreq');
clearvars -except numFile patientList params paths 
%% 6 | SOZ lateralization 🧠
% This part evaluate which method perform best in lateralizing epilepsy patients.
% (Note: The ML part was implemented in Google Colab and hasn't been transfered to here yet) 
% load results
filelist = dir(paths.resultPath);
isdir = [filelist.isdir];
filelist(isdir) = [];
numFile = length(filelist);
% patient list
patients = {filelist.name}';
patients = cellfun(@(x) x(1:end-4),patients,'UniformOutput',false);
nodeStrAll = [];
nodeStr = [];
for i = 1:numFile
    % for each patient, reshape
    load(strcat(paths.resultPath,filesep,'',filelist(i).name))
    ind = find(triu(ones(36,36),1)); 
    results = permute(results,[2,1,3,4,5]);
    results = reshape(results,[params.nMethod,36,36,2]);
    % node level
    for j = 1:36
        nodeStr(:,j,1) = nanmean(results(:,j,[1:(j-1),(j+1):end],1),3);
        nodeStr(:,j,2) = nanmean(results(:,j,[1:(j-1),(j+1):end],2),3);
    end
    nodeStrAll(i,:,:,:) = nodeStr;
end
nodeStrAll = squeeze(nanmean(nodeStrAll,3));
nodeStrAll = reshape(nodeStrAll,params.nSeg,[],params.nMethod,2);
nodeStrAll = squeeze(nanmean(nodeStrAll,1));

% build labels
strlabel = {patientList.soz}';
istemp = [patientList.istemp];
numlabel = zeros(length(strlabel),1);
numlabel(cellfun(@(x) strcmp(x,'left'),strlabel)) = 1;
numlabel(cellfun(@(x) strcmp(x,'right'),strlabel)) = 2;
numlabel(cellfun(@(x) strcmp(x,'bilateral'),strlabel)) = 3;
remove = find(numlabel==0);
numlabel(remove) = [];
strlabel(remove) = [];
nodeStrAll(remove,:,:) = [];
istemp(remove) = [];
istemp = logical(istemp');
goodoutcome = cellfun(@(x) ~isempty(x)&&x < 2,{patientList.Engel});
goodoutcome(remove) = [];
goodoutcome = goodoutcome';
nodeStrAll = permute(nodeStrAll,[2,1,3]);
save(strcat(paths.dataPath,filesep,'sozML.mat'),'nodeStrAll','numlabel','strlabel','istemp','goodoutcome')
for k = 1:params.nMethod
    eval(['writematrix(squeeze(nodeStrAll(',num2str(k),',:,:)),strcat(paths.MLPath,"',filesep,num2str(k),'",".csv"));']);
end
writematrix(numlabel,strcat(paths.MLPath,filesep,'label.csv'))
writecell(params.shortList',strcat(paths.MLPath,filesep,'methods.csv'))
writematrix(goodoutcome,strcat(paths.MLPath,filesep,'goodout.csv'))
writematrix(istemp,strcat(paths.MLPath,filesep,'istemp.csv'))

% if there's left vs right difference overall
% per-method temporal lobe/nontempraol lobe
extractMLData(nodeStrAll(:,istemp,:),strcat(paths.MLPath,filesep,'pairT_LR_temp.csv'));
% soz/non-soz difference, pair-ttest
nodeStrAll(:,numlabel==2,:) = nodeStrAll(:,numlabel==2,[2,1]);
extractMLData(nodeStrAll(:,istemp&(numlabel==1|numlabel==2),:),strcat(paths.MLPath,filesep,'pairT_SOZ_temp.csv'));
clearvars -except numFile patientList params paths 
%% plot for section 6
if exist(strcat(paths.dataPath,filesep,'sozML.mat'),'file') ~= 2
    error('No results file exist, please make sure to run section 6.')
else
    load(strcat(paths.dataPath,filesep,'sozML.mat'));
end
plot_soz_scatter(nodeStrAll(:,istemp,:),numlabel(istemp),'pairT_LR_temp');
nodeStrAll(:,numlabel==2,:) = nodeStrAll(:,numlabel==2,[2,1]);
plot_soz_scatter(nodeStrAll(:,istemp&(numlabel==1|numlabel==2),:),numlabel(istemp&(numlabel==1|numlabel==2)),'pairT_SOZ_temp');
% volcano plot
files = dir(strcat(paths.MLPath,filesep,'pairT*'));
for i = 1:length(files)
    volcano_process(files(i).name(1:end-4),'bh');
end