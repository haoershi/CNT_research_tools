[filedir, ~, ~] = fileparts(mfilename('fullpath'));
cd(filedir);
cd('./../..')
%%
refMethods = {'car','bipolar'}; 
connMeasures = {'pearson','squaredPearson','crossCorr','coh','plv','relaEntropy'};%,'granger'};
numFeats = [1,1,1,6,6,6];
load(which('elecmat.mat'));
load(which('subMeta.mat'));
patientList = subMeta;

results = NaN(length(patientList),length(refMethods),sum(numFeats),36,36,2);

keepPatient = zeros(length(patientList),1);
%%
for i = 1:length(patientList)
    selecElecs = [leftmat(logical(patientList(i).elecInd));rightmat(logical(patientList(i).elecInd))];
    [data,labels,fs,elecIndNew,keepPatient(i)] = preprocess(patientList(i).filename,selecElecs,elecmat);
    if keepPatient(i) == 0
        continue
    end
    save(strcat('data/',patientList(i).filename,'.mat'),'data','labels','fs','elecIndNew')
end
%%
for i = 1:length(patientList)
    filename = strcat('data/',patientList(i).filename,'.mat');
    if exist(filename,'file')
        load(filename)
        disp(i)
        for j = 1:length(refMethods)
            [values,newlabels,elecIndNew,keepPatient(i)] = calcRef(data,labels,refMethods{j});
            if keepPatient(i) == 0
                continue
            end
            %[data,labels,fs] = preprocess_pipeline(subMeta(i).filename,[80000,80015],refMethods{j},selecElecs);
            for k = 4:length(connMeasures)
                out = calcConn(values,fs,connMeasures{k},elecIndNew,2,1);
                results(i,j,sum(numFeats(1:k-1))+1:sum(numFeats(1:k-1))+numFeats(k),:,:,:) = permute(out,[3,1,2,4]);
            end
        end
    end
end
%% turn into upper triangular
load(which('results.mat'));
for i = 1:length(patientList)
    for j = 1:2
        for k = 1:21
            for m = 1:2
                results(i,j,k,:,:,m) = triu(squeeze(results(i,j,k,:,:,m)),1);
            end
        end
    end
end
save('data/results.mat','results');
%% calculate measure correlation
ind = find(triu(ones(36,36), 1));
for i = 1:length(patientList)
    tmp = results(i,:,:,:,:,:);
    tmp = reshape(tmp,[length(refMethods),sum(numFeats),36,36,2]);
    tmp = permute(tmp,[2,1,3,4,5]);
    tmp = reshape(tmp,[length(refMethods)*sum(numFeats),36,36,2]);
    tmpNet = reshape(tmp,[length(refMethods)*sum(numFeats),36*36,2]);
    tmpNet = tmpNet(:,ind,:);
    tmpNet = reshape(tmpNet,[length(refMethods)*sum(numFeats),length(ind)*2]);
    networkCorr(i,:,:) = corrcoef(tmpNet','Rows','complete');
    tmpNode = tmp + permute(tmp,[1,3,2,4]);
    nodeStr = [];
    for j = 1:36
        nodeStr(:,j,1) = mean(tmpNode(:,j,[1:(j-1),(j+1):end],1),3,'omitnan');
        nodeStr(:,j,2) = mean(tmpNode(:,j,[1:(j-1),(j+1):end],2),3,'omitnan');
    end
    nodeStr = reshape(nodeStr,[length(refMethods)*sum(numFeats),36*2]); 
    nodeCorr(i,:,:) = corrcoef(nodeStr','Rows','complete');
    globalStr(:,i) = mean(nodeStr,2,'omitnan');
end
globalCorr = corrcoef(globalStr','Rows','complete');
save('data/corrs.mat','networkCorr','nodeCorr','globalStr','globalCorr')

% % order of patients
% [~,ord] = sort(nodeStr2,1);
% ordCorr = corrcoef(ord);
% imagesc(ordCorr);
%% for machine learning data
ind = find(triu(ones(36,36), 1));
for i = 1:93%length(patientList)
    tmp = results(i,:,:,:,:,:);
    tmp = reshape(tmp,[length(refMethods),sum(numFeats),36,36,2]);
    tmp = permute(tmp,[2,1,3,4,5]);
    tmp = reshape(tmp,[length(refMethods)*sum(numFeats),36,36,2]);
    tmpNode = tmp + permute(tmp,[1,3,2,4]);
    nodeStr = [];
    for j = 1:36
        nodeStr(:,j,1) = mean(tmpNode(:,j,[1:(j-1),(j+1):end],1),3,'omitnan');
        nodeStr(:,j,2) = mean(tmpNode(:,j,[1:(j-1),(j+1):end],2),3,'omitnan');
    end
    nodeStrAll(i,:,:,:) = nodeStr;
%     nodeStr = reshape(nodeStr,[length(refMethods)*sum(numFeats),36*2]); 
%     nodeStr = squeeze(mean(nodeStr,2,'omitnan'));
%     avgMLData(i,:) = reshape(squeeze(mean(nodeStr,2,'omitnan')),[1,length(refMethods)*sum(numFeats)*2]);
end
nodeStrAll = squeeze(mean(nodeStrAll,3,'omitnan'));
nodeStrAll([77,78,92],:,:) = [];
nodeStrAll = nodeStrAll(~remove,:,:);
for k = 1:length(refMethods)*sum(numFeats)
    eval(['writematrix(squeeze(nodeStrAll(:,',num2str(k),',:)),strcat("ML/","',num2str(k),'",".csv"));']);
end
freqBands = {'delta','theta','alpha','beta','gamma','broad'};
connMeasureNames = {'Pearson','Squared Pearson','Cross Corr','Coherence','PLV','Relative Entropy'};
colNames = {};
for i = 1:length(connMeasureNames)
    if numFeats(i) == 1
        colNames = [colNames, connMeasureNames(i)];
    elseif numFeats(i) == 6
         tmpNames = strcat(connMeasureNames(i),{'-'},freqBands);
        colNames = [colNames, tmpNames];
    end
end
finalNames = [strcat(refMethods{1},'-',colNames),strcat(refMethods{2},'-',colNames)];
writecell(finalNames,'ML/methods.csv')
nodeStrAll2 = nodeStrAll;
label2 = numLabel;
nodeStrAll2(21,:,:) = [];
label2(21) = [];
for k = 22:length(refMethods)*sum(numFeats)
    eval(['writematrix(squeeze(nodeStrAll2(:,',num2str(k),',:)),strcat("ML/","',num2str(k),'",".csv"));']);
end
writematrix(label2,'ML/label2.csv');
%% heatmap settings
freqBands = {'\delta','\theta','\alpha','\beta','\gamma','All'};
connMeasureNames = {'Pearson','Squared Pearson','Cross Corr','Coherence','PLV','Relative Entropy'};
colNames = {};
for i = 1:length(connMeasureNames)
    if numFeats(i) == 1
        colNames = [colNames, connMeasureNames(i)];
    elseif numFeats(i) == 6
%         tmpNames = strcat(connMeasureNames(i),{' '},freqBands);
        colNames = [colNames, freqBands];
    end
end
purple = [143,124,195]/255; white = [1,1,1]; yellow = [254,217,102]/255;
blue = [39,110,187]/255;red = [171,55,60]/255;
% colors = [purple;white;yellow];
colors = [blue;white;red];
positions = [0, 0.5, 1];
mycolormap = interp1(positions, colors, linspace(0, 1, 256), 'pchip');
% Customize the appearance of the heatmap
h.Colormap = colormap(mycolormap);%brighten(redbluecmap, 0.6);
h.GridVisible = 'off';
h.FontSize = 12;
h.XDisplayLabels = [colNames,colNames];
h.YDisplayLabels = [colNames,colNames];
h.Position = [0.125 0.15 0.5 0.825];
%% annote
annotation('textbox',[0.175, 0.03,0.1,0.09], 'String','Coherence', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.165, 0.23],[0.12,0.12]);
annotation('textbox',[0.255, 0.03,0.1,0.09], 'String','PLV', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.235, 0.3],[0.12,0.12]);
annotation('textbox',[0.32, 0.03,0.1,0.09], 'String',{'Relative','Entropy'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.305, 0.37],[0.12,0.12]);

plus = 0.25;
annotation('textbox',[0.175+plus, 0.03,0.1,0.09], 'String','Coherence', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.165+plus, 0.23+plus],[0.12,0.12]);
annotation('textbox',[0.255+plus, 0.03,0.1,0.09], 'String','PLV', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.235+plus, 0.3+plus],[0.12,0.12]);
annotation('textbox',[0.32+plus, 0.03,0.1,0.09], 'String',{'Relative','Entropy'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.305+plus, 0.37+plus],[0.12,0.12]);

annotation('textbox',[0.17, 0.03,0.9,0.02], 'String','Common Average Reference', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.125 0.37],[0.05,0.05]);
annotation('textbox',[0.2+plus, 0.03,0.1,0.02], 'String','Bipolar Reference', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.125+plus 0.37+plus],[0.05,0.05]);

% vertical
annotation('textbox',[0.06, 0.03,0.75,0.84], 'String','Coherence', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.8,0.91]);
annotation('textbox',[0.085, 0.03,0.635,0.725], 'String','PLV', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.685,0.795]);
annotation('textbox',[0.07, 0.03,0.55,0.61], 'String',{'Relative','Entropy'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.565,0.68]);

minus = 0.415;
annotation('textbox',[0.06, 0.03,0.75-minus,0.84-minus], 'String','Coherence', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.8-minus,0.91-minus]);
annotation('textbox',[0.085, 0.03,0.635-minus,0.725-minus], 'String','PLV', 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.685-minus,0.795-minus]);
annotation('textbox',[0.07, 0.03,0.55-minus,0.61-minus], 'String',{'Relative','Entropy'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.11, 0.11],[0.565-minus,0.68-minus]);

annotation('textbox',[0.01, 0.03,0.67,0.76], 'String',{'Common','Average','Reference'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.055, 0.055],[0.565,0.97]);
annotation('textbox',[0.01, 0.03,0.67-minus,0.76-minus], 'String',{'Bipolar','Reference'}, 'FontSize', 12,'LineStyle','none');
annotation('line',[0.055, 0.055],[0.565-minus,0.97-minus]);
%%
for i = 1:length(patientList)
    % Create a heatmap object
    if patientList(i).keep == 1
        % Export the heatmap to a file
        fig1 = heatmap(squeeze(networkCorr(i,:,:)));
        set(fig1,h);
        fig1.Title = strrep(strcat(patientList(i).filename,' Network Connectivity Measure Correlation'),'_','-');
        exportgraphics(gcf, strcat('figs/',patientList(i).filename,'_Network.png'), 'Resolution', 300);
        saveas(gcf,strcat('figs/',patientList(i).filename,'_Network.svg'))
        fig2 = heatmap(squeeze(nodeCorr(i,:,:)));
        set(fig2,h);
        fig2.Title = strrep(strcat(patientList(i).filename,' Nodal Connectivity Measure Correlation'),'_','-');
        exportgraphics(gcf, strcat('figs/',patientList(i).filename,'_Nodal.png'), 'Resolution', 300);
        saveas(gcf,strcat('figs/',patientList(i).filename,'_Nodal.svg'))
%         close all
    end
end
%%
fig1 = heatmap(squeeze(mean(networkCorr,1,'omitnan')));
set(fig1,h);
fig1.Title = strrep(strcat('Averaged Network Connectivity Measure Correlation'),'_','-');
exportgraphics(gcf, strcat('figs/Network.png'), 'Resolution', 300);
saveas(gcf,strcat('figs/Network.svg'))
fig1 = heatmap(squeeze(mean(nodeCorr,1,'omitnan')));
set(fig1,h);
fig1.Title = strrep(strcat('Averaged Nodal Connectivity Measure Correlation'),'_','-');
exportgraphics(gcf, strcat('figs/Nodal.png'), 'Resolution', 300);
saveas(gcf,strcat('figs/Nodal.svg'))
fig1 = heatmap(globalCorr);
set(fig1,h);
fig1.Title = strrep(strcat('Global Connectivity Measure Correlation'),'_','-');
exportgraphics(gcf, strcat('figs/Global.png'), 'Resolution', 300);
saveas(gcf,strcat('figs/Global.svg'))