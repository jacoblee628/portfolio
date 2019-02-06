data = csvread("half_mil_part-00001.csv");
centroids = unique(data(:,1:2),'rows');
bundles = cell(length(centroids));
aggr = zeros(4,1);
for i = 1:length(centroids)
    [rows,cols] = find(data(:,1:2)==centroids(i,:));
    points = data(rows,:);
    bundles{i} = points;
    if i==1
         aggr = points;
    else
        aggr = [aggr; points];
    end
end

gscatter(aggr(:,3),-(aggr(:,4))+40000,aggr(:,1:2));
legend("off");
hold on;
scatter(centroids(:,1), -centroids(:,2)+40000, 48, 'k', 'filled');

