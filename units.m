% All units to si units conversion factors
% Conversion to unit not invented by drunk mathematicians rolling dice
% Standard constants values


% Base units that everything can be converted to, have a factor of 1. Usefull only for the purposes of clear code;
m = 1;
kg = 1;
s = 1;
A = 1;
K = 1;
mol = 1;
candela = 1;

% gravity
g = 9.81 * m/s^2;


% length
in = 0.0254*m;
mm = 10^-3*m;

% volume
L = 10^-3 *m^3;
mL = 10^-3 *L^3;

% mass
lb = 0.453592*kg;

% force
N = kg*m/s^2;

% Pressure
Pa = N/m^2;
kPa = 10^3*Pa;
MPa = 10^6*Pa;
GPa = 10^9*Pa;

% Torque
Nm = N*m;

% Energy
J = Nm;
kJ = 10^3*J;
MJ = 10^6*J;
GJ = 10^9*J;

W = J/s;
kW = 10^3*W;
MW = 10^6*W;
GW = 10^9*W;

% temp
degC = K; % this is multiplicative scalr so it doesnt account for the offset of 273.15