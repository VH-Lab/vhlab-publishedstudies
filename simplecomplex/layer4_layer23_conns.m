function [layer4conns_excON,layer4conns_excOFF,layer4conns_inhON,layer4conns_inhOFF,inhT,inhG,myl4gain] = layer4_layer23_conns(gridx,gridy,ori)
 % connection matrix from layer 4 to 2/3
orthx_ = [0 0.3472 0.4981 0.7094 0.8151 0.9358 0.9509 1.0717 1.1019 1.2679 1.4189 1.6000 1.7509 1.8868 2.2491 2.5208 2.9887 3.3208 3.6226 3.8943];
orthy_ = [100 95.3704 92.1296 83.7963 76.3889 64.3519 58.3333 56.9444 50.9259 38.8889 29.1667 23.1481 17.5926 13.8889 11.5741 7.8704 6.0185 4.6296 3.7037 2.7778];
prefy_ =[100 97.6852 94.9074 90.7407 83.7963 73.6111 56.9444 43.0556 31.4815 23.6111 15.2778 6.9444 4.1667 2.3148];
prefx_ = [ 0 0.3472 0.4981 0.7396 0.9660 1.3132 1.7057 2.0075 2.2491 2.5208 2.8528 3.1849 3.5925 3.9396];

fitting = 1;

if fitting,
	simplecomplex_globals;  % for fitting
	myl4gain = l4gain;
	inhT = l4FFiT;
	inhG = l4FFiG;
else,
	inhT = 0;
	inhG = 1.00;
	myl4gain = 1;
	l4inhGain = 0.3285;
	l4inhTau = 10;
end;


[TH,R] = cart2pol(gridx,gridy);  TH = TH + (90+ori)*pi/180;
R_p = interp1(prefx_,prefy_',R,'linear'); R_o = interp1(orthx_,orthy_',R,'linear');
R_p(find(isnan(R_p))) = 0; R_o(find(isnan(R_o))) = 0;
conns = R_p.*(cos(TH).^2)+R_o.*(sin(TH).^2);  % should we square Rp and Ro and then take square root?
layer4conns_excON = conns./max(max(conns));
layer4conns_excOFF = layer4conns_excON;
layer4conns_inhON = l4inhGain*exp(-(R.^2)/l4inhTau);
%layer4conns_inhON = 1.0184*1.0041*layer4conns_inhON*sum(sum(layer4conns_excON))/sum(sum(layer4conns_inhON));
%%zeros(size(layer4conns_excON));
layer4conns_inhOFF = layer4conns_inhON;

