function output = vm_bizness
% VM_BIZNESS - plot squirrel vm tuning
%
%  needs to be run in the directory with the 'ctxintdb' file

[cells,cellnames] = load2celllist('ctxintdb','cell*','-mat');
[cells,cellnames] = vmcells(cells,cellnames); % filter by active cells

%all_angles = unique([-180:22.5:180 -180:30:180]); % not enough 22.5 steps to average
all_angles = unique([-180:30:180 -180:30:180]);

all_resps = nan(length(cells),length(all_angles));

vmcirc_vars = [];

fig = figure;

for i=1:length(cells),
	F0vmassoc = findassociate(cells{i},'OTVM F0 Response Curve','','');
        F1vmassoc = findassociate(cells{i},'OTVM F1 Response Curve','','');
        SpontRateVM = findassociate(cells{i},'OTVM Spontaneous rate','','');
        SpontRateSp = findassociate(cells{i},'OT Spontaneous rate','','');
	CV = findassociate(cells{i},'OTVM Circular variance','','');

	f0resp_vm = F0vmassoc.data(2,:) - SpontRateVM.data(1);
	f1resp_vm = F1vmassoc.data(2,:) - SpontRateVM.data(2);

	if max(f0resp_vm)>max(f1resp_vm),
		resp_vm = f0resp_vm;
		vmcirc_vars(i) = CV.data(1);
	else,
		resp_vm = f1resp_vm;
		vmcirc_vars(i) = CV.data(2);
	end;

	resp_vm = rescale(resp_vm,[min(resp_vm) max(resp_vm)],[0 1]);

	[max_vm,max_vmloc] = max(resp_vm); % find spot of maximum value

	numConds = length(F0vmassoc.data(1,:));

	angles_relative = angdiffwrapsign(F0vmassoc.data(1,:)-F0vmassoc.data(1,max_vmloc),360),

	for z=1:length(angles_relative),
		[dummy,loc] = min(abs(angles_relative(z)-all_angles));
		all_resps(i,loc(1)) = resp_vm(z);
	end;

	hold on;
	[angles_here,order_here] = sort(angles_relative);
	plot(angles_relative(order_here),resp_vm(order_here),'color',[0.5 0.5 0.5]);
end;

hold on;

mns = nanmean(all_resps);
stde = nanstd(all_resps);

size(mns),size(stde),
h=myerrorbar(all_angles,mns,stde,stde,'k-');
set(h,'linewidth',2);

xlabel('Difference from preferred orientation');
ylabel('Normalized response');

box off;

axis([-90 90 0 1]);

output = workspace2struct;
