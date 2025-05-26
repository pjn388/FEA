addpath(genpath('elements'));
addpath(genpath('nodes'));
addpath(genpath('materials'));
addpath(genpath('boundaries'));

RestrictedNode(0, 0, ["u", "v"]);
Element2D({Node2D(0, 0), Node2D(0, 0)}, ["None"], 0)
Material("test");
Thermal()


