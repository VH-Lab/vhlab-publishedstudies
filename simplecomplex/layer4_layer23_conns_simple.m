function [layer4conns_excON,layer4conns_excOFF,layer4conns_inhON,layer4conns_inhOFF,inhT,inhG,myl4gain] = layer4_layer23_conns_simple(gridx,gridy,ori,pushpull)
 % connection matrix from layer 4 to 2/3

phase = 0; %pi/2;
sFreq = 0.2;
angle = (ori+90) * pi/180;

myImage = cos(2*pi*sFreq*(gridx.*sin(angle)+gridy.*cos(angle))-phase);
conns = myImage.*layer4_layer23_conns(gridx,gridy,ori);

layer4conns_excON = conns;
layer4conns_excON(find(layer4conns_excON<0)) = 0;

layer4conns_excOFF = -conns;
layer4conns_excOFF(find(layer4conns_excOFF<0)) = 0;

 % balance subunits
ONval = sum(sum(layer4conns_excON)); OFFval = sum(sum(layer4conns_excOFF));
if ONval>OFFval,
	layer4conns_excOFF = layer4conns_excOFF * ONval/OFFval;
else, layer4conns_excON = layer4conns_excON * OFFval/ONval;
end;

if pushpull,
	layer4conns_inhON = 1*layer4conns_excOFF;
	layer4conns_inhOFF = 1*layer4conns_excON;
else,
	layer4conns_inhON = zeros(size(layer4conns_excON));
	layer4conns_inhOFF = layer4conns_inhON;
end;

fitting = 0;
if fitting,
        simplecomplex_globals;  % for fitting
        myl4gain = l4gain;
        inhT = l4FFiT;
        inhG = l4FFiG;
else,
        inhT = 0;
        inhG = 1.00; 
        myl4gain = 1;
end;
