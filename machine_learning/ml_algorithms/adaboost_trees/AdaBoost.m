function [ train_err, test_err ] = AdaBoost( X_tr, y_tr, X_te, y_te, n_trees )
%AdaBoost: Implement AdaBoost using decision stumps learned
%   using information gain as the weak learners.
%   X_tr: Training set
%   y_tr: Training set labels
%   X_te: Testing set
%   y_te: Testing set labels
%   n_trees: The number of trees to use

% Pre-allocate matrices
importance = zeros(n_trees,1);
prediction_tr = zeros(size(y_tr,1),n_trees);
prediction_te = zeros(size(y_te,1),n_trees);

% Initialize weights to 1/n
w = ones(size(X_tr,1),1)*(1/size(X_tr,1));

% Generate trees
for i=1 : n_trees
    % Train weak learner stump
    stumpini = fitctree(X_tr,y_tr,'Weights', w, 'MaxNumSplits',1);
    
    % Compute weighted training errors
    weighted_err = 0;
    prediction_tr(:,i) = predict(stumpini,X_tr);
    prediction_te(:,i) = predict(stumpini,X_te);
    
    for j=1 : size(prediction_tr,1)
        if (prediction_tr(j,i)~=y_tr(j,1))
            weighted_err = weighted_err + w(j,1);
        end
    end
    
    % Compute importance, normalization factor, and update weights
    importance(i,1) = (1/2)*log((1-weighted_err)/weighted_err);
    normalization = 2*sqrt(weighted_err*(1-weighted_err));
    
    for k=1 : size(w,1)
        w(k,1)=w(k,1)/normalization*exp(-importance(i,1)*y_tr(k,1)*prediction_tr(k,i));
    end
end

% Calculate training error based on saved information
atht_tr = importance'.*prediction_tr;
gt_tr = sign(sum(atht_tr,2));
train_err = sum(gt_tr~=y_tr)/size(y_tr,1);

% Calculate test error
atht_te = importance'.*prediction_te;
gt_te = sign(sum(atht_te,2));
test_err = sum(gt_te~=y_te)/size(y_te,1);