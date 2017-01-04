

this is a log of steve's exploration of parameters

exper:
out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1*2.36e-11);
result: doesn't inhibit enough, E cell responds more and more to both directions

exper:
out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',7*2.36e-11);
result: it's good at the beginning (4Hz or so preferred direction firing rate) but then it escapes from inhibition and DI goes down

out7=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',10*2.36e-11);
result: it's good at the beginning (4Hz or so preferred direction firing rate) but then it escapes from inhibition and DI goes down

I think the inhibition increase should be multiplicative rather than additive

edited code to make this happen

out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.05);

out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.01);

the inhibition doesn't increase fast enough

out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.001*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.5*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.05);

out6=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.15);

out7=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',2.5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.15);

out8=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',2.5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.10);

results: for all of these, the inihibition grows so strong early that it shuts off responses


2 ideas:  easy one is to limit overall strength of inhibition, hard one is to have the amount of inhibition be proportional to postsynaptic firing rate (evidence for this)

limiting overall strength of inhibition:

out10=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',2.5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.15,'ISyn_Max',0.8e-08);

needs to slightly higher maximum, let's try having that maximum arrive at 60

>> out10=directionselectivityNcell_learning2('isi',1.1,'N',5,'R',5,'trials',100,'latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(3)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(3)*ones(1,25),'classic_stdp',1,'Gmax_max',2.5*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.05,'ISyn_Max',1.0e-08);

not quite, opposite direction still breaks free



could try starting from step 30, seeing how much inhibition is needed to pull the circuit back to 100% direction-selective


2013-07-18

this is interesting:  goes to 1 DI

>> close all; out6=directionselectivityNcell_learning2('isi',0.2750,'N',5,'R',5,'trials',200,'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(5)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(5)*ones(1,25),'classic_stdp',1,'Gmax_max',0.999*GsynMax_list(5),'dt',1e-3,'ISyn_change',1.01)';


bidirectional training:  this does what you expect, increases firing in both directions:

close all; out6=directionselectivityNcell_learning2('isi',0.2750,'N',5,'R',5,'trials',100,'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},'Gmax_initial',1.101*GsynAP_list(5)*ones(1,25),'Gmax_initial_inhib',1.001*GsynAP_list(5)*ones(1,25),'classic_stdp',1,'Gmax_max',0.999*GsynMax_list(3),'dt',1e-3,'ISyn_change',1.01,'unidir',0);

question is, if it is biased?
