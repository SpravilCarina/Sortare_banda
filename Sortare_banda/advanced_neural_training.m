%% ANTRENAMENT AVANSAT AL REȚELEI NEURONALE PENTRU SORTARE
% Script pentru optimizarea performanței rețelei neuronale

function optimized_net = advanced_neural_training()
    fprintf('=== ANTRENAMENT AVANSAT AL REȚELEI NEURONALE ===\n');
    
    %% 1. GENERARE SET DE DATE EXTINS
    n_samples_per_class = 1000;  % Mai multe date pentru antrenament
    
    [X_train, Y_train] = generate_extended_dataset(n_samples_per_class);
    
    %% 2. ÎMPĂRȚIREA DATELOR
    [X_train_set, X_val_set, X_test_set, Y_train_set, Y_val_set, Y_test_set] = ...
        split_dataset(X_train, Y_train, 0.7, 0.15, 0.15);
    
    fprintf('Date generate pentru antrenament: %d eșantioane\n', size(X_train, 1));
    
    %% 3. TESTAREA DIFERITELOR ARHITECTURI
    architectures = {...
    [10], ...
    [15], ...
    [20], ...
    [10, 5], ...
    [15, 10], ...
    [20, 15], ...
    [15, 10, 5] ...
    };

    
    best_accuracy = 0;
    best_net = [];
    best_architecture = [];
    
    fprintf('\nTestarea arhitecturilor:\n');
    fprintf('%-15s %-15s %-15s\n', 'Arhitectura', 'Acuratețe (%)', 'MSE');
    fprintf('%s\n', repmat('-', 1, 45));
    
    for i = 1:length(architectures)
        arch = architectures{i};
        arch_str = sprintf('[%s]', num2str(arch));
        
        net = patternnet(arch, 'trainscg');
        net.trainParam.epochs = 500;
        net.trainParam.goal = 1e-6;
        net.trainParam.lr = 0.01;
        net.trainParam.showWindow = false;
        
        net.divideParam.trainRatio = 0.7;
        net.divideParam.valRatio = 0.15;
        net.divideParam.testRatio = 0.15;
        
        net = train(net, X_train_set', Y_train_set');
        
        outputs = net(X_val_set');
        performance = perform(net, Y_val_set', outputs);
        
        [~, predicted] = max(outputs);
        [~, actual] = max(Y_val_set');
        accuracy = sum(predicted == actual) / length(actual) * 100;
        
        fprintf('%-15s %-15.2f %-15.6f\n', arch_str, accuracy, performance);
        
        if accuracy > best_accuracy
            best_accuracy = accuracy;
            best_net = net;
            best_architecture = arch;
        end
    end
    
    fprintf('\nCea mai bună arhitectură: [%s] cu acuratețea %.2f%%\n', num2str(best_architecture), best_accuracy);
    
    %% 4. FINE-TUNING AL CELEI MAI BUNE REȚELE
    fprintf('\nFine-tuning pentru arhitectura optimă...\n');
    
    optimized_net = patternnet(best_architecture, 'trainscg');
    optimized_net.trainParam.epochs = 2000;
    optimized_net.trainParam.goal = 1e-7;
    optimized_net.trainParam.lr = 0.005;
    optimized_net.trainParam.lr_dec = 0.1;
    optimized_net.trainParam.lr_inc = 1.05;
    optimized_net.trainParam.max_fail = 10;
    optimized_net.trainParam.min_grad = 1e-10;
    
    optimized_net.divideParam.trainRatio = 0.7;
    optimized_net.divideParam.valRatio = 0.15;
    optimized_net.divideParam.testRatio = 0.15;
    
    [optimized_net, tr] = train(optimized_net, X_train', Y_train');
    
    %% 5. EVALUAREA PERFORMANȚEI FINALE
    test_outputs = optimized_net(X_test_set');
    [~, predicted_classes] = max(test_outputs);
    [~, actual_classes] = max(Y_test_set');
    
    final_accuracy = sum(predicted_classes == actual_classes) / length(actual_classes) * 100;
    final_mse = perform(optimized_net, Y_test_set', test_outputs);
    
    confusion_matrix = confusionmat(actual_classes, predicted_classes);
    
    num_classes = 3;
    class_names = {'Plastic', 'Metal', 'Sticla'};
    precision = zeros(num_classes, 1);
    recall = zeros(num_classes, 1);
    f1_score = zeros(num_classes, 1);
    
    for class=1:num_classes
        tp = confusion_matrix(class, class);
        fp = sum(confusion_matrix(:, class)) - tp;
        fn = sum(confusion_matrix(class, :)) - tp;
        
        precision(class) = tp / (tp + fp);
        recall(class) = tp / (tp + fn);
        f1_score(class) = 2 * precision(class) * recall(class) / (precision(class) + recall(class));
    end
    
    %% 6. AFIȘAREA REZULTATELOR
    fprintf('\n=== REZULTATE FINALE ===\n');
    fprintf('Acuratețea pe setul de test: %.2f%%\n', final_accuracy);
    fprintf('MSE final: %.8f\n', final_mse);
    fprintf('\nPerformanța pe clasă:\n');
    fprintf('%-10s %-12s %-12s %-12s\n', 'Clasă', 'Precizie', 'Recall', 'F1-Score');
    fprintf('%s\n', repmat('-',1,48));
    for i=1:num_classes
        fprintf('%-10s %-12.3f %-12.3f %-12.3f\n', class_names{i}, precision(i), recall(i), f1_score(i));
    end
    
    %% 7. SALVAREA MODELULUI OPTIMIZAT
    save('retea_neuronala_optimizata.mat', 'optimized_net', 'tr', 'confusion_matrix', 'precision', 'recall', 'f1_score');
    
    fprintf('\nRețeaua neurală optimizată a fost salvată cu succes!\n');
end

%% FUNCȚII SUPLIMENTARE
function [X, Y] = generate_extended_dataset(n_per_class)
    total_samples = 3 * n_per_class;
    X = zeros(total_samples,6);
    Y = zeros(total_samples,3);
    
    idx_start = 1;
    idx_end = n_per_class;
    X(idx_start:idx_end,1) = 50 + 150*rand(n_per_class,1);  % R Plastic
    X(idx_start:idx_end,2) = 30 + 170*rand(n_per_class,1);  % G Plastic
    X(idx_start:idx_end,3) = 40 + 160*rand(n_per_class,1);  % B Plastic
    X(idx_start:idx_end,4) = 0.03 + 0.20*rand(n_per_class,1); % L Plastic
    X(idx_start:idx_end,5) = 0.03 + 0.20*rand(n_per_class,1); % W Plastic
    X(idx_start:idx_end,6) = 0.01 + 0.12*rand(n_per_class,1); % H Plastic
    Y(idx_start:idx_end,1) = 1;
    
    idx_start = n_per_class + 1;
    idx_end = 2 * n_per_class;
    X(idx_start:idx_end,1) = 120 + 80*rand(n_per_class,1);  % R Metal
    X(idx_start:idx_end,2) = 120 + 80*rand(n_per_class,1);  % G Metal
    X(idx_start:idx_end,3) = 120 + 80*rand(n_per_class,1);  % B Metal
    X(idx_start:idx_end,4) = 0.06 + 0.18*rand(n_per_class,1); % L Metal
    X(idx_start:idx_end,5) = 0.06 + 0.18*rand(n_per_class,1); % W Metal
    X(idx_start:idx_end,6) = 0.03 + 0.15*rand(n_per_class,1); % H Metal
    Y(idx_start:idx_end,2) = 1;
    
    idx_start = 2 * n_per_class + 1;
    idx_end = 3 * n_per_class;
    X(idx_start:idx_end,1) = 10 + 100*rand(n_per_class,1);   % R Sticla
    X(idx_start:idx_end,2) = 80 + 120*rand(n_per_class,1);   % G Sticla
    X(idx_start:idx_end,3) = 30 + 120*rand(n_per_class,1);   % B Sticla
    X(idx_start:idx_end,4) = 0.08 + 0.25*rand(n_per_class,1); % L Sticla
    X(idx_start:idx_end,5) = 0.08 + 0.25*rand(n_per_class,1); % W Sticla
    X(idx_start:idx_end,6) = 0.08 + 0.20*rand(n_per_class,1); % H Sticla
    Y(idx_start:idx_end,3) = 1;
    
    % Normalizarea datelor
    X = (X - min(X)) ./ (max(X) - min(X));
end

function [X_train, X_val, X_test, Y_train, Y_val, Y_test] = split_dataset(X, Y, train_ratio, val_ratio, test_ratio)
    n_samples = size(X,1);
    indices = randperm(n_samples);
    
    n_train = round(train_ratio * n_samples);
    n_val = round(val_ratio * n_samples);
    
    train_idx = indices(1:n_train);
    val_idx = indices(n_train+1:n_train+n_val);
    test_idx = indices(n_train+n_val+1:end);
    
    X_train = X(train_idx,:);
    X_val = X(val_idx,:);
    X_test = X(test_idx,:);
    
    Y_train = Y(train_idx,:);
    Y_val = Y(val_idx,:);
    Y_test = Y(test_idx,:);
end
