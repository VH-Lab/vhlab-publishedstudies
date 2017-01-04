function dat_out = neilTF_reorg(dat, Nepochs)
% NEILTF_REORG - Reorganize data from SPSS to reflect linked time-elapsed measures
%  

if Nepochs==3,
	dat_out = emptystruct('Training_Type','t0','t1','t2','d_type');
elseif Nepochs == 4,
	dat_out = emptystruct('Training_Type','t0','t1','t2','d_type');
else,
	error(['only know how to deal with 3 or 4 epochs']);
end;


d_type = unique([dat.Test]);

for dt = 1:length(d_type),

	ind = find([dat.Test]==d_type(dt));
	dat_here = dat(ind);
	
	disp(['d_type(dt): ' int2str(d_type(dt))]),

	tt = unique({dat_here.Training_Type});
	for t=1:length(tt),

		disp(['Training_Type(t): ' tt{t}]),

		ind2 = find(strcmp(tt{t},{dat_here.Training_Type}));
		dat_to_combine = dat_here(ind2);

		% now assume the nth data point is linked to nth data point

		N = length(dat_to_combine) / Nepochs;

		for n=1:N,
			new_dat.Training_Type = tt{t};
			for j=1:Nepochs,
				new_dat = setfield(new_dat,['t' int2str(j-1)], dat_to_combine(n+(j-1)*N).DSI);
			end;
			new_dat.d_type = d_type(dt);
		end;

		dat_out(end+1) = new_dat;	

		clear new_dat;
	end;
end;

