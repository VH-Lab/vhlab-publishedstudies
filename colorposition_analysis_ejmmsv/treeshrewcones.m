function [CONEMON, CONES, MONITOR, CONETRANS, TRANS, WAVES] = treeshrewcones;

load tscolorvars;

% main variables
WAVES = [ 400:1:750 ] ; % wavelengths we will fit here

TRANS = [trans_shrew ones(1,100)];

if 0,
abs_wavelengths = [ 440:10:620 ];
% western gray squirrel, from Yolton ... Jacobs 1974
abs_wgs = ...
[0.54 0.24 0.14 0.09 0.07 0.07 0.06 0.05 0.05 0.05 ...
 0.04 0.03 0.03 0.02 0.02 0.01 0.01 0.00 0.00];
abs_cgs = ...
[1.04 0.62 0.41 0.29 0.21 0.15 0.11 0.08 0.07 0.06 ...
 0.05 0.04 0.04 0.02 0.03 0.02 0.01 0.00 0.00];
trans_wgs = 10.^(-abs_wgs); trans_cgs = 10.^(-abs_cgs);
fudged_trans = [0*ones(1,36) trans_wgs ones(1,80+50)];
fudged_abs_wavelengths = [ 400:435 abs_wavelengths 621:750];

TRANS = spline(fudged_abs_wavelengths,fudged_trans,WAVES);
end;



% fit using Zoran's Govardovskii's functions
Sc = govardovskii(440,WAVES); Lc = govardovskii(555,WAVES); Rc = govardovskii(501,WAVES);
CONES = [ Sc; Lc; Rc];
%CONES = [ Sc; L_shrew; Rc];

MONITOR=2*MONITOR_SONY;
MONITOR(:,3) = MONITOR(:,3)/1.37;
MONITOR(:,2) = MONITOR(:,2)*1.2;
MONITOR = [MONITOR; zeros(100,3)];

CONETRANS = [CONES(1,:).*TRANS;CONES(2,:).*TRANS; CONES(3,:).*TRANS];
CONEMON = CONETRANS * MONITOR;  % matrix between rgb and cone activation
