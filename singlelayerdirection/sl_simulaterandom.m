function [rup,rdown,di,dsi] = sl_simulaterandom(num_sims, sim_size, alpha, threshold, ceiling)
% SL_SIMULATERANDOM - Simulate random single layer feedforward circuits for direction selectivity
%   
% [RUP, RDOWN, DI, DSI] = SL_SIMULATERANDOM(NUM_SIMS, SIM_SIZE, ALPHA, THRESHOLD, CEILING)
%
%  

rup = zeros(1,num_sims);
rdown = zeros(1,num_sims);
di = zeros(1,num_sims);
dsi = zeros(1,num_sims);

for i=1:num_sims-1,
	%D = ceiling * rand(sim_size); % continuous
	%D = threshold ./ (randi(ceiling+1, [sim_size sim_size])) - 0.00001; % only integer multiples of threshold if threshold is 1
	D = -1+randi(ceiling+1, [sim_size sim_size]) - 0.00001; 
	[rup(i),rdown(i),di(i),dsi(i)] = sl_computedirection(D, alpha, threshold);
end;


if 1,
	D = zeros([sim_size sim_size]);
	for i=1:sim_size,
		D(i,i) = threshold-0.00001;
	end;
	if sim_size>2,
		for i=1:sim_size-1,
			D(i+1,i) = threshold-0.00001;
		end;
	end;
	%D=D(:,end:-1:1); not necessary
	i = num_sims;
	[rup(i),rdown(i),di(i),dsi(i)] = sl_computedirection(D, alpha, threshold);
end;
