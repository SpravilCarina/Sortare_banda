% Crează și deschide noul model
modelName = 'SortareBandaRobot3D';
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

% Încarcă librăria Simscape Multibody
load_system('sm_lib');

% Adaugă blocurile principale
add_block('sm_lib/Frames and Transforms/World Frame', ...
    [modelName, '/WorldFrame'], 'Position', [50, 50, 150, 100]);
add_block('simscape/Utilities/Solver Configuration', ...
    [modelName, '/SolverConfig'], 'Position', [50, 150, 150, 200]);
add_block('sm_lib/Frames and Transforms/Ground', ...
    [modelName, '/Ground'], 'Position', [50, 250, 100, 300]);

% Soliduri
add_block('sm_lib/Body Elements/Solid', ...
    [modelName, '/Solid_Banda'], 'Position', [250, 50, 350, 100]);
add_block('sm_lib/Body Elements/Solid', ...
    [modelName, '/Solid_Obiect'], 'Position', [250, 150, 350, 200]);
add_block('sm_lib/Body Elements/Solid', ...
    [modelName, '/Solid_Brat'], 'Position', [250, 250, 350, 300]);

% Articulații Joints
add_block('sm_lib/Joints/Prismatic Joint', ...
    [modelName, '/PrismaticJoint'], 'Position', [450, 150, 550, 200]);
add_block('sm_lib/Joints/Revolute Joint', ...
    [modelName, '/RevoluteJoint'], 'Position', [450, 250, 550, 300]);

% Control semnale
add_block('simulink/Sources/Step', ...
    [modelName, '/StepViteza'], 'Position', [600, 150, 640, 190]);
add_block('sm_lib/Utilities/Simulink-PS Converter', ...
    [modelName, '/PSConv_Viteza'], 'Position', [690, 150, 740, 190]);
add_block('simulink/Sources/Constant', ...
    [modelName, '/ConstRotatie'], 'Position', [600, 270, 640, 310]);
add_block('sm_lib/Utilities/Simulink-PS Converter', ...
    [modelName, '/PSConv_Rotatie'], 'Position', [690, 270, 740, 310]);

% Conexiuni semnale de control
add_line(modelName, 'StepViteza/1', 'PSConv_Viteza/1');
add_line(modelName, 'ConstRotatie/1', 'PSConv_Rotatie/1');

% Salvează și deschide modelul
save_system(modelName);
open_system(modelName);

disp('✅ Model SortareBandaRobot3D creat cu Simscape Multibody!');
disp('⚠️ Acum trebuie să faci conexiunile manual în Simulink:');
disp('1. Activează porturile R pentru fiecare Solid (dublu-click > Frames > Show Port R)');
disp('2. Conectează WorldFrame/W la fiecare Solid/R');
disp('3. Conectează Ground la Solid_Banda');
disp('4. Conectează Joints între soliduri');
disp('5. Conectează PSConv la Joints (porturi v și q)');
disp('6. Rulează simularea!');
