clear all; clc;

run("init.m")
run("units.m") % load units
set(0,'DefaultFigureVisible','on')



k_x = 0.0605 * W/(mm*degC);
k_y = k_x;
material = TermalMaterial("Steel Plate", k_x, k_y)

q_dot = 1;


node_1  = Node2D((0)*mm        ,(0)*mm);
node_2  = Node2D((300/2)*mm    ,(0)*mm);
node_3  = Node2D((300)*mm      ,(0)*mm);
node_4  = Node2D((300+100/2)*mm,(0)*mm);
node_5  = Node2D((300+100)*mm  ,(0)*mm);
node_6  = Node2D((0)*mm        ,(200)*mm);
node_7  = Node2D((300/2)*mm    ,(200)*mm);
node_8  = Node2D((300)*mm      ,(200)*mm);
node_9  = Node2D((300+100/2)*mm,(200)*mm);
node_10 = Node2D((300+100)*mm  ,(200)*mm);
node_11 = Node2D((300/2)*mm    ,(200+200)*mm);





element_1 = ThermalTriangleElement(node_6, node_7, node_11, material, q_dot);
element_1.apply_boundary(ConvectionBoundary(node_6, node_7, 100, 30));

element_2 = ThermalTriangleElement(node_7, node_8, node_11, material, q_dot);
element_2.apply_boundary(ConvectionBoundary(node_8, node_11, 100, 30));


nodes = {node_1, node_2, node_3, node_4, node_5, node_6, node_7, node_8, node_9, node_10, node_11};
elements = {element_1, element_2};
constraints = {};


disp("GO")

% Do all the calculations with this configured setup
fea_solve(nodes, elements, constraints)