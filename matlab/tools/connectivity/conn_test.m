%% some data can be used for calculation
dataList = {};
for i = 1:length(metaData)
    if strcmp('ABC',metaData(i).elecInd)
        dataList = [dataList metaData(i).filename];
    end
end
%% set up results var
results = struct();
regionList = {'LA','RA','LB','RB','LC','RC'};
% for i = 1:length(regionList)
%     for j = 1:6
%         results((i-1)*6+j).Elec1 = strcat([regionList{i},num2str(j)]);
%         results((i-1)*6+j).Elec2 = strcat([regionList{i},num2str(j+6)]);
%     end
% end
%% Doable Pipeline
results = struct(); 
output = zeros(66,12);
refList = {'car','bipolar'};
corrList = {'pearson','coherence'};
for i = 1:length(dataList)
    for j = 1:length(refList)
        [values,labels,fs] = preprocess_pipeline(dataList{i},[100000 100015],refList{j});
        [labels,elecs,nums] = decompose_labels(labels);
        for m = 1:length(regionList)
            nums_tmp = nums(find(contains(labels,regionList{m})));
            [~,ind] = sort(nums_tmp);
            results(i,m,j).label = labels(find(contains(labels,regionList{m})));
            results(i,m,j).label = results(i,m,j).label(ind);
            data = values(:,find(contains(labels,regionList{m})));
            data = data(:,ind);
            for k = 1:length(corrList)
                switch corrList{k}
                    case 'pearson'
                        results(i,m,j).pearson = new_pearson_calc(data,fs,2,1);
                        tmp = [];
                        n_pair = floor(size(results(i,m,j).pearson,1)/2);
                        for n = 1:n_pair
                            tmp = [tmp results(i,m,j).pearson(n,n+n_pair)];
                        end
                        results(i,m,j).avg_pc = mean(tmp);
                        output((i-1)*6+m,(j-1)*6+1) = results(i,m,j).avg_pc;
                    case 'coherence'
                        results(i,m,j).coherence = coherence_calc(data,fs);
                        tmp = [];
                        n_pair = floor(size(results(i,m,j).coherence,1)/2);
                        for n = 1:n_pair
                            tmp = [tmp results(i,m,j).coherence(n,n+n_pair,:)];
                        end
                        results(i,m,j).avg_coh = squeeze(mean(tmp,2));
                        if ~isempty(results(i,m,j).avg_coh)
                            output((i-1)*6+m,(j-1)*6+2:(j-1)*6+6) = results(i,m,j).avg_coh;
                        end
                end
            end
        end
    end
end
    
