function [M_battery]=mass_energy(x)
%====================================================================== 
% Calculates the mass of the battery section of an AUV. 
% It assumes a material density of 7870 kg/m3 (HY-80 Steel).
%====================================================================== 
Diameter=x(1);   Loa=x(2);    nf=x(3);   na=x(4); 
ehp=power_auv(x);      %estimated horse power 
t=hull_thickness(x);   %hull thickness (m)
rho_sea=1025;          %sea water density (kg/m^3)   
rho_material=7870;     %HY-80 Steel:7870(kg/m^3)    
PW=12;                 %estimated engine power/weight ratio (hp/kg)

format long;
V_outer=volume_hull_2(x);    %Outer Volume of Hull (m^3)
inner_diameter=Diameter-2*t; %Inner Diameter (m)
loa_inner=Loa-2*t;           %Inner Length (m)
V_inner=volume_hull_2([inner_diameter loa_inner nf na]); %Inner Volume (m)

M_tot=V_outer*rho_sea;                 %The total mass of the AUV (~neutrally buoyant)
M_hull=(V_outer-V_inner)*rho_material; %The mass of the hull   (kg) 
M_prop=(1/PW)*ehp;          %The mass of the electric motor    (kg)
M_append=0.05*M_tot;        %The mass of the appendages        (kg)
M_payload=0.4*M_tot;        %The mass of the payload           (kg)
M_tether=Tether(x(6));      %The mass of the tether            (kg)
M_battery=M_tot-M_hull-M_prop-M_append-M_payload-M_tether;
%The mass of the energy section equals to the total mass minus the 
%masss of the hull, the propulsion system, the appendages and the payload
return