function thickness=hull_thickness(x)
%====================================================================== 
% This function calculates the aproximate hull thickness of an AUV
% given the maximum desired depth of the AUV, it is based on pressure 
% vessel analysis."Pressure Hull Design Methods for Unmanned 
% Underwater Vehicle"
%====================================================================== 
MaxDepth = 1000; %(m)
E=205000;    %Youngs Modulus Steel (MPa)
v=.28;       %Poisions ratio Steel
k=0.3;       %Initial Correcton Factor
g=9.81;      %(m/s^2) gravity acceleration
D=x(1)*10^3; %Diameter (mm)
[~,L]=volume_hull_2(x);
L=L*10^3; %Total Length (mm)

rho_sea=1025;                      %sea water density (kg/m^3)   
Pdesign=-MaxDepth*rho_sea*g*10^-6; %(MPa)
Pcrit = (Pdesign/k);               %Critical Pressure (Mpa)
R = D/2;                           %Radius of mid Section (mm)
syms thick
flag=false;
thickness = double(real(vpasolve(Pcrit==2.42*E*(thick/(2*R))^(5/2)/((1-v^2)^(3/4)*...
                        (L/(2*R)-0.45*(thick/(2*R))^(1/2))),thick))); %thickness (m)
                    
a = 0;
b = 0;
c = 0;
while flag == false
    if thickness<5 
        if k == 0.4 || a == 5
            flag = true;
        end
        a = a+1;
        k=0.4;
        Pcrit = Pdesign/k;
        thickness = double(real(vpasolve(Pcrit==2.42*E*(thick/(2*R))^(5/2)/((-v^2 + 1)^(3/4)*...
                        (L/(2*R) - 0.45*(thick/(2*R))^(1/2))),thick))); %thickness (m)
    elseif 5<=thickness && thickness<=7
        if k == 0.5 || b == 5
            flag = true;
        end
        b = b+1;
        k=0.5;
        Pcrit = Pdesign/k;
        thickness = double(real(vpasolve(Pcrit==2.42*E*(thick/(2*R))^(5/2)/((-v^2 + 1)^(3/4)*...
                        (L/(2*R) - 0.45*(thick/(2*R))^(1/2))),thick))); %thickness (m)
    elseif 7<thickness
        if k == 0.6 || c == 5
            flag = true;
        end
        c=c+1;
        k=0.6;
        Pcrit = Pdesign/k;
        thickness = double(real(vpasolve(Pcrit==2.42*E*(thick/(2*R))^(5/2)/((-v^2 + 1)^(3/4)*...
                        (L/(2*R) - 0.45*(thick/(2*R))^(1/2))),thick))); %thickness (m)
    end
   
end
thickness = thickness*10^-3; %thickness (m)
end

