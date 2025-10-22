%% TESTAREA ȘI VALIDAREA COMPLETĂ A SISTEMULUI DE SORTARE
% Script pentru testarea în diverse scenarii cu raport detaliat

function comprehensive_testing()
    fprintf('=== TESTAREA COMPLETĂ A SISTEMULUI DE SORTARE ===\n');
    
    %% 1. ÎNCĂRCAREA MODELULUI ANTERIOR
    if ~exist('retea_neuronala_sortare.mat', 'file')
        error('Modelul neural nu există. Rulați main_sorting_system.m mai întâi.');
    end
    load('retea_neuronala_sortare.mat', 'net', 'object_types');
    fprintf('✓ Model neural încărcat cu succes\n');
    
    %% 2. DEFINIREA SCENARIILOR DE TESTARE
    test_scenarios = {'Standard', 'Zgomot ridicat', 'Obiecte similare', 'Condiții extreme'};
    noise_levels = [0.02, 0.15, 0.08, 0.25];
    num_tests = [100, 50, 75, 30];
    
    results = struct();
    
    for s = 1:length(test_scenarios)
        scenario = test_scenarios{s};
        noise = noise_levels(s);
        n = num_tests(s);
        
        fprintf('\nTestare scenariu: %s | Zgomot: %.2f | Nr obiecte: %d\n', scenario, noise, n);
        
        [features, true_labels] = generate_test_data(n, noise, s);
        
        % Clasificarea obiectelor
        predicted_labels = cell(n,1);
        for i=1:n
            input_norm = normalize_features(features(i,:), net);
            output = net(input_norm');
            [~, idx] = max(output);
            predicted_labels{i} = object_types{idx};
        end
        
        % Calculul acurateții
        accuracy = sum(strcmp(true_labels, predicted_labels)) / n * 100;
        fprintf('Acuratețe: %.2f%%\n', accuracy);
        
        results.(sprintf('scenario_%d', s)) = struct('name', scenario, 'accuracy', accuracy, ...
            'num_tests', n, 'noise_level', noise);
    end
    
    %% 3. GENERAREA RAPORTULUI
    generate_report(results);
    
    fprintf('\n=== TESTAREA COMPLETĂ A FOST FINALIZATĂ CU SUCCES ===\n');
end

%% FUNCTII SUPLIMENTARE PENTRU TESTARE

function [features, labels] = generate_test_data(n, noise, scenario_flag)
    features = zeros(n,6);
    labels = cell(n,1);
    for i=1:n
        type_id = randi(3);
        switch type_id
            case 1 % Plastic
                base_rgb = [120, 80, 100]; base_dim = [0.1, 0.1, 0.05];
            case 2 % Metal
                base_rgb = [180, 180, 180]; base_dim = [0.15, 0.15, 0.1];
            case 3 % Sticla
                base_rgb = [50, 150, 80]; base_dim = [0.20, 0.20, 0.15];
        end
        
        % Modificari pe baza scenariului
        switch scenario_flag
            case 1 % Standard
                rgb = base_rgb + randn(1,3)*(noise*10);
                dim = base_dim + rand(1,3)*noise*0.05;
            case 2 % Zgomot ridicat
                rgb = base_rgb + randn(1,3)*(noise*50);
                dim = base_dim + rand(1,3)*noise*0.1;
            case 3 % Obiecte similare
                rgb = base_rgb + randn(1,3)*(noise*5);
                dim = base_dim + rand(1,3)*noise*0.02;
            case 4 % Conditii extreme
                rgb = base_rgb .* (0.5 + rand(1,3));
                dim = base_dim .* (0.5 + rand(1,3));
        end
        
        features(i,:) = [rgb, dim];
        labels{i} = {'Plastic','Metal','Sticla'}{type_id};
    end
end

function norm_feat = normalize_features(feat, net)
    % Normalizare simplificata folosind datele de antrenament existente
    % Aici poți adapta după cazul tău
    % Pentru exemplu, împărțim la 255 pentru culori și la 1 pentru dimensiuni
    
    rgb_norm = feat(1:3) / 255;
    dim_norm = feat(4:6); % presupunem dimensiunile sunt deja normalizate
    norm_feat = [rgb_norm dim_norm];
end

function generate_report(results)
    fid = fopen('raport_testare_sistem.txt', 'w');
    fprintf(fid, '=== RAPORT DE TESTARE SISTEM SORTARE ===\n\n');
    for i=1:length(fieldnames(results))
        key = sprintf('scenario_%d', i);
        sc = results.(key);
        fprintf(fid, 'Scenariul %d: %s\n', i, sc.name);
        fprintf(fid, ' - Acuratețe: %.2f%%\n', sc.accuracy);
        fprintf(fid, ' - Număr teste: %d\n', sc.num_tests);
        fprintf(fid, ' - Nivel zgomot: %.2f\n\n', sc.noise_level);
    end
    fclose(fid);
    fprintf('Raportul a fost salvat in raport_testare_sistem.txt\n');
end
