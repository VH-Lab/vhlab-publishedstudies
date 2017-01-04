
 % this generates a direction-selective cell with unidirectional training

g = eye(3);
g_ = g(3:-1:1,:);
g__ = g_;
g__(1,3) = 0;


sl_limitsHebbianfig; out=directionselectivityNcell_learning2('isi',0.2750,'N',3,'R',3,'trials',100,'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},'Gmax_initial',10*GsynAP_list(5)*reshape(g__,1,9),'Gmax_initial_inhib',3*GsynAP_list(3)*ones(1,9),'classic_stdp',1,'Gmax_max',0.14e-7,'dt',1e-3,'ISyn_change',1.1,'unidir',1,'ISyn_Gmax_initial',1*0.1e-9,'ISyn_Max',30*5.3e-9,'mask',g_);


sl_limitsHebbianfig; out=directionselectivityNcell_learning2('isi',0.2750,'N',3,'R',3,'trials',100,'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},'Gmax_initial',10*GsynAP_list(5)*reshape(g__,1,9),'Gmax_initial_inhib',3*GsynAP_list(3)*ones(1,9),'classic_stdp',1,'Gmax_max',0.14e-7,'dt',1e-3,'ISyn_change',1.1,'unidir',0,'ISyn_Gmax_initial',1*0.1e-9,'ISyn_Max',30*5.3e-9,'mask',g_);


