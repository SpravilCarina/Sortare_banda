%% SISTEM INTELIGENT DE SORTARE PE BANDĂ TRANSPORTOARE CU REȚELE NEURONALE
% Proiect pentru Bazele Roboticii
% Implementare completă în MATLAB și Simulink

clear all; clc; close all;

%% 1. CONFIGURAREA PARAMETRILOR SISTEMULUI
fprintf('=== INIȚIALIZAREA SISTEMULUI INTELIGENT DE SORTARE ===\n');

% Parametrii benzii transportoare
belt_length = 10;        % Lungimea benzii (m)
belt_width = 1;          % Lățimea benzii (m)  
belt_speed = 0.5;        % Viteza inițială (m/s)
belt_speed_min = 0.2;    % Viteza minimă
belt_speed_max = 2.0;    % Viteza maximă

% Parametrii obiectelor
num_objects = 50;        % Numărul de obiecte de sortat
object_types = {'Plastic', 'Metal', 'Sticla'};

% Parametrii senzorilor virtuali
sensor_noise = 0.05;     % Zgomotul senzorilor (5%)
sampling_rate = 100;     % Rata de eșantionare (Hz)

fprintf('Parametrii sistemului configurați cu succes\n');

%% 2. GENERAREA DATELOR DE ANTRENAMENT PENTRU REȚEAUA NEURALĂ
fprintf('\n=== GENERAREA DATELOR DE ANTRENAMENT ===\n');

% Generare date pentru 3 tipuri de obiecte
n_samples_per_class = 200;  % Numărul de eșantioane per clasă
total_samples = n_samples_per_class * 3;

% Matricea de caracteristici [R, G, B, Lungime, Lățime, Înălțime]
X_train = zeros(total_samples, 6);
Y_train = zeros(total_samples, 3);  % One-hot encoding pentru 3 clase

% CLASA 1: PLASTIC (culori variate, dimensiuni mici-medii)
start_idx = 1;
end_idx = n_samples_per_class;
X_train(start_idx:end_idx, 1) = 100 + 100*rand(n_samples_per_class, 1);  % R: 100-200
X_train(start_idx:end_idx, 2) = 50 + 150*rand(n_samples_per_class, 1);   % G: 50-200  
X_train(start_idx:end_idx, 3) = 80 + 120*rand(n_samples_per_class, 1);   % B: 80-200
X_train(start_idx:end_idx, 4) = 0.05 + 0.15*rand(n_samples_per_class, 1); % L: 5-20cm
X_train(start_idx:end_idx, 5) = 0.05 + 0.15*rand(n_samples_per_class, 1); % W: 5-20cm
X_train(start_idx:end_idx, 6) = 0.02 + 0.08*rand(n_samples_per_class, 1); % H: 2-10cm
Y_train(start_idx:end_idx, 1) = 1;  % Plastic = [1 0 0]

% CLASA 2: METAL (culori metalice, dimensiuni medii)
start_idx = n_samples_per_class + 1;
end_idx = 2 * n_samples_per_class;
X_train(start_idx:end_idx, 1) = 150 + 50*rand(n_samples_per_class, 1);   % R: 150-200 (argintiu)
X_train(start_idx:end_idx, 2) = 150 + 50*rand(n_samples_per_class, 1);   % G: 150-200
X_train(start_idx:end_idx, 3) = 150 + 50*rand(n_samples_per_class, 1);   % B: 150-200
X_train(start_idx:end_idx, 4) = 0.08 + 0.12*rand(n_samples_per_class, 1); % L: 8-20cm
X_train(start_idx:end_idx, 5) = 0.08 + 0.12*rand(n_samples_per_class, 1); % W: 8-20cm
X_train(start_idx:end_idx, 6) = 0.05 + 0.10*rand(n_samples_per_class, 1); % H: 5-15cm
Y_train(start_idx:end_idx, 2) = 1;  % Metal = [0 1 0]

% CLASA 3: STICLĂ (transparentă/verde, dimensiuni mari)
start_idx = 2 * n_samples_per_class + 1;
end_idx = 3 * n_samples_per_class;
X_train(start_idx:end_idx, 1) = 20 + 80*rand(n_samples_per_class, 1);    % R: 20-100 (verde)
X_train(start_idx:end_idx, 2) = 100 + 100*rand(n_samples_per_class, 1);  % G: 100-200
X_train(start_idx:end_idx, 3) = 50 + 100*rand(n_samples_per_class, 1);   % B: 50-150
X_train(start_idx:end_idx, 4) = 0.10 + 0.20*rand(n_samples_per_class, 1); % L: 10-30cm
X_train(start_idx:end_idx, 5) = 0.10 + 0.20*rand(n_samples_per_class, 1); % W: 10-30cm
X_train(start_idx:end_idx, 6) = 0.10 + 0.15*rand(n_samples_per_class, 1); % H: 10-25cm
Y_train(start_idx:end_idx, 3) = 1;  % Sticla = [0 0 1]

% Normalizarea datelor de intrare
X_train_norm = (X_train - min(X_train)) ./ (max(X_train) - min(X_train));

fprintf('Date de antrenament generate: %d eșantioane pentru %d clase\n', total_samples, 3);

%% 3. CREAREA ȘI ANTRENAREA REȚELEI NEURONALE
fprintf('\n=== CREAREA REȚELEI NEURONALE ===\n');

% Transpunerea datelor pentru MATLAB Deep Learning Toolbox
% (caracteristici pe rânduri, eșantioane pe coloane)
inputs = X_train_norm';
targets = Y_train';

% Crearea rețelei de recunoaștere de tipare
hiddenLayerSizes = [15, 10];  % Două straturi ascunse: 15 și 10 neuroni
net = patternnet(hiddenLayerSizes, 'trainscg');

% Configurarea parametrilor de antrenament
net.trainParam.epochs = 1000;       % Numărul maxim de epoci
net.trainParam.goal = 1e-5;         % Eroarea țintă
net.trainParam.lr = 0.01;           % Rata de învățare
net.trainParam.show = 50;           % Afișarea progresului la fiecare 50 epoci

% Împărțirea datelor pentru antrenament, validare și testare
net.divideParam.trainRatio = 0.7;   % 70% pentru antrenament
net.divideParam.valRatio = 0.15;    % 15% pentru validare
net.divideParam.testRatio = 0.15;   % 15% pentru testare

% Antrenarea rețelei neuronale
fprintf('Începerea antrenamentului rețelei neuronale...\n');
[net, tr] = train(net, inputs, targets);

% Evaluarea performanței
outputs = net(inputs);
performance = perform(net, targets, outputs);
fprintf('Performanța rețelei (MSE): %.6f\n', performance);

% Calcularea acurateței de clasificare
[~, predicted_class] = max(outputs);
[~, actual_class] = max(targets);
accuracy = sum(predicted_class == actual_class) / length(actual_class) * 100;
fprintf('Acuratețea clasificării: %.2f%%\n', accuracy);

%% 4. SIMULAREA SENZORILOR VIRTUALI
fprintf('\n=== SIMULAREA SENZORILOR VIRTUALI ===\n');

% Funcție pentru simularea senzorului de culoare
color_sensor = @(r, g, b, noise) [r + noise*randn(), g + noise*randn(), b + noise*randn()];

% Funcție pentru simularea senzorului de dimensiuni  
dimension_sensor = @(l, w, h, noise) [l + noise*randn(), w + noise*randn(), h + noise*randn()];

% Funcție pentru simularea detecției obiectelor pe bandă
function [detected_objects] = simulate_object_detection(num_obj)
    detected_objects = cell(num_obj, 1);
    
    for i = 1:num_obj
        % Generare aleatoare tip obiect
        obj_type = randi(3);
        
        switch obj_type
            case 1  % Plastic
                rgb = [100 + 100*rand(), 50 + 150*rand(), 80 + 120*rand()];
                dims = [0.05 + 0.15*rand(), 0.05 + 0.15*rand(), 0.02 + 0.08*rand()];
                type_name = 'Plastic';
                
            case 2  % Metal
                rgb = [150 + 50*rand(), 150 + 50*rand(), 150 + 50*rand()];
                dims = [0.08 + 0.12*rand(), 0.08 + 0.12*rand(), 0.05 + 0.10*rand()];
                type_name = 'Metal';
                
            case 3  % Sticlă
                rgb = [20 + 80*rand(), 100 + 100*rand(), 50 + 100*rand()];
                dims = [0.10 + 0.20*rand(), 0.10 + 0.20*rand(), 0.10 + 0.15*rand()];
                type_name = 'Sticla';
        end
        
        detected_objects{i} = struct('RGB', rgb, 'Dimensions', dims, 'TrueType', type_name, 'ID', i);
    end
end

fprintf('Senzorii virtuali configurați cu succes\n');

%% 5. ALGORITMUL PRINCIPAL DE SORTARE
fprintf('\n=== ALGORITMUL DE SORTARE ===\n');

% Simularea detecției obiectelor
test_objects = simulate_object_detection(20);

% Contorizarea sortării
sort_counts = struct('Plastic', 0, 'Metal', 0, 'Sticla', 0);
sort_accuracy = 0;

fprintf('\nÎnceperea procesului de sortare pentru %d obiecte:\n', length(test_objects));
fprintf('%-5s %-15s %-15s %-15s %-10s\n', 'ID', 'Tip Real', 'Tip Prezis', 'RGB', 'Corect');
fprintf('%-5s %-15s %-15s %-15s %-10s\n', repmat('-', 1, 5), repmat('-', 1, 15), repmat('-', 1, 15), repmat('-', 1, 15), repmat('-', 1, 10));

for i = 1:length(test_objects)
    obj = test_objects{i};
    
    % Simularea zgomotului senzorilor
    noise_level = sensor_noise * 50; % Pentru RGB
    measured_rgb = color_sensor(obj.RGB(1), obj.RGB(2), obj.RGB(3), noise_level);
    
    noise_level = sensor_noise * 0.02; % Pentru dimensiuni
    measured_dims = dimension_sensor(obj.Dimensions(1), obj.Dimensions(2), obj.Dimensions(3), noise_level);
    
    % Pregătirea datelor pentru rețeaua neurală
    features = [measured_rgb, measured_dims];
    features_norm = (features - min(X_train)) ./ (max(X_train) - min(X_train));
    features_norm = features_norm'; % Transpunere pentru rețea
    
    % Clasificarea cu rețeaua neurală
    nn_output = net(features_norm);
    [~, predicted_class_idx] = max(nn_output);
    predicted_type = object_types{predicted_class_idx};
    
    % Verificarea acurateței
    is_correct = strcmp(obj.TrueType, predicted_type);
    if is_correct
        sort_accuracy = sort_accuracy + 1;
    end
    
    % Actualizarea contorului
    sort_counts.(predicted_type) = sort_counts.(predicted_type) + 1;
    
    % Simularea ajustării vitezei benzii în funcție de tipul obiectului
    switch predicted_type
        case 'Plastic'
            adjusted_speed = belt_speed * 1.2; % Viteza mai mare pentru plastic
        case 'Metal'
            adjusted_speed = belt_speed * 0.8; % Viteza mai mică pentru metal
        case 'Sticla'
            adjusted_speed = belt_speed * 0.6; % Viteza cea mai mică pentru sticlă
    end
    
    adjusted_speed = max(min(adjusted_speed, belt_speed_max), belt_speed_min);
    
    % Afișarea rezultatelor
    rgb_str = sprintf('[%.0f,%.0f,%.0f]', measured_rgb(1), measured_rgb(2), measured_rgb(3));
    if is_correct
        correct_str = '✓';
    else
        correct_str = '✗';
    end
    fprintf('%-5d %-15s %-15s %-15s %-10s\n', obj.ID, obj.TrueType, predicted_type, rgb_str, correct_str);
end

final_accuracy = (sort_accuracy / length(test_objects)) * 100;
fprintf('\n=== REZULTATELE SORTĂRII ===\n');
fprintf('Acuratețea sortării: %.1f%% (%d/%d)\n', final_accuracy, sort_accuracy, length(test_objects));
fprintf('Obiecte sortate:\n');
fprintf('  - Plastic: %d obiecte\n', sort_counts.Plastic);
fprintf('  - Metal: %d obiecte\n', sort_counts.Metal);
fprintf('  - Sticlă: %d obiecte\n', sort_counts.Sticla);

%% 6. VIZUALIZAREA REZULTATELOR
fprintf('\n=== GENERAREA GRAFICELOR ===\n');

% Graficul 1: Distribuția obiectelor sortate
figure(1);
categories = fieldnames(sort_counts);
values = [sort_counts.Plastic, sort_counts.Metal, sort_counts.Sticla];
bar(values, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', categories);
title('Distribuția Obiectelor Sortate');
ylabel('Numărul de Obiecte');
xlabel('Tipul Obiectului');
grid on;

% Graficul 2: Matricea de confuzie pentru rețeaua neurală
figure(2);
plotconfusion(targets, outputs, 'Matricea de Confuzie - Rețea Neurală');

% Graficul 3: Performanța antrenamentului
figure(3);
plotperform(tr);
title('Performanța Antrenamentului Rețelei Neuronale');

% Graficul 4: Curba ROC
figure(4);
plotroc(targets, outputs, 'Curba ROC - Clasificarea Obiectelor');

fprintf('Graficele generate cu succes\n');

%% 7. SALVAREA MODELULUI ȘI REZULTATELOR
fprintf('\n=== SALVAREA REZULTATELOR ===\n');

% Salvarea rețelei neuronale antrenate
save('retea_neuronala_sortare.mat', 'net', 'X_train', 'Y_train', 'object_types');

% Salvarea rezultatelor
results = struct();
results.training_accuracy = accuracy;
results.testing_accuracy = final_accuracy;
results.sort_counts = sort_counts;
results.network_performance = performance;
results.training_record = tr;

save('rezultate_sortare.mat', 'results');

fprintf('Modelul și rezultatele salvate cu succes\n');

%% 8. AFIȘAREA REZUMATULUI FINAL
fprintf('\n=== REZUMATUL PROIECTULUI ===\n');
fprintf('✓ Sistem inteligent de sortare implementat cu succes\n');
fprintf('✓ Rețea neurală antrenată cu acuratețea de %.2f%%\n', accuracy);
fprintf('✓ Testarea pe %d obiecte cu acuratețea de %.1f%%\n', length(test_objects), final_accuracy);
fprintf('✓ Senzori virtuali pentru culoare și dimensiuni implementați\n');
fprintf('✓ Control adaptiv al vitezei benzii implementat\n');
fprintf('✓ Vizualizări și rapoarte generate\n');
fprintf('✓ Toate fișierele salvate pentru utilizare ulterioară\n');

fprintf('\nProiectul a fost finalizat cu succes!\n');
