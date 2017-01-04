function sl_robustfig

 % copied from sl_make_simulation_robustness

Gmax_mod{1} = [ 0.25 0.5 0.75 1 1.25 1.5 1.75 2];
Gmax_mod{2} = [ 0.625 0.8750 1.125 1.375];
Inhib_mod = [ 0 0.25 0.5 0.75 1 1.25 1.5 1.75 2];

stdptitles = {'triplet','classic'};

for STDP = [1 2]  % [ 1 2]
  gind = 0;
  simNum = 0;
  p{STDP} = [];
  for k=1:2,
	for g=1:length(Gmax_mod{k}),
		gind = gind + 1;
		for i=1:length(Inhib_mod),
			try,
				['ml_' sprintf('%0.4d',simNum+1000*(STDP-1))]
				z = load(['ml_' sprintf('%0.4d',simNum+1000*(STDP-1))]);
				p{STDP}(gind,i) = z.out.di(end);
			catch,
				p{STDP}(gind,i) = NaN;
			end;
			simNum = simNum + 1;
		end;
	end;
  end; % for loop over k
end;

if k==2,
  % re-sort for the proper order
[dummy,order] = sort([Gmax_mod{1} Gmax_mod{2}]);
order,

p{1} = p{1}(order,:);
p{2} = p{2}(order,:);
end;

figure;
subplot(2,2,1);
pcolor(pcolordummyrowcolumn(p{1}));
shading faceted;
caxis([0 1]);
title(stdptitles{1});
axis square;
axis([1 10 1 9+4]);
set(gca,'xticklabel',{},'yticklabel',{});
subplot(2,2,2);
pcolor(pcolordummyrowcolumn(p{1}));
caxis([0 1]);
colorbar;

if length(p)<2, return; end;

subplot(2,2,3);
pcolor(pcolordummyrowcolumn(p{2}));
shading faceted;
caxis([0 1]);
title(stdptitles{2});
axis square;
axis([1 10 1 9+4]);
set(gca,'xticklabel',{},'yticklabel',{});
subplot(2,2,4);
pcolor(pcolordummyrowcolumn(p{2}));
caxis([0 1]);
colorbar;
