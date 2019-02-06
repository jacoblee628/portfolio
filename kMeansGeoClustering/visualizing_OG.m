%% Assumes input data was pure coordinates and nothing else

data=[part00000; part00001; part00002]; % add more as needed

centroids = data(:, [1 2]);
clusters = data(:, [3 4 1]);

%% run it

hold on

gscatter(clusters{:,2}, clusters{:,1}, clusters{:,3});
scatter(centroids{:,2}, centroids{:,1}, 48, 'k', 'filled');

hold off