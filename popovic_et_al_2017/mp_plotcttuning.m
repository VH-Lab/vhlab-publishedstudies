function output=mp_plotcttuning(cellinfo)
% MP_PLOTSFTUNING - plot contrast tuning information from cells
%
%  OUTPUT = MP_PLOTCTTUNING(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
% 

 % right now only divides cells into rearing types

struct2var(mp_definestudygroups(cellinfo)); % define variables for study groups

axis_max = -Inf;
axis_min = Inf;
axis_xmin = Inf;
axis_xmax = -Inf;

max_firing_rate_criterion = -Inf;

N = zeros(1,4);

P = length(myinds);

f_figure = figure('tag',['Contrast_TuningResponses']);

for p = 1:P,

	subplot(3,P,p);
	hold on;
	mygoodcells = []; % only include responsive cells


	for i=1:length(myinds{p}),

		myfield = getfield(cellinfo(myinds{p}(i)),['contrast_info']); 
		myresp = getfield(myfield,['response_curve']);
		if numel(myresp)>2, myresp(2,:) = myresp(2,:) - myfield.blank(1); end;

		if ~isempty(myfield.sig_ct),
			if (myfield.sig_ct< 0.05) & ( max(myresp(2,:)) >  max_firing_rate_criterion),
				mygoodcells(end+1) = myinds{p}(i);
			end;
		end;
	end;

	N(p) = length(mygoodcells);
	% now we have all good cells

	f_curves_ind{p} = [];

	f_curve_peak_loc{p} = [];
	f_curve_peak{p} = [];
	f_curve_f_peak{p} = [];

	f_si{p} = [];
	f_c50{p} = [];
	f_rmg{p} = [];

	for i=1:length(mygoodcells),
		myfield = getfield(cellinfo(mygoodcells(i)),['contrast_info']); 
		myresp = getfield(myfield,['response_curve']);
		if ~isempty(myresp), myresp(2,:) = myresp(2,:) - myfield.blank(1); end;


		f_si{p}(end+1) = myfield.si;
		f_c50{p}(end+1) = myfield.c50;
		f_rmg{p}(end+1) = myfield.rmg;

		f_curves_ind{p}(end+1,:) = myresp(2,:);
		[f_curve_peak{p}(end+1),f_curve_peak_loc{p}(end+1)] = max( myresp(2,:) );
		f_curve_f_peak{p}(end+1) = myresp(1,f_curve_peak_loc{p}(end));
		interp_x = linspace(myresp(1,1), myresp(1,end));
		interp_y = interp1(myresp(1,:), myresp(2,:), interp_x, 'linear');
		plot(myresp(1,:),myresp(2,:),'color',0.5*[1 1 1]);
	end;
	if length(mygoodcells)>1,
		AA=nanmean(f_curves_ind{p});
		BB=nanstderr(f_curves_ind{p});
		h=errorbar(myresp(1,:),AA,BB,BB);
		set(h,'color',[0 0 0],'linewidth',1.5);
	end;

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Contrast');
	ylabel('Spikes/sec');
	A = axis;
	axis_max = max(axis_max,A(4));
	axis_xmax = max(axis_xmax,max(myresp(1,:)));
	axis_xmin = min(axis_xmin,min(myresp(1,:)));
	axis_min = min(axis_min,A(3));
	hold on
	plot([axis_xmin axis_xmax],[0 0],'k--');
	axis([A(1) axis_xmax axis_min axis_max]);

	set(gca,'xscale','log');

	subplot(3,P,1*P+p);
	hold on;
	f_curves_ind_norm{p} = [];
	for i=1:length(mygoodcells),
		myfield = getfield(cellinfo(mygoodcells(i)),['contrast_info']); % SF or TF info
		myresp = getfield(myfield,['response_curve']);
		if ~isempty(myresp), myresp(2,:) = myresp(2,:) - myfield.blank(1); end;

		f_curves_ind_norm{p}(end+1,:) = myresp(2,:) / max(myresp(2,:));
		plot(myresp(1,:), myresp(2,:) / max(myresp(2,:)),'color',[0.5 0.5 0.5],'linewidth',1);
	end;
	if length(mygoodcells)>1,
		AA=nanmean(f_curves_ind_norm{p});
		BB=nanstderr(f_curves_ind_norm{p});
		h=errorbar(myresp(1,:),AA,BB,BB);
		set(h,'color',[0 0 0],'linewidth',1.5);
	end;

	box off;
	xlabel('Contrast');
	ylabel('Norm Spikes/sec');
	hold on
	plot([axis_xmin axis_xmax],[0 0],'k--');
	A=axis;
	axis([A(1) axis_xmax -1 1]);
	set(gca,'xscale','log');

end; %loop over p

subplot(3,3,7);
hold on;
rmg_mns = [];
rmg_stderr = [];
for p=1:P,
	rmg_mns(p) = nanmean(f_rmg{p});
	rmg_stderr(p) = nanstderr(f_rmg{p});
end;
h=bar([1:P],rmg_mns);
set(h,'facecolor',[0 0 0]);
h2 = myerrorbar([1:P],rmg_mns,rmg_stderr,rmg_stderr);
set(h2,'color',[0 0 0],'linewidth',1);
delete(h2(2));
box off;
ylabel('RMG');

subplot(3,3,8);
hold on;
si_mns = [];
si_stderr = [];
for p=1:P,
	si_mns(p) = nanmean(f_si{p});
	si_stderr(p) = nanstderr(f_si{p});
end;
h=bar([1:P],si_mns);
set(h,'facecolor',[0 0 0]);
h2 = myerrorbar([1:P],si_mns,si_stderr,si_stderr);
set(h2,'color',[0 0 0],'linewidth',1);
delete(h2(2));
box off;
ylabel(['SI']);

subplot(3,3,9);
hold on;
c50_mns = [];
c50_stderr = [];
for p=1:P,
	c50_mns(p) = nanmean(f_c50{p});
	c50_stderr(p) = nanstderr(f_c50{p});
end;
h=bar([1:P],c50_mns);
set(h,'facecolor',[0 0 0]);
h2 = myerrorbar([1:P],c50_mns,c50_stderr,c50_stderr);
set(h2,'color',[0 0 0],'linewidth',1);
delete(h2(2));
box off;
ylabel(['C50']);

output = workspace2struct;
output = rmfield(output,{'i','A','p','axis_max','axis_min','axis_xmax','cellinfo','h','h2'});


