%% CONFIGURAREA MODELULUI SIMULINK PENTRU SISTEMUL DE SORTARE
% Script pentru crearea modelului Simulink automat

function create_conveyor_sorting_simulink_model()
    fprintf('=== CREAREA MODELULUI SIMULINK ===\n');
    
    % Numele modelului
    model_name = 'SistemSortareBandaTransportoare';
    
    % Crearea unui model nou
    new_system(model_name);
    open_system(model_name);
    
    %% ADĂUGAREA BLOCURILOR PRINCIPALE
    
    % 1. Generatorul de obiecte (Pulse Generator pentru simularea detectării)
    add_block('simulink/Sources/Pulse Generator', [model_name '/GeneratorObiecte']);
    set_param([model_name '/GeneratorObiecte'], 'Position', [50, 50, 100, 80]);
    set_param([model_name '/GeneratorObiecte'], 'Period', '2');
    set_param([model_name '/GeneratorObiecte'], 'PulseWidth', '50');
    
    % 2. Blocul pentru senzorul de culoare (Random Number pentru simulare)
    add_block('simulink/Sources/Random Number', [model_name '/SenzorCuloare_R']);
    set_param([model_name '/SenzorCuloare_R'], 'Position', [150, 30, 200, 60]);
    set_param([model_name '/SenzorCuloare_R'], 'Mean', '128');
    set_param([model_name '/SenzorCuloare_R'], 'Variance', '50');
    
    add_block('simulink/Sources/Random Number', [model_name '/SenzorCuloare_G']);
    set_param([model_name '/SenzorCuloare_G'], 'Position', [150, 70, 200, 100]);
    set_param([model_name '/SenzorCuloare_G'], 'Mean', '128');
    set_param([model_name '/SenzorCuloare_G'], 'Variance', '50');
    
    add_block('simulink/Sources/Random Number', [model_name '/SenzorCuloare_B']);
    set_param([model_name '/SenzorCuloare_B'], 'Position', [150, 110, 200, 140]);
    set_param([model_name '/SenzorCuloare_B'], 'Mean', '128');
    set_param([model_name '/SenzorCuloare_B'], 'Variance', '50');
    
    % 3. Blocul pentru senzorul de dimensiuni
    add_block('simulink/Sources/Random Number', [model_name '/SenzorDimensiuni_L']);
    set_param([model_name '/SenzorDimensiuni_L'], 'Position', [150, 160, 200, 190]);
    set_param([model_name '/SenzorDimensiuni_L'], 'Mean', '0.15');
    set_param([model_name '/SenzorDimensiuni_L'], 'Variance', '0.05');
    
    add_block('simulink/Sources/Random Number', [model_name '/SenzorDimensiuni_W']);
    set_param([model_name '/SenzorDimensiuni_W'], 'Position', [150, 200, 200, 230]);
    set_param([model_name '/SenzorDimensiuni_W'], 'Mean', '0.15');
    set_param([model_name '/SenzorDimensiuni_W'], 'Variance', '0.05');
    
    add_block('simulink/Sources/Random Number', [model_name '/SenzorDimensiuni_H']);
    set_param([model_name '/SenzorDimensiuni_H'], 'Position', [150, 240, 200, 270]);
    set_param([model_name '/SenzorDimensiuni_H'], 'Mean', '0.10');
    set_param([model_name '/SenzorDimensiuni_H'], 'Variance', '0.03');
    
    % 4. Multiplexer pentru combinarea semnalelor de la senzori
    add_block('simulink/Signal Routing/Mux', [model_name '/MuxSenzori']);
    set_param([model_name '/MuxSenzori'], 'Position', [250, 130, 270, 200]);
    set_param([model_name '/MuxSenzori'], 'Inputs', '6');
    
    % 5. Blocul MATLAB Function pentru rețeaua neurală
    add_block('simulink/User-Defined Functions/MATLAB Function', [model_name '/ReteaNeuronala']);
    set_param([model_name '/ReteaNeuronala'], 'Position', [320, 130, 400, 200]);
    
    % 6. Demultiplexer pentru ieșirile clasificării
    add_block('simulink/Signal Routing/Demux', [model_name '/DemuxClasificare']);
    set_param([model_name '/DemuxClasificare'], 'Position', [450, 130, 470, 200]);
    set_param([model_name '/DemuxClasificare'], 'Outputs', '3');
    
    % 7. Controlul vitezei benzii (PID Controller)
    add_block('simulink/Continuous/PID Controller', [model_name '/ControlViteza']);
    set_param([model_name '/ControlViteza'], 'Position', [520, 100, 570, 130]);
    
    % 8. Modelul benzii transportoare (Transfer Function)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/BandaTransportoare']);
    set_param([model_name '/BandaTransportoare'], 'Position', [620, 100, 680, 130]);
    set_param([model_name '/BandaTransportoare'], 'Numerator', '[1]');
    set_param([model_name '/BandaTransportoare'], 'Denominator', '[1 0.5]');
    
    % 9. Blocuri pentru afișare
    add_block('simulink/Sinks/Scope', [model_name '/AfisareClasificare']);
    set_param([model_name '/AfisareClasificare'], 'Position', [600, 150, 650, 180]);
    
    add_block('simulink/Sinks/To Workspace', [model_name '/SalvareDate']);
    set_param([model_name '/SalvareDate'], 'Position', [600, 200, 650, 230]);
    set_param([model_name '/SalvareDate'], 'VariableName', 'rezultate_simulare');
    
    %% CONECTAREA BLOCURILOR
    
    try
        % Conectarea senzorilor la multiplexer
        add_line(model_name, 'SenzorCuloare_R/1', 'MuxSenzori/1');
        add_line(model_name, 'SenzorCuloare_G/1', 'MuxSenzori/2');
        add_line(model_name, 'SenzorCuloare_B/1', 'MuxSenzori/3');
        add_line(model_name, 'SenzorDimensiuni_L/1', 'MuxSenzori/4');
        add_line(model_name, 'SenzorDimensiuni_W/1', 'MuxSenzori/5');
        add_line(model_name, 'SenzorDimensiuni_H/1', 'MuxSenzori/6');
        
        % Conectarea multiplexer-ului la rețeaua neurală
        add_line(model_name, 'MuxSenzori/1', 'ReteaNeuronala/1');
        
        % Conectarea rețelei neuronale la demultiplexer
        add_line(model_name, 'ReteaNeuronala/1', 'DemuxClasificare/1');
        
        % Conectarea la controlul vitezei și afișare
        add_line(model_name, 'DemuxClasificare/1', 'ControlViteza/1');
        add_line(model_name, 'ControlViteza/1', 'BandaTransportoare/1');
        add_line(model_name, 'DemuxClasificare/1', 'AfisareClasificare/1');
        add_line(model_name, 'DemuxClasificare/1', 'SalvareDate/1');
    catch ME
        fprintf('Avertisment: Unele conexiuni nu au putut fi realizate automat: %s\n', ME.message);
    end
    
    %% CONFIGURAREA PARAMETRILOR DE SIMULARE
    set_param(model_name, 'StopTime', '60');  % Simulare pentru 60 secunde
    set_param(model_name, 'Solver', 'ode45'); % Solver Runge-Kutta
    set_param(model_name, 'MaxStep', '0.01'); % Pasul maxim de simulare
    
    % Salvarea modelului
    save_system(model_name);
    fprintf('Modelul Simulink \"%s\" a fost creat cu succes\n', model_name);
    
    fprintf('\nPentru a completa implementarea:\n');
    fprintf('1. Deschideți blocul \"ReteaNeuronala\" prin dublu-click\n');
    fprintf('2. Înlocuiți conținutul cu codul pentru clasificare\n');
    fprintf('3. Rulați simularea pentru a vedea rezultatele\n');
    fprintf('\nModelul Simulink este gata pentru utilizare!\n');
    
end

% Apelarea funcției pentru crearea modelului
create_conveyor_sorting_simulink_model();
