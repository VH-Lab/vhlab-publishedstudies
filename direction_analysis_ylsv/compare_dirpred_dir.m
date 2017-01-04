function compare_dirpred_dir(DP,di, subsetx, subsety)

di_angs = rescale(mod(angle(di),2*pi),[0 2*pi],[1 360]);
dip_angs =rescale(mod(angle(DP),2*pi),[0 2*pi],[1 360]);
di_mag = abs(di); dip_mag = abs(DP);
MN = min([min(min(di_mag))]); MX = max([max(max(di_mag))]);
di_mag = rescale(di_mag,[MN MX],[129 256]);
dip_mag = rescale(dip_mag,[min(min(dip_mag)) max(max(dip_mag))],[129 256]);

figure;

subplot(1,1,1);

plot(di_angs(:),dip_angs(:),'k.');

di_angssub = di_angs(subsetx,subsety);
dip_angssub = di_angs(subsetx,subsety);

[slope,offset,slope_conf,r2] = quickregression(di_angssub(:),dip_angssub(:),0.05); 

slope,slope_conf,
hold on;

plot([0 360],[0 360]*slope+offset,'b--');