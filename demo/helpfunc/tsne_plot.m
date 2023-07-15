function tsne_plot(networkCorr)
networkCorr = squeeze(mean(networkCorr,1,'omitnan'));
tsneCoordinates = tsne(networkCorr);
% make cluster labels
global paths params
clusterRef = [];
for i = 1:params.nRef
    clusterRef = [clusterRef repmat(i,1,24)];
end
clusterConn = [];
for j = 1:params.nRef
    for i = 1:params.nConn
        clusterConn = [clusterConn repmat(i,1,params.numFeats(i))];
    end
end
% cluster = [];
% for i = 1:nMethod
%     if clusterConn(i) == 6
%         cluster = [cluster 3];
%     elseif clusterRef(i) == 1
%         cluster = [cluster 1];
%     elseif clusterRef(i) == 2
%         cluster = [cluster 2];
%     end
% end
refCol = params.refCols;
% connCols = {'#B4CE99','#789264','#506D31','#E59595','#A5474E','#3C5488'};
% connCols = hex2rgb(connCols);
% colSet = [refCol; connCols(6,:)];
cols_scatter = refCol(clusterRef,:);
axisLabel = {'t-SNE 1','t-SNE 2'};
symbol = {'o','+','*','x','s','^'};
f = figure('Position',[0 0 700 500]);
for i = 1:params.nMethod
    scatter(tsneCoordinates(i, 1), tsneCoordinates(i, 2), ...
            150,cols_scatter(i,:), symbol{clusterConn(i)}, ...
            'MarkerFaceAlpha',.7,'LineWidth',1);
    hold on
end
title("t-SNE Plot of Network Level Pre-processing Pipeline Similarity")
set(gca,'FontName','Helvetica','FontSize',20)
xlabel(axisLabel{1})
ylabel(axisLabel{2})
legend(params.connMeasureNames,'Location','SouthWest','AutoUpdate','off')
saveas(gcf,strcat(paths.figPath,filesep,'tsne.svg'))
close all