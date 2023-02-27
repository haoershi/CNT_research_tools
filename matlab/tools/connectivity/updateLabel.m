function [values,newlabels,newInd,keep] = updateLabel(values,labels,include)
load('elecmat.mat');
newlabels = labels(include);
[newInd,keep] = findLRelecs(newlabels);
newlabels = [leftmat(logical(newInd));rightmat(logical(newInd))];
values = values(:,ismember(labels,newlabels));