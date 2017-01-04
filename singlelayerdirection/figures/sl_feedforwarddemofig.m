function sl_feedforwarddemofig

% Simulate 4 networks; 3 are 2x2 illustrating the various degrees of direction selectivity that the
%   network can exhibit. 1 is 5x5

% for this figure, t2 is 50ms

 % GSynAP_50 = intfireleaky_GsynAP([],synapset1t2el_init('tau2',0.050),[],[]);
GSynAP_50 = 0.00000000528395724483;

 % if synapses have t2 of 20ms:
 % GSynAP_20 = intfireleaky_GsynAP([],synapset1t2el_init('tau2',0.020),[],[]);
GSynAP_20 = 0.00000000713888861239;

%Steps 1-3

directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',0.75*GSynAP_50*[1 1 1 1],'N',2','R',2,'isi',0.75);

D_2 = diag([1 1]); % 2x2 matrix with 1's on the diagonals
D2_2 = D_2(end:-1:1,:); % flip 
directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',0.75*GSynAP_50*D2_2(:)','N',2','R',2,'isi',1);

directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',1.10*GSynAP_50*D2_2(:)','N',2','R',2,'isi',0.75);

%Step 4:

 % Create a figure showing a 5 x 5 LGN input array

D_5 = diag([1 1 1 1 1]); % 5x5 matrix with 1's on the diagonals
D2_5 = D_5(end:-1:1,:);
directionselectivityNcelldemo('latency',0.100,'lag',0.100,'synapseparams',{'tau2',0.020},...
	'Syn_Gmax_initial',0.75*GSynAP_50*D2_5(:)','N',5','R',5,'isi',1);

return;

directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.020},...
	'Syn_Gmax_initial',7e-9*D(:)','N',5','R',5,'isi',1);

 % 2x2 LGN input array
directionselectivityNcelldemo('latency',0.200,'lag',0.200,'synapseparams',{'tau2',0.050},...
	'Syn_Gmax_initial',7e-9*D(:)','N',2','R',2,'isi',1);


