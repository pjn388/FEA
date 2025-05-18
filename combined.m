clear all; clc;


run("units.m") % load units
% Material properties
E = 200 *GPa;
Yeild = 345 * MPa;

% ITERATION 1

% beams supports
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(350)/50x25x1.6_RHS/
I_beam = 70200*mm^4;
A_beam = 223 *mm^2;
r_beam = 25 *mm;

% beam connectors
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(450)/50x20x1.6_RHS/
A_connect = 207*mm^2;

% hydrolic
d_hydrolic = 20*mm;

disp("iteration 1")
do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E, 'Iteration 1')

clearvars -except in mm GPa lb g E



% ITERATION 2

% beams supports
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(350)/100x50x2.0_RHS/
I_beam = 750000 *mm^4;
A_beam = 574 *mm^2;
r_beam = 50 *mm;

% beam connectors
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(450)/50x20x1.6_RHS/
A_connect = 207*mm^2;

% hydrolic
d_hydrolic = 20*mm;

disp("iteration 2")
do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E, 'Iteration 2')

clearvars -except in mm GPa lb g E




% ITERATION 3 (This is the one that we will be using)

% beams supports
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(350)/200x100x4.0_RHS
I_beam = 11900000*mm^4;
A_beam = 2280*mm^2;
r_beam = 100*mm;

% beam connectors
% https://beamdimensions.com/database/Australian/Steel_(250_Grade)/Rect_hollow_sections_(450)/50x20x1.6_RHS/
A_connect = 207*mm^2;

% hydrolic
d_hydrolic = 20*mm;

disp("iteration 3")
do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E, 'Iteration 3')

clearvars -except in mm GPa lb g E



function do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E, name)
    run("units.m") % load units

    % specify node locations
    node_A = PinnedNode2D((0       )*in     ,(0       )*in);
    node_B = Node2D(     (72      )*in     ,(24+30   )*in);
    node_C = PinnedNode2D((0       )*in     ,(24      )*in);
    node_D = Node2D(     (72      )*in     ,(24+30+24)*in);
    node_E = Node2D(     (32      )*in     ,(24+24   )*in);
    node_F = Node2D(     (32      )*in     ,(24      )*in);
    node_G = PinnedNode2D((32+30   )*in     ,(24-30   )*in);

    nodes = {node_A, node_B, node_C, node_D, node_E, node_F, node_G};
    node_names = {"node_A", "node_B", "node_C", "node_D", "node_E", "node_F", "node_G"};

    % hydrolic support params
    A_hydrolic = pi*d_hydrolic^2/4;



    % define the elements
    element_AF     = FrameElement(node_A          ,node_F     ,A_beam           ,E   ,I_beam,r_beam);
    element_FB     = FrameElement(node_F          ,node_B     ,A_beam           ,E   ,I_beam,r_beam);
    element_CE     = FrameElement(node_C          ,node_E     ,A_beam           ,E   ,I_beam,r_beam);
    element_ED     = FrameElement(node_E          ,node_D     ,A_beam           ,E   ,I_beam,r_beam);
    element_EF     = TrussElement(node_E          ,node_F     ,A_connect        ,E     );
    element_BD     = TrussElement(node_B          ,node_D     ,A_connect        ,E);
    element_FG     = TrussElement(node_F          ,node_G     ,A_hydrolic       ,E     );

    elements = {element_AF, element_FB, element_CE, element_ED, element_EF, element_FG, element_BD};
    element_names = {"element_AF", "element_FB", "element_CE", "element_ED", "element_EF", "element_FG", "element_BD"};
    
    % Not used as alternative of solving platform forces was used instead as this was the reccommended method.
    % define constrinsts for MPC solving of complex systems
    % we have split the structure into a mechanism and a platform and are constraining the solutions between these 2
    constraints = {
        % Constraint(node_B, node_B_p, ["u", "v"]),... % B,B_p
        % Constraint(node_D, node_D_p, ["u", "v"])     % D,D_p
    };

    node_B.apply_loading(["u", "v"], [-5555.1, -2893]);
    node_D.apply_loading(["u", "v"], [5555.1, -1544]);

    % Do all the calculations with this configured setup
    run("main.m")

    % Find and record maximum stresses
    max_stresses = zeros(1, numel(elements));
    for i = 1:numel(elements)
        stress_states = elements{i}.get_solution_states();

        max_stress = 0;
        for j = 1:numel(stress_states)
            stress_value = stress_states{j};
            if isa(stress_value, 'char')
                stress_value = str2double(stress_value);
            end

            if ~isnumeric(stress_value) || isempty(stress_value)
                continue;
            end
            % standard find largets value check
            if abs(stress_value) > abs(max_stress)
                max_stress = stress_value;
            end
        end
        max_stresses(i) = max_stress;

        disp(element_names{i}+" max stress: "+render_stress(max_stress))
    end

end
