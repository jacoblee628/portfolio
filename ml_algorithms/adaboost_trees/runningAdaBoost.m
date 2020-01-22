% Note: Changed names of input files (to properly separate the training and
% test data)
% load zip_train;
% load zip_test;

% -------------------------
% One vs Three
% -------------------------
% 
% fprintf('Working on the one-vs-three problem...\n\n');
% % Isolate entries
% subsample_tr = zip_train(find(zip_train(:,1)==1 | zip_train(:,1)==3),:);
% subsample_te = zip_test(find(zip_test(:,1)==1 | zip_test(:,1)==3),:);
% X_tr = subsample_tr(:,2:257);
% X_te = subsample_te(:,2:257);
% y_tr = subsample_tr(:,1);
% y_te = subsample_te(:,1);
% 
% % Change y values that are "3" to "-1", to work with AdaBoost
% y_tr(y_tr==3)=-1;
% y_te(y_te==3)=-1;
% 
% % Run AdaBoost experiments, each time incrementing
% n_trees = 1:1:100;
% errors = [reshape(1:1:length(n_trees),[length(n_trees),1]) zeros(length(n_trees),2)];
% for i=1:length(n_trees)
%     [errors(i,2), errors(i,3)] = AdaBoost(X_tr, y_tr, X_te, y_te, i);
% end
% 
% % Plot One Vs Three
% plot(errors(:,1),errors(:,2),errors(:,1),errors(:,3))
% ylim([0 0.2])
% xlabel("# of Trees")
% ylabel("Error Rate")
% legend("Training Error", "Test Error")
% title("AdaBoost (1 vs 3) Number of Stumps vs Error Rate")

% -------------------------
% Three vs Five
% -------------------------
fprintf('Working on the three-vs-five problem...\n\n');

% Isolate entries
subsample_tr = zip_train(find(zip_train(:,1)==3 | zip_train(:,1) == 5),:);
subsample_te = zip_test(find(zip_test(:,1)==3 | zip_test(:,1) ==5),:);
X_tr = subsample_tr(:,2:257);
X_te = subsample_te(:,2:257);
y_tr = subsample_tr(:,1);
y_te = subsample_te(:,1);

% Change y values from "3" to 1 and "5" to "-1", to work with AdaBoost
y_tr(y_tr==3)=1;
y_te(y_te==3)=1;
y_tr(y_tr==5)=-1;
y_te(y_te==5)=-1;

% Run AdaBoost experiments, each time incrementing
n_trees = 1:1:100;
errors = [reshape(1:1:length(n_trees),[length(n_trees),1]) zeros(length(n_trees),2)];
for i=1:length(n_trees)
    [errors(i,2), errors(i,3)] = AdaBoost(X_tr, y_tr, X_te, y_te, i);
end

% Plot Three Vs Five
plot(errors(:,1),errors(:,2),errors(:,1),errors(:,3))
ylim([0 0.2])
xlabel("# of Trees")
ylabel("Error Rate")
legend("Training Error", "Test Error")
title("AdaBoost (3 vs 5) Number of Stumps vs Error Rate")