function [imb,ima] = plot_otdirstack_divide_beforeafter(tpf, stackname, divider)

ds = dirstruct(tpf);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

cells = beforeaftercells(cells);

incl = [];

only_flippers = 0;

if only_flippers, % pull out only guys who flip
	for i=1:length(cells),
		dp1 = findassociate(cells{i},'TP Ach OT Fit Pref','','');
		dp2 = findassociate(cells{i},'TP ME Ach OT Fit Pref','','');
		if angdiffwrap(dp1.data-dp2.data,360)>90, incl(end+1) = i; end;
	end;
else, incl = 1:length(cells);
end;

imb = plototdirstack_divide(cells(incl),stackname,divider,'projection',[0.0 0.7],'supressplot',1,'afterscale',[0.999 1]);

ima = plototdirstack_divide(cells(incl),stackname,divider,'dir_assoc','TP ME Ach OT Carandini Fit Params','ot_assoc','TP ME Ach OT Fit Pref',...
			'pthreshold_assoc','TP ME Ach OT vec varies p','dir_pref_assoc','TP ME Ach OT Fit Pref',...
			'bor_assoc','Recovery Best orientation resp','fit_assoc','TP ME Ach OT Carandini Fit','projection',[0 0.7],'supressplot',1,...
			'afterscale',[0.999 1],'dirind_assoc','TP ME Ach OT Fit Direction index blr');

figure;
subplot(1,2,1); image(imb); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

subplot(1,2,2); image(ima); axis equal; set(gca,'box','off','xtick',[],'ytick',[],'visible','off');

intervals = [ 0 0.1 0.3 1];

