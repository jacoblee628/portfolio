clearvars;

%% Declare activations and criterion
relu = @(x) max(0, x);
sigmoid = @(x) 1 ./ (1 + exp(-x));
tanh = @(x) tanh(x);

%% training params (set these!)
lrs = [0.3, 0.1, 0.01, 0.001]; % Basic LR scheduling
momentum = 0.1; % Momentum factor
num_epochs = 5000;
num_trials = 100; % Number of neural networks to create (num_epochs on each during training)
plot_train_loss = false;
disp_fold_stats = false;
K = 5;

zero_mean = true; % Set this to true to center input data around a mean of 0.
data_len = 45; % Change this if not using full set
split_size = 9; % Adjust this for k fold validation

%% Neural network params
layer_sizes = [2 4 1]; % change layers and hidden sizes 
activations = {tanh, sigmoid}; % replace with activation functions
init_method = "kaiming"; % or "normal"

%% Run t trials with K folds each
num_lrs = length(lrs);
trial_test_accs = zeros(num_trials, 1);
trial_train_losses = zeros(num_trials, 1);
for trial=1:num_trials
    disp("Trial #" + trial);
    
    %% Data stuff
    data = [hex_1 hex_2]; % Change this
    data_size = size(data, 2);
    
    train_len = data_len - split_size; % Check this

    % zero-mean data
    if zero_mean
        data = data - mean(data, 2); 
    end
    
    labels = [ones(1, data_size / 2) zeros(1, data_size / 2)];
    
    % Shuffle data so each trial is diff
    rnd_idx = randperm(data_size);
    data = data(:, rnd_idx);
    labels = labels(rnd_idx);
    
    train_inds = zeros(K, train_len);
    test_inds = zeros(K, split_size);

    partition = crossvalind('Kfold', data_len, K);

    for fold = 1:K
        test_inds(fold,:) = find(partition == fold);
        train_inds(fold,:) = find(~(partition == fold));
    end

    %% Fold loop
    fold_test_accs = zeros(1, K);
    fold_train_losses = zeros(1, K);
    for fold=1:K
        if disp_fold_stats
            disp("Fold #" + fold);
        end
        train_data = data(:, train_inds(fold, :));
        train_labels = labels(:, train_inds(fold, :));
        test_data = data(:, test_inds(fold, :));
        test_labels = labels(:, test_inds(fold, :));

        % Flip indices (make my life easier)
        train_data = train_data';
        train_labels = train_labels';
        test_data = test_data';
        test_labels = test_labels';

        %% initialize layers, neurons, weights and biases
        num_layers = size(layer_sizes, 2) - 1;
        weights = {};
        biases = {};
        dws = {};
        dw_momentum = {};
        dbs = {};
        db_momentum = {};

        for layer=1:num_layers
            weights{layer} = randn(layer_sizes(layer), layer_sizes(layer + 1));
            biases{layer} = randn(1, layer_sizes(layer+1));
            dws{layer} = zeros(layer_sizes(layer), layer_sizes(layer + 1));
            dbs{layer} = zeros(1, layer_sizes(layer + 1));
            dw_momentum{layer} = zeros(layer_sizes(layer), layer_sizes(layer + 1));;
            db_momentum{layer} = zeros(1, layer_sizes(layer + 1));
            if init_method == "kaiming"
                weights{layer} = weights{layer} * (sqrt(2)/sqrt(layer_sizes(layer))); 
                biases{layer} = zeros(1, layer_sizes(layer + 1));
            end
        end

        %% begin training
        E = zeros(num_epochs, 1);
        lr_counter = 1;
        lr = lrs(lr_counter);
        for epoch=1:num_epochs
            %% change LR based on scheduler
            if mod(epoch, num_epochs / num_lrs) == 0
                lr = lrs(lr_counter);
                lr_counter = lr_counter + 1;
            end

            %% Shuffle input data
            train_indices = randperm(train_len);

            %% FORWARD:
            outs = cell(num_layers + 1, 1);
            outs{1} = train_data(train_indices, :);
            for layer=1:num_layers
                activation = activations{layer};
                outs{layer + 1} = activation(outs{layer} * weights{layer} + biases{layer});
            end

            %% BACKPROP: 
            % Zero out gradients
            for layer=1:num_layers
                dws{layer} = zeros(layer_sizes(layer), layer_sizes(layer + 1));
                dbs{layer} = zeros(layer_sizes(layer + 1), 1);
            end

            % Calculate loss
            delta = train_labels(train_indices) - outs{end};
            E(epoch) = 1/2 * (delta' * delta);

            % Backprop through each layer
            for layer = num_layers:-1:1
                if isequal(activations{layer}, relu)
                   dz = sign(outs{layer + 1});
                elseif isequal(activations{layer}, tanh)
                   dz = 1 - outs{layer + 1}.^2;
                else
                   dz = outs{layer + 1} .* (1 - outs{layer + 1});
                end
                % Get new delta
                delta = delta .* dz;
                dws{layer} = outs{layer}' * delta / train_len;
                dbs{layer} = sum(delta) / train_len;

                % Get dws
                delta = delta * weights{layer}';

                % Momentum update
                dw_momentum{layer} = momentum * dw_momentum{layer} - lr * dws{layer};
                dws{layer} = dws{layer} + dw_momentum{layer};
                db_momentum{layer} = momentum * db_momentum{layer} - lr * dbs{layer};
                dbs{layer} = dbs{layer} + db_momentum{layer};
                weights{layer} = weights{layer} + dws{layer};
                biases{layer} = biases{layer} + dbs{layer};
            end
        end

        %% Display final train error
        train_loss = E(end);

        %% Calculate test error
        predictions = p4_get_labels(test_data, weights, biases, activations);
        test_accuracy = sum(predictions == test_labels) / length(test_data);
        

        if disp_fold_stats
            fprintf('train loss: %f \n', train_loss);
            fprintf('test acc: %f \n', test_accuracy);
        end
        %% Plot
        if plot_train_loss
            figure;
            plot(E);
            title("Training loss, final train loss: " + train_loss + ", final test acc: " + test_accuracy)
            xlabel('Epoch #')
            ylabel('Loss')
        end

        %% Store results of fold
        fold_test_accs(fold) = test_accuracy;
        fold_train_losses(fold) = train_loss;
    end
    %% Average over folds
    trial_loss = mean(fold_train_losses);
    disp("train loss: " + trial_loss);
    trial_train_losses(trial) = trial_loss;
    
    trial_acc = mean(fold_test_accs);
    disp("test acc: " + trial_acc);
    trial_test_accs(trial) = trial_acc;
end


if num_trials > 1
    disp("--------------------------");
    disp("Trial stats");
    disp("--------------------------");
    disp("Mean train loss: " + mean(trial_train_losses));
    disp("Max train loss: " + max(trial_train_losses));
    disp("Min train loss: " + min(trial_train_losses));
    disp("Mean test acc: " + mean(trial_test_accs));
    disp("Max test acc: " + max(trial_test_accs));
    disp("Min test acc: " + min(trial_test_accs));
    
    % Create plot title
    layer_string = "[";
    for layer=1:length(layer_sizes) - 1
        layer_string = layer_string + layer_sizes(layer) + ", "; 
    end
    layer_string = layer_string + layer_sizes(end) + "]";
    
    % LR string
    lr_string = "[";
    for lr=1:length(lrs) - 1
        lr_string = lr_string + lrs(lr) + ", "; 
    end
    lr_string = lr_string+ lrs(end) + "]";

    % Rest of the params
    param_string = "lrs=" + lr_string + ", " + init_method + " init, zero mean=" + zero_mean + ", "+ layer_string;
    
    % Test accuracy
    figure;
    histogram(trial_test_accs);
    title({"Test Accuracies, " + num_trials + " trials", param_string});
    xlabel('Accuracy')
    ylabel('Frequency')
    % Train loss
    figure;
    histogram(trial_train_losses);
    title({"Train Losses, " + num_trials + " trials", param_string});
    xlabel('Loss')
    ylabel('Frequency')
end