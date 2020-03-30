function [Cost,Batterycapacity,SA,ACd,PowerWatts,range,M_leftover] = cost(D,V,T)
%This function gives an estimated cost for an AUV given
% Input  D = Diameter (m)
%        V = Velocity (m/s)
%        T = Tether Length (m)
% Output Cost ($)
%        Batterycapacity (kWh)
%        SA = Surface Area (m)
%        ACd = Area*Cd (m) 
%        PowerWatts (W)
%        Range (km) 

M_Kite = 3000; %Mass of Kite kg 
L = 8.5*D;        %L/D Ratio of 8.5 (m)
nf = 1;           %fore form factor
na = 1;           %aft form factor
Velocity = V;     %(m/s)
TetherLenght = T; %(m)
x = [D,L,na,nf,Velocity,TetherLenght];

t = hull_thickness(x) %(m) Hull Thickness

[ehp,SA,ACd]=power_auv(x);  %HP
PowerWatts=ehp*745.7;       %Watts
[range,Batterycapacity,duration,M_leftover]=range_auv(x); %(km,Wh,hr)

%Motor Cost using Horsepower
MotorMultipler = 200;            %($/HP)
CostMotor = ehp*MotorMultipler;  %($)

%Battery Cost using Capaity
BattyMultipler = 1136*((.746*(ehp*duration))^(-0.317)); %($/kWh)
Batterycapacity = Batterycapacity/1000;       %(kWh)
CostBattery = Batterycapacity*BattyMultipler; %($)

%Hull Cost Using Material Ammount
MaterialMultipler = 34700; %($/m^3)
HullVolume = volume_hull_2(x)-...
             volume_hull_2([x(1)-2*t,x(2)-2*t,x(3),x(4)]); %(m^3)
CostHull = HullVolume*MaterialMultipler; %Hull cost ($)

%Teather Cost Using Length
TetherMultipler = 13;     % ($/m)
TetherLength = x(6);
CostTether = TetherLength*TetherMultipler; %($)

Cost = CostMotor+CostBattery+CostHull+CostTether;
if imag(Cost)~=0
    fprintf('Something Does Not Fit')
    Cost = 0;
end
if M_Kite>M_leftover
    fprintf('Kite Does Not Fit')
    Cost = 0;
end
return
