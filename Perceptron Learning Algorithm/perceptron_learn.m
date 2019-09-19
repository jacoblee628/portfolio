function [ w, iterations ] = perceptron_learn( data_in )
%perceptron_learn Run PLA on the input data
%   Inputs: data_in: Assumed to be a matrix with each row representing an
%                    (x,y) pair, with the x vector augmented with an
%                    initial 1, and the label (y) in the last column
%   Outputs: w: A weight vector (should linearly separate the data if it is
%               linearly separable)
%            iterations: The number of iterations the algorithm ran for

% Initialization
iterations = 0;
N = size(data_in,1);
d = size(data_in,2)-2;
w = zeros(d+1,1);
updating=true;

% Begin algorithm
while updating==true
    updating = false;
    for m = 1:N
        if sign(dot(w,data_in(m, 1:d+1)))~=data_in(m,d+2)
            updating = true;
            w = w + (data_in(m,1:d+1)*data_in(m,d+2)).';
            iterations=iterations+1;
        end
    end
end
end

