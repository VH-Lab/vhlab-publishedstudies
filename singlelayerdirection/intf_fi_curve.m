function [Gsyn,F, slope, offset, GsynAP] = intf_fi_curve


intfireparams = {'V_threshold',-0.055};
intfireparams = {'V_threshold',-0.050};

intfire = intfireleakyel_init(intfireparams{:});

synapse = synapset1t2el_init('tau2',0.020);
GsynAP = intfireleaky_GsynAP(intfire,synapse,[],[0 10e-9 30]);
Grange = [ GsynAP 50e-9 10]; % for fitting a slope

Grange = [ GsynAP 50e-9 100];

[Gsyn,F] = intfireleaky_Gsyn_vs_F(intfire,synapse,[],Grange);

[slope,offset] = quickregression(Gsyn',F',0.05);

figure;
plot(Gsyn,F,'bo');
hold on;
plot(Gsyn,slope*[Gsyn]+offset,'g-');
xlabel('Synaptic strength');
ylabel('Firing rate');

 % how to plot the expected range?
% bottom is 0, alpha * M * thresh
% what is slope?
% 1 I suppose
