function [ w, e_in ] = logistic_reg( X, y, w_init, max_its, eta )
%LOGISTIC_REG Learn logistic regression model using gradient descent
%   Inputs:
%       X : data matrix (without an initial column of 1s)
%       y : data labels (plus or minus 1)
%       w_init: initial value of the w vector (d+1 dimensional)
%       max_its: maximum number of iterations to run for
%       eta: learning rate

%   Outputs:
%       w : weight vector
%       e_in : in-sample error (as defined in LFD)

% Augment x
X = [ones(size(X,1),1) X];

for t=1:max_its
    % calculate gradient
    denominator=(1+exp(y.* (X*w_init)));
    g=-(1/size(X,1))*(y./denominator)'*X;
    
    % break if euclidean norm of g is less than 10^-3
    if abs(g)<10^(-6)
%         disp('break');
        break;
    end
    
    % add the negative gradient to w
    w_init = w_init - eta*g';
end

fprintf('Iterations: %d \n', t);

% return weight vector
w=w_init;

% return e_in
e_in=(1/size(X,1)).*sum(log(1+exp(-(y.*(X*w)))));

end

