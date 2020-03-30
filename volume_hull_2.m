function [Volume,Lpmb]=volume_hull_2(x)   
%====================================================================== 
% This function calculates the volume of the hull of an AUV. 
% It uses a cylindrical hull following MIT model (Jackson 1992). 
% It assumes a body of revolution with a length/diameter (L/D) 
% ratio between 6 and 9 and a maximum diameter at 0.4L.
% The entrance has a length Lf=2.4D. The run or after end has a length, 
% La=3.6D. It uses a numerical approximation (Discretization with 
% n=1000) 
%======================================================================  
Diameter=x(1);   Loa=x(2);    nf=x(3);   na=x(4);
Lf=2.4*Diameter;  La=3.6*Diameter;
Lpmb=Loa-La-Lf;  

format long;  

n=1001; 
a=1:1:n; 
dx=a*Loa/n; 
bf=Lf*n/Loa; 
bf=floor(bf); 
xf=dx(1:bf); 
ba=(Loa-La)*n/Loa;
ba=floor(ba);
xa=dx(ba+1:n);   

for i=1:bf    
    y=Diameter/2*(1-((Lf-xf)/Lf).^nf).^(1/nf); 
end

j=1; 
for i=bf+1:ba   
    y(i)=Diameter/2;    
    j=j+1; 
end

j=1; 
for i=ba+1:n   
    y(i)=Diameter/2*(1-((xa(j)-Lf-Lpmb)/La).^na);    
    j=j+1;
end

v=pi*y.^2; Volume=trapz(dx,v); 

%To plot AUV hull 
%   [Z,X,Y] = cylinder(y);
%   surf(X,Y*Loa,Z);
%   axis 'equal';
%   xlabel('z'); 
%   ylabel('y'); 
%   zlabel('x')
%   view(60,20)

return