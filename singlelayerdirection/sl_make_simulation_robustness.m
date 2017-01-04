function robustcommands = sl_make_simulation_robustness

Gmax_mod{1} = [ 0.25 0.5 0.75 1 1.25 1.5 1.75 2];
Gmax_mod{2} = [ 0.625 0.8750 1.125 1.375];

Inhib_mod = [ 0 0.25 0.5 0.75 1 1.25 1.5 1.75 2];

robustcommands = struct;

for k=1:2, % notice this here

for g=1:length(Gmax_mod{k}),
	for i=1:length(Inhib_mod),
		clear s;

		if isempty(fieldnames(robustcommands)),
			simNum = 0;
		else,
			simNum = simNum + 1;
		end;

		s.jobclaimfile = ['ml_' sprintf('%0.4d',simNum) '_start'];
		s.pathtorun = '/Volumes/Data2/singlelayermodel/robust';
		s.commandtorun = [ 'Gmax_mod=' mat2str(Gmax_mod{k}(g)) ';' ...
				'Inhib_mod=' mat2str(Inhib_mod(i)) ';' ...
 ...
'sl_limitsHebbianfig; out=directionselectivityNcell_learning2(''isi'',0.2750,''N'',5,''R'',5,''trials'',1000/20,''latency'',0.025,''lag'',0.025,''synapseparams'',{''tau2'',0.020},''Gmax_initial'',sl_biasinit(5),''Gmax_initial_inhib'',1.001*GsynAP_list(5)*ones(1,25),''classic_stdp'',0,''Gmax_max'',Gmax_mod*GsynMax_list(5),''dt'',1e-3,''ISyn_change'',(1.0010)^20,''unidir'',0,''ISyn_Gmax_initial'',0.1e-9,''ISyn_Max'',Inhib_mod*1*1.800e-9,''nreps'',20);' ...
	];
		s.savefile = ['ml_' sprintf('%0.4d',simNum) '.mat'];
		s.errorsave= ['ml_' sprintf('%0.4d',simNum) '.mat'];

		if isempty(fieldnames(robustcommands)),
			robustcommands = s;
		else,
			robustcommands(end+1) = s;
		end;
	end;
end;

end; % for loop over k
