clear all; clc; clear classes;
run("init.m")
run("units.m") % load units


% set(0,'DefaultFigureVisible','on')
% set(0,'DefaultFigureVisible','off')


% Material properties
E = 200 *GPa;
Yeild = 345 * MPa;



name = "Alternative approach";

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

% platform
I_platform = 11900000*mm^4;
A_platform = 2280*mm^2;

disp("iteration 3")

% specify node locations
% mechanism
node_A = PinnedNode2D((0       )*in     ,(0       )*in);
node_B_m = Node2D(     (72      )*in     ,(24+30   )*in);
node_C = PinnedNode2D((0       )*in     ,(24      )*in);
node_D_m = Node2D(     (72      )*in     ,(24+30+24)*in);
node_E = Node2D(     (32      )*in     ,(24+24   )*in);
node_F = Node2D(     (32      )*in     ,(24      )*in);
node_G = PinnedNode2D((32+30   )*in     ,(24-30   )*in);

% platoform
node_H = Node2D(     (72+30   )*in     ,(24+30   )*in);
node_I = Node2D(     (72+30+30)*in     ,(24+30   )*in);
node_B_p = Node2D(     (72      )*in     ,(24+30   )*in);
node_D_p = Node2D(     (72      )*in     ,(24+30+24)*in);

nodes = {node_A, node_B_m, node_C, node_D_m, node_E, node_F, node_G, node_H, node_I, node_B_p, node_D_p};
node_names = {"node_A", "node_B_m", "node_C", "node_D_m", "node_E", "node_F", "node_G", "node_H", "node_I", "node_B_p", "node_D_p"};

% hydrolic support params
A_hydrolic = pi*d_hydrolic^2/4;


material = ElasticMaterial("Steel", E);


% define the elements
% mechanism
element_AF     = FrameElement(node_A          ,node_F     ,A_beam           ,material   ,I_beam,r_beam);
element_FB_m     = FrameElement(node_F          ,node_B_m     ,A_beam           ,material   ,I_beam,r_beam);
element_CE     = FrameElement(node_C          ,node_E     ,A_beam           ,material   ,I_beam,r_beam);
element_ED_m     = FrameElement(node_E          ,node_D_m     ,A_beam           ,material   ,I_beam,r_beam);
element_EF     = TrussElement(node_E          ,node_F     ,A_connect        ,material     );
element_FG     = TrussElement(node_F          ,node_G     ,A_hydrolic       ,material     );

% platoform
element_B_pD_p =FrameElement(node_B_p        ,node_D_p        ,A_platform       ,material   ,I_platform,10*mm);
element_B_pH   =FrameElement(node_B_p        ,node_H          ,A_platform       ,material   ,I_platform,10*mm);
element_HI     =FrameElement(node_H          ,node_I          ,A_platform       ,material   ,I_platform,10*mm);

elements = {element_AF, element_FB_m, element_CE, element_ED_m, element_EF, element_FG, element_B_pD_p, element_B_pH, element_HI};
element_names = {"element_AF", "element_FB_m", "element_CE", "element_ED_m", "element_EF", "element_FG", "element_BD", "element_B_pD_p", "element_B_pH", "element_HI"};

% define constrinsts for MPC solving of complex systems
% we have split the structure into a mechanism and a platform and are constraining the solutions between these 2
constraints = {
    Constraint(node_B_m, node_B_p, ["u", "v"]),... % B,B_p
    Constraint(node_D_m, node_D_p, ["u", "v"])     % D,D_p
};


node_B_p.apply_loading(["u", "v"], [0, -300 * lb * g]); % B_p
node_H.apply_loading(["u", "v"], [0, -400 * lb * g]); % H
node_I.apply_loading(["u", "v"], [0, -300 * lb * g]); % I


% % Do all the calculations with this configured setup
% run("main.m")

fea_solve(nodes, elements, constraints)

% Find and record maximum stresses
max_stresses = zeros(1, numel(elements));
for i = 1:numel(elements)
    stress_states = elements{i}.get_stress_states();

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
