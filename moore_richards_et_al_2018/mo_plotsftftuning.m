function output=mp_plotsftftuning(cellinfo)
% MP_PLOTSFTUNING - plot spatial frequency and temporal frequency tuning information from cells
%
%  OUTPUT = MP_PLOTSFTFTUNING(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
% 

 % right now only divides cells into rearing types

struct2var(mo_definestudygroups(cellinfo)); % define variables for study groups

axis_max = -Inf;
axis_min = Inf;

axis_xmax = -Inf;

max_firing_rate_criterion = -Inf;

N = zeros(1,4);

P = length(myinds);

F_strings = {'SF','TF'};
f_strings = {'sf','tf'};

xvalues = { [0.02 0.05 0.1 0.2 0.5 0.8 1.3] , [0.5 1 2 4 6 8 12] };

for g = 1:length(F_strings),

	f_figure = figure('tag',[F_strings{g} '_' F_strings{g} 'TuningResponses']);

	for p = 1:P,

		subplot(3,P,p);
		hold on;
		mygoodcells = []; % only include responsive cells

		for i=1:length(myinds{p}),

			myfield = getfield(cellinfo(myinds{p}(i)),[f_strings{g} '_info']); % SF or TF info
			myresp = getfield(myfield,[f_strings{g} '_response_curve']);
			if numel(myresp)>2, myresp(2,:) = myresp(2,:) - myfield.blank_rate; end;

			if ~isempty(myfield.sig_vis),
				if (myfield.sig_vis< 0.05) & ( max(myresp(2,:)) >  max_firing_rate_criterion),
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

		for i=1:length(mygoodcells),
			myfield = getfield(cellinfo(mygoodcells(i)),[f_strings{g} '_info']); % SF or TF info
			myresp = getfield(myfield,[f_strings{g} '_response_curve']),
			if ~isempty(myresp), myresp(2,:) = myresp(2,:) - myfield.blank_rate; end;
			if myresp(1,1) == 0.025, myresp(1,1) = 0.02; end; % small edit
			[dummy,matchingindexes] = intersect(xvalues{g},myresp(1,:));
			f_curves_ind{p}(end+1,:) = myresp(2,matchingindexes);
			[f_curve_peak{p}(end+1),f_curve_peak_loc{p}(end+1)] = max( myresp(2,:) );
			f_curve_f_peak{p}(end+1) = myresp(1,f_curve_peak_loc{p}(end));
			interp_x = linspace(myresp(1,1), myresp(1,end));
			interp_y = interp1(myresp(1,:), myresp(2,:), interp_x, 'linear');
			plot(myresp(1,:),myresp(2,:),'color',0.5*[1 1 1]);
		end;
		if length(mygoodcells)>1,
			AA=nanmean(f_curves_ind{p});
			BB=nanstderr(f_curves_ind{p});
			h=errorbar(xvalues{g},AA,BB,BB);
			set(h,'color',[0 0 0],'linewidth',1.5);
		end;

		% deleted an 'end' here that I cannot place; why was it there?

		box off;
		title([title_strings{p} ', n=' int2str(N(p))]);
		xlabel(F_strings{g});
		ylabel('Spikes/sec');
		A = axis;
		axis_max = max(axis_max,A(4));
		axis_xmax = max(axis_xmax,max(myresp(1,:)));
		axis_min = min(axis_min,A(3));
		axis([A(1) axis_xmax axis_min axis_max]);

		set(gca,'xscale','log');

		subplot(3,P,1*P+p);
		hold on;
		f_curves_ind_norm{p} = [];
		for i=1:length(mygoodcells),
			myfield = getfield(cellinfo(mygoodcells(i)),[f_strings{g} '_info']); % SF or TF info
			myresp = getfield(myfield,[f_strings{g} '_response_curve']);
			if ~isempty(myresp), myresp(2,:) = myresp(2,:) - myfield.blank_rate; end;
			if myresp(1,1) == 0.025, myresp(1,1) = 0.02; end; % small edit
			[dummy,matchingindexes] = intersect(xvalues{g},myresp(1,:));
			f_curves_ind_norm{p}(end+1,:) = myresp(2,matchingindexes) / max(myresp(2,matchingindexes));
			plot(myresp(1,:), myresp(2,:) / max(myresp(2,:)),'color',[0.5 0.5 0.5],'linewidth',1);
		end;
		if length(mygoodcells)>1,
			AA=nanmean(f_curves_ind_norm{p});
			BB=nanstderr(f_curves_ind_norm{p});
			h=errorbar(xvalues{g},AA,BB,BB);
			set(h,'color',[0 0 0],'linewidth',1.5);
		end;

		box off;
		xlabel(F_strings{g});
		ylabel('Norm Spikes/sec');
		A=axis;
		axis([A(1) axis_xmax -1 1]);
		set(gca,'xscale','log');

	end; %loop over p

	subplot(3,2,5);
	hold on;
	peak_mns = [];
	peak_stderr = [];
	for p=1:P,
		peak_mns(p) = nanmean(f_curve_peak{p});
		peak_stderr(p) = nanstderr(f_curve_peak{p});
	end;
	h=bar([1:P],peak_mns);
	set(h,'facecolor',[0 0 0]);
	h2 = myerrorbar([1:P],peak_mns,peak_stderr,peak_stderr);
	set(h2,'color',[0 0 0],'linewidth',1);
	delete(h2(2));
	box off;
	ylabel('Firing rate');

	subplot(3,2,6);
	hold on;
	peak_pref_mns = [];
	peak_pref_stderr = [];
	for p=1:P,
		peak_pref_mns(p) = nanmean(f_curve_f_peak{p});
		peak_pref_stderr(p) = nanstderr(f_curve_f_peak{p});
	end;
	h=bar([1:P],peak_pref_mns);
	set(h,'facecolor',[0 0 0]);
	h2 = myerrorbar([1:P],peak_pref_mns,peak_pref_stderr,peak_pref_stderr);
	set(h2,'color',[0 0 0],'linewidth',1);
	delete(h2(2));
	box off;
	ylabel(['Pref ' F_strings{g}]);

	output{g} = workspace2struct;
	output{g} = rmfield(output{g},{'i','A','p','axis_max','axis_min','axis_xmax','cellinfo','h','h2'});

end; % loop over SF, TF (variable g)

return;
