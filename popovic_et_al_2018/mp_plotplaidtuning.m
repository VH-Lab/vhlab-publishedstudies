function [output] = mp_plotplaidtuning(cellinfo)
% MP_PLOTPLAIDTUNING - plot direction information from cells
%
%  OUTPUT = MP_PLOTPLAIDTUNING(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
%  OUTPUT - A list of output variables
%
% 

 % right now only divides cells into rearing types

rearing_types = {cellinfo.rearing};
rearing_inds = { find(strcmp('typical',rearing_types))  find(strcmp('dark',rearing_types))  };  % typical, dark
training_types = {cellinfo.training_type};
training_inds = { find(strcmp('multidirectional',training_types)) find(strcmp('none',training_types)) };
agegrouping_inds = { find( [cellinfo.agegroup] == 40)  find( [cellinfo.agegroup] == 60) find([cellinfo.agegroup]==90)};


 % now length tuning info

myinds = { intersect(rearing_inds{1}, agegrouping_inds{2}), intersect(rearing_inds{1}, agegrouping_inds{1}), intersect(rearing_inds{2},training_inds{2}), intersect(rearing_inds{2},training_inds{1}) };
title_strings = {'TR 60', 'TR P40','DR','DR, trained'};

myinds = { intersect(rearing_inds{1}, agegrouping_inds{3}), intersect(rearing_inds{1}, agegrouping_inds{2}), intersect(rearing_inds{1}, agegrouping_inds{1}), intersect(rearing_inds{2},training_inds{2}), intersect(rearing_inds{2},training_inds{1}) };
title_strings = {'TR 90', 'TR 60', 'TR P40','DR','DR, trained'};


xaxis_max = -Inf;
xaxis_min = Inf;
yaxis_max = -Inf;
yaxis_min = Inf;

P = length(myinds);

N = zeros(1,P);

plaidfigure = figure('tag','Plaid_ComponentVsPlaidResponses');

plaidratio = cell(P,3);


Cs = [ 0.32 0.64 1];

for p = 1:P,
for c=1:3,

	mygoodcells = []; % only include responsive cells
	for i=1:length(myinds{p}),
		if ~isempty(cellinfo(myinds{p}(i)).plaid.vis_resp_p),
			if (cellinfo(myinds{p}(i)).plaid.vis_resp_p< 0.05)
				mygoodcells(end+1) = myinds{p}(i);
			end;
		end;
	end;

	N(p) = length(mygoodcells);
	% now we have all good cells



	subplot(3,P,p+(c-1)*P);
	hold on;

	for i=1:length(mygoodcells),
		contrast_index = c + 1;
		plot(sum(cellinfo(mygoodcells(i)).plaid.normalization_curve{contrast_index}(2,1:2)),...
			 cellinfo(mygoodcells(i)).plaid.normalization_curve{contrast_index}(2,3), 'ko' );
		plaidratio{p,c}(end+1) = cellinfo(mygoodcells(i)).plaid.normalization_curve{contrast_index}(2,3) / ...
			sum(cellinfo(mygoodcells(i)).plaid.normalization_curve{contrast_index}(2,1:2));
		if isinf(plaidratio{p,c}(end)), plaidratio{p,c}(end) = 0; end;
	end;

	if c==1,
		title([title_strings{p} ', n=' int2str(N(p))]);
	end;

	box off;
	if c==3, 
		xlabel({'Component','response sum'});
	end;
	if p==1,
		ylabel('Plaid response');
	end;
	A = axis;
	xaxis_max = max(xaxis_max,A(2));
	xaxis_min = min(xaxis_min,A(1));
	yaxis_max = max(yaxis_max,A(4));
	yaxis_min = min(yaxis_min,A(3));

end;

end;

minmin = min(xaxis_min,yaxis_min);
maxmax = max(xaxis_max,yaxis_max);
maxmax = min(100, maxmax);

for p=1:P,
for c=1:3
	subplot(3,P,p+(c-1)*P);
	plot([minmin maxmax], [minmin maxmax],'k--');
	plot([minmin maxmax], [minmin maxmax/2],'k--');
	plot([minmin maxmax], [minmin maxmax/3],'k--');
	A=axis;
	axis([minmin maxmax minmin maxmax]);
end;
end;


plaidfigure_stats = figure('tag','Plaid_Stats1');

for p=1:P,
for c=1:3,
	subplot(3,P,p+(c-1)*P);
	plot(plaidratio{p,c},'o');
	xlabel('Cell number');
	box off;
	A=axis;
	axis([A(1) A(2) 0 2]);
	if c==1,
		title([title_strings{p} ', n=' int2str(N(p))]);
	end;
	if p==1,
		ylabel({'Plaid Multiplier', ['contrast = ' num2str(Cs(c),2) ]});
	end;
end;
end;

plaidfigure_bar = figure('tag','Plaid_BarGraphs');

for c=1:3,
	bar_x = [];
	bar_y = [];
	bar_e = [];
	for p=1:P,
		bar_x(end+1) = p;
		bar_y(end+1) = nanmean(plaidratio{p,c});
		bar_e(end+1) = nanstderr(plaidratio{p,c});

		subplot(3,length(Cs),c);
		h=bar(bar_x,bar_y);
		set(h,'facecolor',[0 0 0]);
		hold on;
		h2 = errorbar(bar_x,bar_y,bar_e,bar_e);
		set(h2,'color',[0 0 0],'LineStyle','none');
		if c==1, ylabel(['Average plaid multiplier']); end;
		title(['contrast = ' num2str(Cs(c),2) ]);
		axis([0 P+1 0 1]);
		box off;
	end;
end;


plaidratio_pvalue = kruskal_wallis_test(plaidratio{1,3},plaidratio{2,3},plaidratio{3,3},plaidratio{4,3});

plaidratio_pvalue = plaidratio_pvalue,

%kruskal_wallis_test(plaidratio{[1 3 4],3})

disp(['Mean of plaid ratio for 100% contrast for TR60, TR40, DR40, DRT40']);
[ nanmean(plaidratio{1,3}) nanmean(plaidratio{2,3}) nanmean(plaidratio{3,3}) nanmean(plaidratio{4,3})] 

output = workspace2struct;
output = rmfield(output,{'c','p','maxmax','minmin','xaxis_min','xaxis_max','yaxis_min','yaxis_max','A','i'});

