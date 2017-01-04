function sl_gradients
%

sl_limitHebbianfig;

%ml1start        /Volumes/Data2/singlelayermodel/bias_inhib      sl_limitsHebbianfig; out=directionselectivityNcell_learning2('isi',0.2750,'N',5,'R',5,'trials',1000,'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},'Gmax_initial',sl_biasinit(1),'Gmax_initial_inhib',1.001*GsynAP_list(5)*ones(1,25),'classic_stdp',1,'Gmax_max',0.999*GsynMax_list(5),'dt',1e-3,'ISyn_change',1.01,'unidir',0,'ISyn_Gmax_initial',0*0.1e-9,'ISyn_Max',5.3e-9);    ml1.mat ml1error.mat

out = directionselectivityNcell_learning2('isi',0.8,'lag',0.200,'latency',0.2,'N',2,'R',2,'Gmax_max',0.99*7.0e-9,'trials',110,...
	'classic_stdp',1,'synapseparams',{'tau2',0.020},'Gmax_initial',0.6*7.1e-9*ones(1,4),'dt',1e-3,...
	'Gmax_initial_inhib',0.4e-9,...
	'unidir',1,'ISyn_Gmax_initial',0,'ISyn_Max',5.3e-9,'ISyn_change',1.01);
out = directionselectivityNcell_learning2('isi',0.8,'lag',0.200,'latency',0.2,'N',2,'R',2,'Gmax_max',0.99*7.0e-9,'trials',110,...
	'classic_stdp',1,'synapseparams',{'tau2',0.020},'Gmax_initial',0.6*7.55e-9*ones(1,4),'dt',1e-3,...  % 0.6*7.55
	'Gmax_initial_inhib',6.0e-9*ones(1,4),...
	'unidir',1,'ISyn_Gmax_initial',10e-9,'ISyn_Max',22e-9,'ISyn_change',1.02,'mask',0);

Ginhib{2} = 22e-9;
Gceil{2} = 0.99*7.0e-9;
Gt_half{2} = 0.6*7.55;

gmax_low = 0.6*7.1e-9;
gmax_high = 0.99*7.0e-9;
gmax_steps = 10;

g_even_steps = linspace(gmax_low,gmax_high,gmax_steps);
g_odd_steps = linspace(gmax_low,gmax_high,gmax_steps);

i=1;
G_even{i} = [];
G_odd{i} = [];
DI{i} = [];
dG_even{i} = [];
dG_odd{i} = [];
dDI{i} = [];
trial_step = 4;

for g1 = 1:length(g_even_steps),
	g1,
	for g2 = 1:length(g_odd_steps),
		out = directionselectivityNcell_learning2('isi',0.5,'lag',0.200,'latency',0.2,'N',2,'R',2,'Gmax_max',0.99*7.1e-9,'trials',trial_step,...
		        'classic_stdp',1,'synapseparams',{'tau2',0.020},'Gmax_initial',[g_even_steps(g1) g_odd_steps(g2) g_odd_steps(g2) g_even_steps(g1)],...
			'dt',1e-3,'Gmax_initial_inhib',0.4e-9,...
		        'unidir',1,'ISyn_Gmax_initial',0,'ISyn_Max',5.3e-9,'ISyn_change',1.01,'mask',0);
		close(gcf);
		G_even{i}(g1,g2) = g_even_steps(g1);
		G_odd{i}(g1,g2) = g_odd_steps(g2);
		DI{i}(g1,g2) = out.di(1);  %initial DI
		dG_even{i}(g1,g2) =mean(out.gmaxes([1 4],end)) - G_even{i}(g1,g2);
		dG_odd{i}(g1,g2) =mean(out.gmaxes([2 3],end)) - G_odd{i}(g1,g2);
		dDI{i}(g1,g2) =  out.di(end) - DI{i}(g1,g2);
	end;
end;

i = 1;
figure;
subplot(2,2,1);
quiver(G_odd{i},G_even{i},dG_odd{i}/trial_step,dG_even{i}/trial_step,'g')
box off;
subplot(2,2,2);
quiver(G_odd{i},DI{i},dG_odd{i}/trial_step,dDI{i}/trial_step,'b');
box off;

