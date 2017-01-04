function plot_sTestDoubleGaussOS(output_list)


f = figure;

plot_type = 1; % 0 is mean + std dev, 1 is mean plus 25-75 patches

for i=1:length(output_list),
	% sigma errors
	sigma_error = abs(output_list{i}.sigma_empirical - output_list{i}.sigma_theory);
	mn_sigma_error = mean(sigma_error,2);
	std_sigma_err = std(sigma_error')';
	p25_sigma_err = prctile(sigma_error',25)';
	p75_sigma_err = prctile(sigma_error',75)';

	subplot(3,3,1+(i-1)*2);
	[dummy,inds] = sort(output_list{i}.oi_theory(:,1));
	if plot_type==0,
		myerrorbar(output_list{i}.oi_theory(inds,1),mn_sigma_error,std_sigma_err,std_sigma_err,'b');
	elseif plot_type==1,
		xaxis_ois = output_list{i}.oi_theory(inds,1);
		patch([xaxis_ois(1:end)' xaxis_ois(end:-1:1)'], [p25_sigma_err(inds(1:end))' p75_sigma_err(inds(end:-1:1))'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.oi_theory(inds,1),mn_sigma_error(inds),'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute tuning width error');
	xlabel('Underlying OI');
	axis([0 1 0 50]);

	% Opref errors
	Opref_error = cat(3,    output_list{i}.Opref_empirical - output_list{i}.Opref_theory, ...
				output_list{i}.Opref_empirical - output_list{i}.Opref_theory+360, ...
				output_list{i}.Opref_empirical - output_list{i}.Opref_theory-360);
	Opref_error = min(mod(abs(Opref_error),180),[],3);
	mn_Opref_error = mean(Opref_error,2);
	std_Opref_err = stderr(Opref_error')';
	p25_Opref_err = prctile(Opref_error',25)';
	p75_Opref_err = prctile(Opref_error',75)';

	subplot(3,3,2+(i-1)*2);
	if plot_type==0,
		myerrorbar(output_list{i}.oi_theory(:,1),mn_Opref_error,std_Opref_err,std_Opref_err,'b');
	elseif plot_type==1,
		xaxis_ois = output_list{i}.oi_theory(inds,1);
		patch([xaxis_ois(1:end)' xaxis_ois(end:-1:1)'], [p25_Opref_err(inds(1:end))' p75_Opref_err(inds(end:-1:1))'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.oi_theory(inds,1),mn_Opref_error,'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute angle error');
	xlabel('Underlying OI');
	axis([0 1 0 50]);

	oi_error = abs(output_list{i}.oi_empirical - output_list{i}.oi_theory);
	mn_oi_error = mean(oi_error,2);
	std_oi_err = std(oi_error')';
	p25_oi_err = prctile(oi_error',25)';
	p75_oi_err = prctile(oi_error',75)';

	subplot(3,3,3+(i-1)*2);
	if plot_type==0,
		myerrorbar(output_list{i}.oi_theory(inds,1),mn_oi_error,std_oi_err,std_oi_err,'b');
	elseif plot_type==1,
		xaxis_ois = output_list{i}.oi_theory(inds,1);
		patch([xaxis_ois(:)' xaxis_ois(end:-1:1)'], [p25_oi_err(inds)' p75_oi_err(inds(end:-1:1))'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.oi_theory(inds,1),mn_oi_error,'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute OI error');
	xlabel('Underlying OI');
	axis([0 1 0 1]);

end;
