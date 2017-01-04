function sl_feedforwardcapabilities

% first row of panels

%[Gsyn, F, slope, offset, GsynAP] = intf_fi_curve;
alpha = 4.5941e+08;
GSynAP_20 = 0.00000000713888861239;  % 20ms

plot_sl_random_sims('/Volumes/Data2/singlelayermodel/random');
fig1 = gcf;
plot_sl_predicted(fig1,2,alpha,GSynAP_20);

% second row of panels

fig2 = figure;
Mlist = [ 2 4 8 16 ];

for m=Mlist,
	plot_sl_predicted(fig2, m, alpha, GSynAP_20);
end;

subplot(2,2,1); axis([0 100 0 100]);
subplot(2,2,2); axis([0 100 0 1]);
subplot(2,2,3); axis([0 100 0 1]);
subplot(2,2,4); axis([0 20 0 1]);

