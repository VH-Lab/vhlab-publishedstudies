function neilplotlinearmodel(slope_dist)

figure; 
bins = -0.100:0.001:0.2;

axis_top = 0.05;

labels = {'Control','1 Hz','4Hz'};

for i=1:3,

	N{i}=histc(slope_dist(:,i),bins);

	subplot(3,1,i);

	hold off;
	bar(bins,N{i}/sum(N{i}));
	hold on;
	plot(prctile(slope_dist(:,i),[5 5]),[0 0.05],'k-');
	plot(prctile(slope_dist(:,i),[95 95]),[0 0.05],'k-');
	axis([bins(1) bins(end) 0 axis_top]);
 	ylabel(labels{i});
	box off;
end;


