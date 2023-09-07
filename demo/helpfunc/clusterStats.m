function p_value = clusterStats(data, numCluster, numBootStrap)

% Hierarchical clustering
linkage_matrix = linkage(data, 'ward', 'euclidean');
clusters = cluster(linkage_matrix, 'MaxClust', numCluster);
ref_sihoulette_scores = mean(silhouette(data, clusters));

% Initialize an array to store adjusted Rand Indices
sihoulette_scores = zeros(numBootStrap, 1);
ri_scores = zeros(numBootStrap, 1); % Columns for Rand Index and Jaccard Similarity

for i = 1:numBootStrap
    % Generate bootstrap resampled data and perform clustering
    bootstrap_indices = randi(size(data, 1), size(data, 1), 1);
    bootstrap_data = data(bootstrap_indices, :);
    bootstrap_linkage = linkage(bootstrap_data, 'ward');
    bootstrap_clusters = cluster(bootstrap_linkage, 'MaxClust', numCluster); % Example number of clusters
    sihoulette_scores(i) = mean(silhouette(bootstrap_data, bootstrap_clusters));
    mapped_clusters = NaN
    mapped_clusters(bootstrap_indices) = bootstrap_clusters;  
    % Adjust cluster indices to align with the original clustering
    adjusted_clusters = align_clusters(clusters, mapped_clusters);
    
    % Calculate Adjusted Rand Index
    ri_scores(i) = rand_index(clusters, adjusted_clusters, 'adjusted');
end

% Calculate p-value based on adjusted Rand Indices
avg_ri = mean(adjusted_ri_values);
p_value = sum(sihoulette_scores >= ref_sihoulette_scores) / numBootStrap;
disp(['Stability score for the original clustering: ', num2str(avg_ri)]);
disp(['Sihoulette score: ', num2str(ref_sihoulette_scores)]);
disp(['P-value from permutation: ', num2str(p_value)]);
end
% Function to align cluster indices with the reference clustering
function aligned_clusters = align_clusters(reference_clusters, clusters)
    num_clusters = max(reference_clusters);
    aligned_clusters = zeros(size(clusters));
    for i = 1:num_clusters
        mask = reference_clusters == i;
        most_frequent_value = mode(clusters(mask));
        aligned_clusters(mask) = most_frequent_value;
    end
end
