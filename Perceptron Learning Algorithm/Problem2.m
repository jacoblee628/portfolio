[num_iters, bounds] = perceptron_experiment(100,10,5);

% histogram(num_iters);

dif=zeros(size(bounds));

for i=1:size(bounds)
    dif(i)=log(bounds(i)-num_iters(i));
end

histogram(dif);