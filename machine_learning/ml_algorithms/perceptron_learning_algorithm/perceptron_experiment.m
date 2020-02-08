function [ num_iters, bounds] = perceptron_experiment ( N, d, num_samples )
%perceptron_experiment Code for running the perceptron experiment in HW1
%   Inputs: N is the number of training examples
%           d is the dimensionality of each example (before adding the 1)
%           num_samples is the number of times to repeat the experiment
%   Outputs: num_iters is the # of iterations PLA takes for each sample
%            bound_minus_ni is the difference between the theoretical bound
%               and the actual number of iterations
%      (both the outputs should be num_samples long)

% Create arrays to bound_minus_ni and num_iters for each sample
num_iters=zeros(num_samples,1);
bounds=zeros(num_samples,1);

for i = 1:num_samples
    % Initialization
    training = -1+2*rand(N,d+2);
    training(:,1) = ones(1,N);
    
    % Calculating training y based on ideal weights
    ideal_weight = rand(d+1,1);
    ideal_weight(1,1) = 0;
    
    for j = 1:N
        training(j, d+2) = sign(dot(ideal_weight,training(j, 1:d+1)));
    end

    % Run the actual algorithm
    [w, iterations] = perceptron_learn(training);
    
    % Store the number of iterations
    num_iters(i) = iterations;
    
    % Find min rho and max R
    rho=intmax;
    R=0;
    for k = 1:N
        rho = min(rho,training(k,d+2)*(dot(ideal_weight,training(k, 1:d+1))));
        R = max(R, norm(training(k, 1:d+1)));
    end
    
    % Store bounds for that round
    bounds(i)=(R^2*norm(ideal_weight)^2)/(rho^2); 
end
end

