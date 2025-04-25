clear all; clc;

% Conversion to unit not invented by drunk mathematicians rolling dice
in = 0.0254;
mm = 10^-3;
lb = 0.453592;
g = 9.81;


% specify node locations
node_A = FixedNode2D((0       )*in     ,(0       )*in);
node_B_m = Node2D(     (72      )*in     ,(24+30   )*in);
node_C = FixedNode2D((0       )*in     ,(24      )*in);
node_D_m = Node2D(     (72      )*in     ,(24+30+24)*in);
node_E = Node2D(     (32      )*in     ,(24+24   )*in);
node_F = Node2D(     (32      )*in     ,(24      )*in);
node_G = FixedNode2D((32+30   )*in     ,(24-30   )*in);

node_H = Node2D(     (72+30   )*in     ,(24+30   )*in);
node_I = Node2D(     (72+30+30)*in     ,(24+30   )*in);
node_B_p = Node2D(     (72      )*in     ,(24+30   )*in);
node_D_p = Node2D(     (72      )*in     ,(24+30+24)*in);


nodes ={node_A, node_B_m, node_C, node_D_m, node_E, node_F, node_G, node_H, node_I, node_B_p, node_D_p};


% temp element properties
A = 3*mm*3*mm; E = 2.7*10^9; I = 0.0001;


% define the elements
element_AF     = FrameElement(node_A          ,node_F     ,A       ,E   ,I);
element_FB_m   = FrameElement(node_F          ,node_B_m   ,A       ,E   ,I);
element_CE     = FrameElement(node_C          ,node_E     ,A       ,E   ,I);
element_ED_m   = FrameElement(node_E          ,node_D_m   ,A       ,E   ,I);
element_EF     = TrussElement(node_E          ,node_F     ,A       ,E     );
element_FG     = TrussElement(node_F          ,node_G     ,A       ,E     );
element_D_mB_m     = TrussElement(node_D_m          ,node_B_m     ,A       ,E     );

element_B_pD_p = FrameElement(node_B_p        ,node_D_p        ,A       ,E   ,I);
element_B_pH   = FrameElement(node_B_p        ,node_H     ,A       ,E   ,I);
element_HI     = FrameElement(node_H          ,node_I     ,A       ,E   ,I);

elements = {element_AF, element_FB_m, element_CE, element_ED_m, element_EF, element_FG, element_B_pD_p, element_B_pH, element_HI};


% define constrinsts for MPC solving of complex systems
% we have split the structure into a mechanism and a platform and are constraining the displacements between these 2
constraints = {
    Constraint(node_B_m, node_B_p, ["u", "v"]),... % B_,m,B_p
    Constraint(node_D_m, node_D_p, ["u", "v"])     % d_,m,d_p
};

% now that the structure and thus the dof for each node have been defined we can apply a loading state to the dof
node_B_p.apply_loading(["u", "v"], [0, -300 * lb * g]); % B_p
node_H.apply_loading(["u", "v"], [0, -400 * lb * g]); % H
node_I.apply_loading(["u", "v"], [0, -300 * lb * g]); % I


% Do all the calculations with this configured setup
run("main.m")


% get stresses

element_HI.get_stress(0, 0)