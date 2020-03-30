function [range,Etot,duration,M_leftover]=range_auv(x)  
%====================================================================== 
% This function calculates the range of an AUV. 
% A hybrid energy system is assumed with an energy density of 0.35 kWh/kg.
% It assumes a hotel load of 600 watts. 
% It calculates the overall propulsion coefficient PC
%======================================================================    
Velocity=x(5);        
format long;   

energy_density=0.35; %kWh/kg for battery  
ehp=power_auv(x);    %Effective Power in Horse Power 
epw=ehp*745.7;       %Effective Power in Watts

nH=1.0;  %hull efficiency (1-t)/(1-w)
nR=0.98; %relative rotative efficiency (open water - hull wake)
nO=0.70; %open water efficiency (propeller type, diameter, rpm etc) 
nM=0.95; %machinery efficiency (rotor, bearings, shaft) 
[M_battery]=mass_energy(x); %(kg)
Etot=1000*M_battery*energy_density;      %Wh ((kg*kWh/kg)*1000)
p_hotel=600;                                  %Hotel load (Watt)
n_prop=nH*nR*nO*nM;                           %overall propulsive efficiency
duration=Etot*n_prop/(epw+p_hotel*n_prop);    %in hours (Wh/W)
range=(duration*Velocity*3.6);                %in km (60*60/1000)

if range>5 %Sets range around 5 km
    while range>5
        Etot=Etot-Etot*.1;                            %in Wh
        duration=Etot*n_prop/(epw+p_hotel*n_prop);    %in hours (Wh/W)
        range=(duration*Velocity*3.6);                %in km 
    end
end
M_leftover = M_battery-Etot/(energy_density*1000); %leftover mass for kite (kg)
Etot/(energy_density*1000)
return

