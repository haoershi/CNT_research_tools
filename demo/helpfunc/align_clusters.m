function aligned_clusters = align_clusters(reference_clusters, clusters)
    num_clusters = max(reference_clusters);
    aligned_clusters = zeros(size(clusters));
    for i = 1:num_clusters
        mask = reference_clusters == i;
        most_frequent_value = mode(clusters(mask));
        aligned_clusters(mask) = most_frequent_value;
    end
end
