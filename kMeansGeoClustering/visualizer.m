%% change the files in centroids folder to centroids1...centroidsA
centroids=[centroids1; centroids2];

%% change the files to cluster1...clusterB
clusters = [cluster1; cluster2];

%% run it

hold on

gscatter(clusters{:,2}, clusters{:,1}, clusters{:,3});
scatter(centroids{:,2}, centroids{:,1}, 48, 'k', 'filled');

hold off