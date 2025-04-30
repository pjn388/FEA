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

do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E)
% Note: Too week

clearvars -except in mm GPa lb g E



% ITERATION 2 (This is the one that we will be using)

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

do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E)
% Note too strong

clearvars -except in mm GPa lb g E



% ITERATION 3

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

do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E)
% Note: just right

clearvars -except in mm GPa lb g E





function do_iteration(I_beam, A_beam, r_beam, A_connect, d_hydrolic, E)
    run("units.m") % load units

    % specify node locations
    node_A = PinnedNode2D((0       )*in     ,(0       )*in);
    node_B = Node2D(     (72      )*in     ,(24+30   )*in);
    node_C = PinnedNode2D((0       )*in     ,(24      )*in);
    node_D = Node2D(     (72      )*in     ,(24+30+24)*in);
    node_E = Node2D(     (32      )*in     ,(24+24   )*in);
    node_F = Node2D(     (32      )*in     ,(24      )*in);
    node_G = PinnedNode2D((32+30   )*in     ,(24-30   )*in);

    % node_H = Node2D(     (72+30   )*in     ,(24+30   )*in);
    % node_I = Node2D(     (72+30+30)*in     ,(24+30   )*in);
    % node_B_p = Node2D(     (72      )*in     ,(24+30   )*in);
    % node_D_p = Node2D(     (72      )*in     ,(24+30+24)*in);

    nodes ={node_A, node_B, node_C, node_D, node_E, node_F, node_G};

    % Node2D(89fb8f90): x = 1.8288, y = 1.3716, dof = [theta, u, v], loading = [0, -5555.1, -2893], displacement = [-0.013625, 0.0078102, -0.010698]
    % Node2D(3f5d9647): x = 1.8288, y = 1.3716, dof = [theta, u, v], loading = [0, -5555.1, -2893], displacement = [-0.013645, 0.0077927, -0.010741]

    % hydrolic support params
    A_hydrolic = pi*d_hydrolic^2/4;



    % define the elements
    element_AF     = FrameElement(node_A          ,node_F     ,A_beam       ,E   ,I_beam, r_beam);
    element_FB   = FrameElement(node_F          ,node_B   ,A_beam       ,E   ,I_beam, r_beam);
    element_CE     = FrameElement(node_C          ,node_E     ,A_beam       ,E   ,I_beam, r_beam);
    element_ED   = FrameElement(node_E          ,node_D   ,A_beam       ,E   ,I_beam, r_beam);
    element_EF     = TrussElement(node_E          ,node_F     ,A_connect       ,E     );
    element_BD     = TrussElement(node_B, node_D, A_connect, E);

    element_FG     = TrussElement(node_F          ,node_G     ,A_hydrolic       ,E     );
    % element_DB     = TrussElement(node_D          ,node_B     ,A       ,E     ); % i dont think this is neccessary

    % element_B_pD_p = FrameElement(node_B_p        ,node_D_p        ,A       ,E   ,I, 10*mm);
    % element_B_pH   = FrameElement(node_B_p        ,node_H     ,A       ,E   ,I, 10*mm);
    % element_HI     = FrameElement(node_H          ,node_I     ,A       ,E   ,I, 10*mm);

    elements = {element_AF, element_FB, element_CE, element_ED, element_EF, element_FG, element_BD};

    
    % Not used as alternative of solving platform forces as this was the reccommended method.
    % define constrinsts for MPC solving of complex systems
    % we have split the structure into a mechanism and a platform and are constraining the displacements between these 2
    constraints = {
        % Constraint(node_B, node_B_p, ["u", "v"]),... % B,B_p
        % Constraint(node_D, node_D_p, ["u", "v"])     % D,D_p
    };

    node_B.apply_loading(["u", "v"], [-5555.1, -2893])
    node_D.apply_loading(["u", "v"], [5555.1, -1544])


    % now that the structure and thus the dof for each node have been defined we can apply a loading state to the dof
    % node_B_p.apply_loading(["u", "v"], [0, -300 * lb * g]); % B_p
    % node_H.apply_loading(["u", "v"], [0, -400 * lb * g]); % H
    % node_I.apply_loading(["u", "v"], [0, -300 * lb * g]); % I


    % Do all the calculations with this configured setup
    run("main.m")
end
