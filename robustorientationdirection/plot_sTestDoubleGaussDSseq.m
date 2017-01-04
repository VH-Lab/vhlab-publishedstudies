function plot_sTestDoubleGaussDS(pathname)

labels = {'Noise','Angles','NumTrials'};

values = {  [1 3 5 7], [11.5 22.5 45 90], [4 6 8 10] };

fl{1}{1} = 'output_DS_noise1';
fl{1}{2} = 'output_DS_noise3';
fl{1}{3} = 'output_DS';
fl{1}{4} = 'output_DS_noise7';

fl{2}{1} = 'output_DS_angles3';
fl{2}{2} = 'output_DS';
fl{2}{3} = 'output_DS_angles2';
fl{2}{4} = 'output_DS_angles1';

fl{3}{1} = 'output_DS';
fl{3}{2} = 'output_DS_numTrials1';
fl{3}{3} = 'output_DS_numTrials2';
fl{3}{4} = 'output_DS_numTrials3';

color_list = { 0*[1 1 1], 0.2*[1 1 1], 0.4*[1 1 1], 0.6*[1 1 1], 0.8*[1 1 1] };


f = figure;

plot_type = 1; % 0 is mean + std dev, 1 is mean plus 25-75 patches

for i=1:size(fl,2),
	for j=1:length(fl{i}),
		output = getfield(load([pathname filesep fl{i}{j} '.mat']),'output');
		% sigma errors
		sigma_error = abs(output.sigma_empirical - output.sigma_theory);
		mn_sigma_error = mean(sigma_error,2);
		std_sigma_err = std(sigma_error')';

		subplot(3,3,1+(i-1)*3);
		[dummy,inds] = sort(output.di_theory(:,1));
		hold on;
		plot(output.di_theory(inds,1),mn_sigma_error(inds),'linewidth',2,'color',color_list{j});
		box off;
		ylabel('Absolute tuning width error');
		xlabel('Underlying DI');
		axis([0 1 0 50]);
		title([ labels{i} ': ' mat2str(values{i}) ]);

		% Opref errors
		Opref_error = cat(3,    output.Opref_empirical - output.Opref_theory, ...
				output.Opref_empirical - output.Opref_theory+360, ...
				output.Opref_empirical - output.Opref_theory-360);
		Opref_error = min(mod(abs(Opref_error),360),[],3);
		%mn_Opref_error = mean(Opref_error,2);
		mn_Opref_error = 100*sum(Opref_error<=90,2)/size(Opref_error,2);
		std_Opref_err = stderr(Opref_error')';

		subplot(3,3,2+(i-1)*3);
		hold on;
		plot(output.di_theory(inds,1),mn_Opref_error,'linewidth',2,'color',color_list{j});
		box off;
		ylabel('Percent simulations with correct direction');
		xlabel('Underlying DI');
		axis([0 1 0 110]);

		di_error = abs(output.di_empirical - output.di_theory);
		mn_di_error = mean(di_error,2);
		std_di_err = std(di_error')';

		subplot(3,3,3+(i-1)*3);
		hold on;
		plot(output.di_theory(inds,1),mn_di_error,'linewidth',2,'color',color_list{j});
		box off;
		ylabel('Absolute DI error');
		xlabel('Underlying DI');
		axis([0 1 0 1]);

	end;
end;
