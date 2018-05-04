function mr_plotsfwaveformsfromtuning(cellinfo, cells, cellnames, prefix, out, categories)
% MR_PLOTSFWAVEFORMSFROMTUNING
%
% 

for p=categories,

	[sorted_obs,sortorder] = sort(out{1}.f_curve_blank{p});

	mysortedcells = out{1}.f_goodcells{p}(sortorder);

	fig = figure;
	for i=1:numel(mysortedcells)
		disp(['Working on cell ' int2str(i) ' of ' int2str(numel(mysortedcells)) '.'])
		ind = mysortedcells(i);
		[t,wv] = mr_sfspontwaveform(cellinfo(ind), cells{ind}, cellnames{ind}, prefix);
		ax = supersubplot(fig,6,2,i);
		plot(t,wv);
		A=axis;
		axis([min(t) max(t) -200 200]);
		ylabel({out{1}.title_strings{p}   [num2str(sorted_obs(i))]  }  );
		box off;
		drawnow;
	end
end


