function [Power,S,ACd]=power_auv(x)  
%======================================================================
% This function calculates the power needed for an AUV. 
% I use a cylindrical hull following MIT model (Jackson 1992). 
% It assumes a body of revolution with a length/diameter (L/D) 
% ratio of 8.5 and a maximum diameter at 0.4L. The entrance has a length,  
% Lf=2.4D. The run or after end has a length, La=3.6D. %
%====================================================================== 
Diameter=x(1); Loa=x(2); nf=x(3); na=x(4); Velocity=x(5);       

format long; 
ca=0.0004;            %Roughness value (openings,fouling,ect...)
rho=1025;             %Sea water density (kg/m^3)
mhu=0.00108;          %Dynamic viscosity seawater (kg/(m*s)) 
Re=Loa*Velocity*rho/mhu;  %Reynold's number 
S=surface_hull_2(x);      %Wetted surface area (m^2)
cf=0.075/((log10(Re)-2)^2); %Bare-hull skin friction coefficient
formfac=1+0.5*Diameter/Loa+3*(Diameter/Loa)^3;      %The coefficient of viscous resistance(multiplied by cf) 
cv=(1+formfac)*cf;      %viscous resistance=tangential (skin friction)+= normal (viscous pressure drag) 
ct = cv + ca + 1;
Rapp=1/1000*Loa*Diameter;                           %Account for appendages - Vlahopoulos Hart 
Rt=1/2*rho*Velocity^2*(S*ct+Rapp);     %Resistance (N)
ACd = (S*(cf*formfac+ca)+Rapp);
Power=Rt*Velocity;   %Power (Nm/s) (watts)

return
