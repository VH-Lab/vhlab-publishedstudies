function [out_young, out_old] = intracell_strf_oriprops2diprefnull(oristruct, vmf_model)
% INTRACELL_STRF_ORIPROPS2DIPREFNULL - 
% 
%  
%
%

out_young = [];
out_old = [];

dc = find(strcmpi('mean',{oristruct.response_type}));
f1 = find(strcmpi('F1',{oristruct.response_type}));

map_ori2vmf = zeros(1,numel(dc));
map_vmf2ori = zeros(1,numel(dc));
for i=1:numel(dc),
        map_ori2vmf(i) = find( strcmpi(oristruct(dc(i)).name,{vmf_model.name}) & strcmpi(oristruct(dc(i)).reference,{vmf_model.reference})  );
        map_vmf2ori(map_ori2vmf(i)) = i;
end;

map_ori2vmf,

 % assume adjacent entries are the same, complain if wrong

for i=1:numel(dc),
	if ~strcmp(oristruct(dc(i)).name, oristruct(f1(i)).name),
		error('mismatch');
	end;

        n_spikes = numel(  find(vmf_model(  map_ori2vmf(i)  ).firingrate_observations>0));
        passes_spikeflag = (n_spikes >= 15);

	% max responses

	mean_resp = oristruct(dc(i)).actual.tuning_curve.mean;
	f1_resp = oristruct(f1(i)).actual.tuning_curve.mean;

	[mxvalue,max_loc] = max(mean_resp+f1_resp); % use F0

	% null loc

	null_loc = 1 + mod(-1 + max_loc + 0.5*numel(oristruct(dc(i)).actual.tuning_curve.mean), numel(oristruct(dc(i)).actual.tuning_curve.mean));

	[max_loc null_loc numel(oristruct(dc(i)).actual.tuning_curve.mean)]

	null_here = mean_resp(null_loc) + f1_resp(null_loc);
	pref_here = mean_resp(max_loc) + f1_resp(max_loc);
	if iscell(oristruct(dc(i)).actual.tuning_curve.raw_individual),
		pref_here_meanonly = nanmean(oristruct(dc(i)).actual.tuning_curve.raw_individual{max_loc}); 
	else,
		pref_here_meanonly = nanmean(oristruct(dc(i)).actual.tuning_curve.raw_individual(max_loc,:)); 
	end;
	di_here = (pref_here - null_here)/pref_here;
	if isinf(di_here) | isnan(di_here), % if we divide by 0, then di should be zero unless null negative
		if null_here < 0, %( -something/0) is DI of 1
			di_here = 1;
		else,
		        di_here = 0;
		end;
	end;
	di_here = max(0,di_here);  % constrain to be in 0..1
	di_here = min(1,di_here);

	if passes_spikeflag, 
		if oristruct(dc(i)).young,
			out_young = [out_young; di_here pref_here null_here pref_here_meanonly ];
		else,
			out_old = [out_old; di_here pref_here null_here pref_here_meanonly];
		end;
	end;
end;


