
 % if synapses have t2 of 50ms:
 % GSynAP_50 = intfireleaky_GsynAP([],synapset1t2el_init('tau2',0.050),[],[]);
GSynAP_50 = 0.00000000528395724483;

 % if synapses have t2 of 20ms:
 % GSynAP_20 = intfireleaky_GsynAP([],synapset1t2el_init('tau2',0.020),[],[]);
GSynAP_20 = 0.00000000713888861239;


 % Create a figure showing a 5 x 5 LGN input array

D = diag([1 1 1 1 1]); % 5x5 matrix with 1's on the diagonals
D2 = D(end:-1:1,:)
directionselectivityNcelldemo('latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',0.75*GSynAP_50*D2(:)','N',5','R',5,'isi',1);


directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.020},...
	'Syn_Gmax_initial',7e-9*D(:)','N',5','R',5,'isi',1);

 % 2x2 LGN input array
directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',7e-9*D(:)','N',2','R',2,'isi',1);



 % triplet conditions:

out = directionselectivity4cell_learning1('trials',400,...
	'latency',0.100,'lag',0.100,'classic_stdp',0);
 % saved as triplet5e9_100

out = directionselectivity4cell_learning1('trials',2,...
	'latency',0.200,'lag',0.200,'classic_stdp',0,...
	'synapseparams',{'tau2',0.020},'Gmax_initial',ones(1,4)*5.35e-9);
