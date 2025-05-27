clear all; clc;

run("init.m")
run("units.m") % load units
set(0,'DefaultFigureVisible','on')



k_x = 0.0605 * W/(mm*degC);
k_y = k_x;
material = ThermalMaterial("Steel Plate", k_x, k_y)

q_dot = 0;


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





element_5 = ThermalTriangleElement(node_6, node_7, node_11, material, q_dot);
element_5.apply_boundary(HeatFluxBoundary(node_6, node_11, 0.05 * W/mm^2))

element_6 = ThermalTriangleElement(node_7, node_8, node_11, material, q_dot);
element_6.apply_boundary(FixedTemperatureBoundary(node_8, node_11, 300*degC));


element_1 = ThermalRectangleElement(node_1, node_2, node_6, node_7, material, q_dot);
element_1.apply_boundary(FixedTemperatureBoundary(node_1, node_2, 300*degC));

element_2 = ThermalRectangleElement(node_2, node_3, node_7, node_8, material, q_dot);
element_2.apply_boundary(FixedTemperatureBoundary(node_2, node_3, 300*degC));
element_2.apply_boundary(ConvectionBoundary(node_3, node_8, 50*W/(mm^2*degC), 22*degC));

A = 10*mm * 10*mm;
p = 2*10*mm + 2*10*mm;
element_3 = Thermal1D(node_3, node_4, material, A, p, 0, 0, 0, 22*degC);
element_4 = Thermal1D(node_4, node_5, material, A, p, 0, 0, 500*W/(mm^2*degC), 22*degC);

element_7 = Thermal1D(node_8, node_9, material, A, p, 0, 0, 0, 22*degC);
element_8 = Thermal1D(node_9, node_10, material, A, p, 0, 0, 500*W/(mm^2*degC), 22*degC);



nodes = {node_1, node_2, node_3, node_4, node_5, node_6, node_7, node_8, node_9, node_10, node_11};
elements = {element_1, element_2, element_3, element_4, element_5, element_6, element_7, element_8};


% nodes = {node_1, node_2, node_6, node_7};
% elements = {element_1};
constraints = {};


disp("GO")

% Do all the calculations with this configured setup
fea_solve(nodes, elements, constraints)
