trials = [1; 10; 100; 1000; 10000; 100000];
c = 2;

area_storage = [trials zeros(size(trials,1),1)];

for n = 1:size(trials,1)
    
    d = [rand([trials(n),c]) zeros(trials(n),1)];
    d(:,3) = sqrt(d(:,1).^2+d(:,2).^2);
    
    inside = zeros(1,3);
    outside = zeros(1,3);
    
    for i = 1:trials(n)
        if d(i,3)<1
            inside = [inside;d(i,:)];
        else
            outside = [outside;d(i,:)];
        end
    end
    
    cropped_in = inside(2:size(inside,1),:);
    cropped_out = outside(2:size(outside,1),:);
    if (n==6)
        scatter(cropped_in(:,1),cropped_in(:,2),'blue', '.');
        hold on;
        
        scatter(cropped_out(:,1),cropped_out(:,2),'red', '.');
        
        x=0:0.00001:1;
        y=sqrt(1-x.^2);
        plot(x,y);
        
        hold off;
    end
    
    area_storage(n,2) = 4 * size(cropped_in,1)/trials(n);
    
    disp(trials(n));
end
