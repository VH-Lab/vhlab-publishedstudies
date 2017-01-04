function [imb,ima] = plot_otdirstack_divide_beforeonly(tpf, stackname, divider)

ima = 0;
ds = dirstruct(tpf);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

incl = [];
for i=1:length(cells),
	a=findassociate(cells{i},'OT vec varies p','','');
	if ~isempty(a)&a.data<0.05,
		incl(end+1) = i;
	end;
end;
if isempty(incl),
	for i=1:length(cells),
		a=findassociate(cells{i},'TP Ach OT vec varies p','','');
		if ~isempty(a)&a.data<0.05,
			incl(end+1) = i;
		end;
	end;

end;


imb = plototdirstack_divide(cells(incl),stackname,divider,'projection',[0.0 0.7],'supressplot',1,'afterscale',[0.999 1]);


figure;
subplot(1,2,1); image(imb); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

return;
subplot(1,2,2); image(ima); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

intervals = [ 0 0.1 0.3 1];

if 1,
figure;
for k=1:3,
	incl = [];
	
	for i=1:length(cells), 
		di = newferretdi(cells{i},1);
		dp1 = findassociate(cells{i},'OT Fit Pref','','');
		dp2 = findassociate(cells{i},'Recovery OT Fit Pref','','');
		if only_flippers,
			if angdiffwrap(dp1.data-dp2.data,360)>90 & di > intervals(k) & di <= intervals(k+1), incl(end+1) = i; end;
		else,
			if di > intervals(k) & di <= intervals(k+1), incl(end+1) = i; end;
		end;
	end;
	
	imb_ = plototdirstack_divide(cells(incl),stackname,divider,'projection',[0.0 0.7],'supressplot',1,'afterscale',[0.1 1]);

	ima_ = plototdirstack_divide(cells(incl),stackname,divider,'dir_assoc','Recovery OT Carandini Fit Params','ot_assoc','Recovery OT Fit Pref',...
			'pthreshold_assoc','Recovery OT vec varies p','dir_pref_assoc','Recovery OT Fit Pref',...
			'bor_assoc','Recovery Best orientation resp','fit_assoc','Recovery OT Carandini Fit','projection',[0 0.7],'supressplot',1,...
			'afterscale',[1 1]);
	
	subplot(3,2,2*(k-1)+1); image(imb_); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

	subplot(3,2,2*(k-1)+2); image(ima_); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

end;

end;
