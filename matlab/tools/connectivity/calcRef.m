function [values,labels,newInd,keep] = calcRef(values,labels,reference)

%% Common average reference (include only intra-cranial)
switch reference
    case 'car'
        [values,labels] = common_average_reference(values,ones(length(labels)),labels);
        newlabels = cellfun(@(x) x(1:regexp(x,'-')-1),labels,'UniformOutput',false);
        [values,labels,newInd,keep] = updateLabel(values,newlabels,logical([1:length(labels)]));
    case 'bipolar'
        [values,~,labels,~] = bipolar_montage(values,labels);
        ind = cellfun(@(x) strcmp(x,'-'),labels);
        newlabels = cellfun(@(x) x(1:regexp(x,'-')-1),labels,'UniformOutput',false);
        [values,newlabels,newInd,keep] = updateLabel(values,newlabels,~ind);
        labels = labels(cellfun(@(x) ismember(x(1:regexp(x,'-')-1),newlabels),labels));
end


