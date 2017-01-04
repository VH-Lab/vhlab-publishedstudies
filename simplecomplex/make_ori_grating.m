function stim= make_ori_grating(gridx,gridy,ori,sFreq,phase)
 % makes grating stimulus

angle = (ori+90) * pi/180;

stim= cos(2*pi*sFreq*(gridx.*sin(angle)+gridy.*cos(angle))-phase);
