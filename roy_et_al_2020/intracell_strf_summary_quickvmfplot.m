function out = intracell_strf_summary_quickvmfplot(curvestruct)

Nx = 5;
Ny = 6;

showfit = 1;

c = [0 1 0 ; 1 0 1 ] ; % green for young, magenta for old

agestr = {'y','o'};

v_interp = 0:0.001:0.050;
v_plot = -0.10:0.001:0.050;

v_plot_lowsample = findclosest(v_plot,v_interp(1));
v_plot_highsample = findclosest(v_plot,v_interp(end));

v_summary = {[] []};
n_summary = {[] []};

currentfigs = get(0,'children');
fig = figure;

for i=1:numel(curvestruct),

	supersubplot(fig,Ny,Nx,i);

	plot(curvestruct(i).voltage_observations,...
		curvestruct(i).firingrate_observations,'o');

	N_loc = find(curvestruct(i).Xn>0.01 & curvestruct(i).Nn<50,1,'first');
	curvestruct(i).Yn(N_loc:end) = NaN;

	if 1,
		hold on;
		plot(curvestruct(i).fit(2).voltages,curvestruct(i).fit(2).fr,'color',...
			c(1+1-curvestruct(i).young,:),'linewidth',2);
		if ~strcmp(curvestruct(i).fit(2).fittype,'linepowerthreshold'),
			error(['We were trying to access linepowerthreshold, got ' curvestruct(i).fit(2).fittype ' instead.']);
		end;
	end;

	h=myerrorbar(curvestruct(i).Xn,curvestruct(i).Yn,curvestruct(i).Yint,curvestruct(i).Yint);
	set(h,'color',[0 0 0],'linewidth',2);
	delete(h(2));

	title([curvestruct(i).name ' ' agestr{1+1-curvestruct(i).young}]);

	box off;

	axis([-0.010 0.050 0 150]);

	if numel(find(curvestruct(i).firingrate_observations>0))>15, % exclude cells with no or almost no spikes
		v_summary{1+1-curvestruct(i).young}(:,end+1) = interp1(curvestruct(i).Xn(~isnan(curvestruct(i).Yn)), ...
				curvestruct(i).Yn(~isnan(curvestruct(i).Yn)), v_interp, 'linear', NaN);
		n_summary{1+1-curvestruct(i).young}(:,end+1) = slidingwindowfunc(curvestruct(i).voltage_observations,...
			curvestruct(i).voltage_observations,v_plot(1)-0.001, diff(v_plot(1:2)), v_plot(end)+0.001, 0.001, 'numel', 1);
	end;
end;

added_figs = setdiff(get(0,'children'),currentfigs);

numbers = [];
for i=1:numel(added_figs),
	numbers(i) = get(added_figs(i),'Number');
end;

[numbers_sorted,sortindexes] = sort(numbers);

for i=1:numel(numbers_sorted),
	set(numbers_sorted(i),'tag',['VMF_Fig_' int2str(i)]);
end;


empirical_summary_fig = figure('tag','empirical_summary_fig');

for i=1:2,
	for k=1:size(v_summary{i},2), % for number of columns
		plot(v_interp(:), v_summary{i}(:,k), 'color', c(i,:) );
		hold on;
	end;
end;
ylabel('Firing rate (spikes/sec)');
xlabel('Membrane potential (V)');
box off;

empirical_summary_mean_fig = figure('tag','empirical_summary_mean_fig');

 % do fits

for i=1:2,
    y = colvec(nanmean(v_summary{i},2));
    w = colvec(nanmean(n_summary{i}([v_plot_lowsample:v_plot_highsample]'),2));
    w(find(isnan(y))) = 0;
    y(find(isnan(y))) = 0; 
	[slope{i},offset{i},threshold{i},exponent{i}, curve{i},gof{i},fitinfo{i}] = ...
		linepowerthresholdfit(v_interp(:), y, ...
			'threshold_start',0,'threshold_range',[0 0.01], ...
			'exponent_start',1,'exponent_range',[1 4],...
			'offset_start',0,'offset_range',[0 0],...
			'weights',w);
end;


for i=1:2,
	h=myerrorbar(v_interp(:), nanmean(v_summary{i},2), nanstderr(v_summary{i}')', nanstderr(v_summary{i}')');
	hold on;
	set(h,'color',c(i,:));
	if showfit,
		delete(h(2));
		h2=plot(v_interp(:),curve{i}(:),'color',c(i,:));
	else,

	end;

end;

[adjusted_p,raw_p] = twocurves_bhfdr(v_summary{1},v_summary{2});
  % the adjusted_p depends on independence; we don't have independence here, we can't test across comparisons rigorously with common methods
for i=1:numel(raw_p),
	if raw_p(i)<0.01,
		text(v_interp(i),65,'$');
	elseif raw_p(i)<0.05,
		text(v_interp(i),65,'*');
	end;
end;

ylabel('Firing rate (spikes/sec)');
xlabel('Membrane potential (V)');
box off;




empirical_summary_N_mean_fig = figure('tag','empirical_summary_N_mean_fig');

for i=1:2,
	h=myerrorbar(v_plot(:), nanmean(n_summary{i},2), nanstderr(n_summary{i}')', nanstderr(n_summary{i}')');
	hold on;
	set(h,'color',c(i,:));
	delete(h(2));
end;

ylabel('Average number observations');
xlabel('Membrane potential (V)');
box off;

out = var2struct('slope','offset','threshold','exponent','curve','gof','fitinfo');
