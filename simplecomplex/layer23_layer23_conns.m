function conns = layer23_layer23_conns(gridx,gridy,ori)
  % the boutons from Heather's paper
prefx_ = [ 0 1.0000 1.6154 2.4615 2.8462 3.3846 3.9231 4.6923 5.4615 6.5385 7.5385 8.8462 9.5385 10.0000];  % deg. visual angle
prefy_ = [ 100 98.7854 82.1862 59.5142 44.1296 29.1498 21.0526 14.9798 8.9069 6.4777 4.0486 1.6194 1.2146 1.2146]; % percent of all boutons
orthx_ = [ 0 1.0000 1.3077 1.6923 2.2308 3.0769 4.0769 6.2308 8.3846 10.0000];
orthy_ = [ 100 87.8543 72.4696 54.6559 36.8421 17.8138 5.2632 1.2146 0.8097 0.8097];

[TH,R] = cart2pol(gridx,gridy);  TH = TH - ori*pi/180;
R_p = interp1(prefx_,prefy_',R); R_o = interp1(orthx_,orthy_',R);
conns = R_p.*(cos(TH).^2)+R_o.*(sin(TH).^2);  % should we square Rp and Ro and then take square root?
conns = conns./max(max(conns));

