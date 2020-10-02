function sim_resps = intracell_strf_summary_makesims(oristruct, vmf_model, simpleflag)
%
% If SIMPLEFLAG == 0, then no filtering
% If SIMPLEFLAG == 1, then simple only
% If SIMPLEFLAG == 2, then non-simple only
%


  % NEED TO SUBTRACT SPONTANEOUS RATE!!

if nargin<3,
	simpleflag = 0;
end;

oristruct = oristruct(strcmpi('mean',{oristruct.response_type}));

map_ori2vmf = zeros(1,numel(oristruct));
map_vmf2ori = zeros(1,numel(oristruct));
for i=1:numel(oristruct),
	map_ori2vmf(i) = find( strcmpi(oristruct(i).name,{vmf_model.name}) & strcmpi(oristruct(i).reference,{vmf_model.reference})  );
	map_vmf2ori(map_ori2vmf(i)) = i;
end;

 % now eliminate weak spikers and, if necessary, simple or complexcells

include = [];
for i=1:numel(vmf_model),
	simple_value = intracell_strf_issimple(vmf_model(i).name);

	if simpleflag == 0,
		passes_simpleflag = 1;
	elseif simpleflag == 1,
		passes_simpleflag = simple_value;
	elseif simpleflag == 2,
		passes_simpleflag = ~simple_value;
	else,
		error(['Unknown simpleflag ' num2str(simpleflag) ]);
	end;

	n_spikes = numel(find(vmf_model(i).firingrate_observations>0));
	passes_spikeflag = n_spikes >= 15;
	
	if passes_spikeflag & passes_simpleflag,
		include(end+1) = i;
	end;
end;

vmf_model = vmf_model(include);
oristruct = oristruct(map_vmf2ori(include));

  % so lazy, we could calculate in 2 lines
map_ori2vmf = zeros(1,numel(oristruct));
map_vmf2ori = zeros(1,numel(oristruct));
for i=1:numel(oristruct),
	map_ori2vmf(i) = find( strcmpi(oristruct(i).name,{vmf_model.name}) & strcmpi(oristruct(i).reference,{vmf_model.reference})  );
	map_vmf2ori(map_ori2vmf(i)) = i;
end;


y = find([oristruct.young]==1);
o = find([oristruct.young]~=1);

numsims = 1000;
fitdocid = 2;

sim_resps = {};
for age1=1:2,
	for age2=1:2,
		sim_resps{age1}{age2} = [];
	end;
end;

 % Step 1: simulate young voltages on young gains

young = 1;
old = 2;
pref = 2;
null = 3;
di = 1;

for n=1:numsims,
	% draw a cell at random for its voltages
	cell_v = randi(numel(y),1);
	% draw another cell at random for its gains
	cell_g = randi(numel(y),1);
	
	voltage_here_pref = oristruct(y(cell_v)).out_pref;
	voltage_here_null = oristruct(y(cell_v)).out_null;
	voltage_here_control = oristruct(y(cell_v)).out_control;
	gain_here = vmf_model(map_ori2vmf(y(cell_g))).fit(2).fitdoc;
	[di_here,resp_p,resp_n] = simulate_prefnull(voltage_here_pref,voltage_here_null,voltage_here_control, gain_here);
	sim_resps{young}{young}(end+1,:) = [di_here resp_p resp_n];
end;

for n=1:numsims,
	% draw a cell at random for its voltages
	cell_v = randi(numel(y),1);
	% draw another cell at random for its gains
	cell_g = randi(numel(o),1);
	
	voltage_here_pref = oristruct(y(cell_v)).out_pref;
	voltage_here_null = oristruct(y(cell_v)).out_null;
	voltage_here_control = oristruct(y(cell_v)).out_control;
	gain_here = vmf_model(map_ori2vmf(o(cell_g))).fit(2).fitdoc;
	[di_here,resp_p,resp_n] = simulate_prefnull(voltage_here_pref, voltage_here_null, voltage_here_control, gain_here);
	sim_resps{young}{old}(end+1,:) = [di_here resp_p resp_n];
end;

for n=1:numsims,
	% draw a cell at random for its voltages
	cell_v = randi(numel(o),1);
	% draw another cell at random for its gains
	cell_g = randi(numel(y),1);
	
	voltage_here_pref = oristruct(o(cell_v)).out_pref;
	voltage_here_null = oristruct(o(cell_v)).out_null;
	voltage_here_control = oristruct(o(cell_v)).out_control;
	gain_here = vmf_model(map_ori2vmf(y(cell_g))).fit(2).fitdoc;
	[di_here,resp_p,resp_n] = simulate_prefnull(voltage_here_pref, voltage_here_null, voltage_here_control, gain_here);
	sim_resps{old}{young}(end+1,:) = [di_here resp_p resp_n];
end;

for n=1:numsims,
	% draw a cell at random for its voltages
	cell_v = randi(numel(o),1);
	% draw another cell at random for its gains
	cell_g = randi(numel(o),1);
	
	voltage_here_pref = oristruct(o(cell_v)).out_pref;
	voltage_here_null = oristruct(o(cell_v)).out_null;
	voltage_here_control = oristruct(o(cell_v)).out_control;
	gain_here = vmf_model(map_ori2vmf(o(cell_g))).fit(2).fitdoc;
	[di_here,resp_p,resp_n] = simulate_prefnull(voltage_here_pref, voltage_here_null, voltage_here_control, gain_here);
	sim_resps{old}{old}(end+1,:) = [di_here resp_p resp_n];
end;

function [di, resp_p, resp_n] = simulate_prefnull(pref_struct, null_struct, control_struct, gain_doc)

useV = 0;
useG = 0;

  % pref_resp

prefs = [];

for i=1:numel(pref_struct.TT),
	if ~any(isnan(pref_struct.raw_data{i})),
		R = ndi.data.evaluate_fitcurve(gain_doc,pref_struct.raw_data{i});
		if useV, 
			R = pref_struct.raw_data{i};
		end;
		if useG,
			R = ndi.data.evaluate_fitcurve(gain_doc,0.025);
		end;
		prefs(end+1) = nanmean(R);
	end;
end;

nulls = [];

for i=1:numel(null_struct.TT),
	if ~any(isnan(null_struct.raw_data{i})),
		R = ndi.data.evaluate_fitcurve(gain_doc,null_struct.raw_data{i});
		if useV, 
			R = null_struct.raw_data{i};
		end;
		if useG,
			R = 0;
		end;
	nulls(end+1) = nanmean(R);
	end;
end;

controls = [];

for i=1:numel(control_struct.TT),
	if ~any(isnan(control_struct.raw_data{i})),
		R = ndi.data.evaluate_fitcurve(gain_doc,control_struct.raw_data{i});
		if useV, 
			R = control_struct.raw_data{i};
		end;
		if useG,
			R = 0;
		end;
		controls(end+1) = nanmean(R);
	end;
end;


resp_p = nanmean(prefs) - nanmean(controls);
resp_n = nanmean(nulls) - nanmean(controls);
di = (resp_p-resp_n)/resp_p;
if isinf(di) | isnan(di), % if we divide by 0, then di should be zero
	di = 0;
end;
di = max(0,di);  % constrain to be in 0..1
di = min(1,di);

