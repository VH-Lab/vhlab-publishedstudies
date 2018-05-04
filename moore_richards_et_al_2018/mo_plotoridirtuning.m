function [output] = mp_plotoridirtuning(cellinfo)
% MP_PLOTORIDIRTUNING - plot direction information from cells
%
%  OUTPUT = MP_PLOTORIDIRTUNING(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
%  OUTPUT - A list of output variables
%
% 

struct2var(mo_definestudygroups(cellinfo)); % define variables for study groups

axis_max = -Inf;
axis_min = Inf;
P = length(myinds);
N = zeros(1,P);

oridirfigure = figure('tag','OriDir_ResponsesAndStats');

for p = 1:P,
	subplot(3,P,p);
	hold on;
	mygoodcells = []; % only include responsive cells
	for i=1:length(myinds{p}),
		if ~isempty(cellinfo(myinds{p}(i)).ori_info.sig_vis),
			if (cellinfo(myinds{p}(i)).ori_info.sig_vis< 0.05) %  & (max(cellinfo(myinds{p}(i)).ori_info.fit(2,:))>0),
				mygoodcells(end+1) = myinds{p}(i);
			end;
		end;
	end;

	N(p) = length(mygoodcells);
	% now we have all good cells

	dir_curve_ind{p} = [];

	for i=1:length(mygoodcells),
		fit_new = cellinfo(mygoodcells(i)).ori_info.fit;
		[dummy,shuffle] = sort(mod(fit_new(1,:),360));
		fit_new = fit_new(:,shuffle);
		fit_new(1,:) = mod(fit_new(1,:),360);
		fit_new(2,:) = rotatedircurve(fit_new(1,:),fit_new(2,:),90);
		dir_curve_ind{p}(end+1,:) = fit_new(2,:);
		plot(fit_new(1,:),fit_new(2,:),'color',[0.5 0.5 0.5],'linewidth',1,'userdata',mygoodcells(i));
	end;
	if ~isempty(mygoodcells),
		AA = nanmean(dir_curve_ind{p},1);
		BB = nanstderr(dir_curve_ind{p});
		plot(fit_new(1,:),AA,'k','linewidth',1.5);
		i90 = findclosest(fit_new(1,:), 90);
		i270 = findclosest(fit_new(1,:), 270);
		I = [i90 i270];
		h=myerrorbar(fit_new(1,I), AA(1,I), BB(1,I), BB(1,I));
		set(h,'color',[0 0 0],'linewidth',1.5);
		delete(h(2));
	end;

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Length');
	ylabel('Spikes/sec');
	A = axis;
	axis_max = max(axis_max,A(4));
	axis_min = min(axis_min,A(3));


	subplot(3,P,P+p);
	hold on;
	dir_curve_ind_norm{p} = [];
	for i=1:length(mygoodcells),
		fit_new = cellinfo(mygoodcells(i)).ori_info.fit;
		[dummy,shuffle] = sort(mod(fit_new(1,:),360));
		fit_new = fit_new(:,shuffle);
		fit_new(1,:) = mod(fit_new(1,:),360);
		fit_new(2,:) = rotatedircurve(fit_new(1,:),fit_new(2,:),90);
		fit_new(2,:) = fit_new(2,:) / max(fit_new(2,:));
		dir_curve_ind_norm{p}(end+1,:) = fit_new(2,:);
		plot(fit_new(1,:),fit_new(2,:),'color',[0.5 0.5 0.5],'linewidth',1,'userdata',mygoodcells(i));
	end;
	if ~isempty(mygoodcells),
		AA = nanmean(dir_curve_ind_norm{p},1);
		BB = nanstderr(dir_curve_ind_norm{p});
		plot(fit_new(1,:),AA,'k','linewidth',1.5);
		i90 = findclosest(fit_new(1,:), 90);
		i270 = findclosest(fit_new(1,:), 270);
		I = [i90 i270];
		h=myerrorbar(fit_new(1,I), AA(1,I), BB(1,I), BB(1,I));
		set(h,'color',[0 0 0],'linewidth',1.5);
		delete(h(2));
	end;
	box off;
	xlabel('Length');
	ylabel('Norm Spikes/sec');
	A=axis;
	[fit_new(1,1) fit_new(1,end) -1 1]
	axis([0 360 -1 1]);


	% dir and ori (1-cv) cumulative histograms

	dir_ind{p} = [];
	cv_ind{p} = [];
	for i=1:length(mygoodcells),
		dir_ind{p}(end+1) = cellinfo(mygoodcells(i)).ori_info.di;
		cv_ind{p}(end+1) = cellinfo(mygoodcells(i)).ori_info.cv;
	end;

	colors = [ 1 1 0 ; 0 0 0 ; 0 0 1 ; 1 0 0 ; 0 1 0 ];

	subplot(3,2,5);
	[x,y] = cumhist(dir_ind{p}, [0 1], 1);
	hold on;
	plot(x,y,'color',colors(p,:),'linewidth',2);
	xlabel('Direction index');
	ylabel('Cumulative percentage');
	if p==P, legend({'Het', 'WT'},'Location','NorthWest'); end;


	subplot(3,2,6);
	[x,y] = cumhist(1-cv_ind{p}, [0 1], 1);
	hold on;
	plot(x,y,'color',colors(p,:),'linewidth',2);
	xlabel('1 - CV');
	ylabel('Cumulative percentage');

end;

for p=1:P,
	subplot(3,P,p);
	A=axis;
	axis([0 360 axis_min axis_max]);
end;

output = workspace2struct;
output = rmfield(output,{'i','i90','i270','fit_new','colors','AA','BB','A','p','axis_max','axis_min'});


