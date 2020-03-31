function [TetherMass,TetherVolume]= Tether(length)
%====================================================================== 
%This function calculates the mass of a 
%Dyneema tether with a densiy of 1000kg/m^3
%given its length
%====================================================================== 
TetherLength = length;    % (m)
TetherDiameter = .0144*2; % 200% for wires inside (m)
TetherVolume = pi/4*TetherDiameter^2*TetherLength; %(m^3)
TetherDensity = 1000;                    %(kg/m^3)
TetherMass = TetherVolume*TetherDensity; %(kg)
end

