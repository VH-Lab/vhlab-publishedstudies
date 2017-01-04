function plot_sTestDoubleGaussDS(output_list)


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
	if plot_type==0,
		myerrorbar(output_list{i}.di_theory(:,1),mn_sigma_error,std_sigma_err,std_sigma_err,'b');
	elseif plot_type==1,
		xaxis_dis = output_list{i}.di_theory(:,1);
		patch([xaxis_dis(1:end)' xaxis_dis(end:-1:1)'], [p25_sigma_err(1:end)' p75_sigma_err(end:-1:1)'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.di_theory(:,1),mn_sigma_error,'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute tuning width error');
	xlabel('Underlying DI');
	axis([0 1 0 50]);

	% Opref errors
	Opref_error = cat(3,    output_list{i}.Opref_empirical - output_list{i}.Opref_theory, ...
				output_list{i}.Opref_empirical - output_list{i}.Opref_theory+360, ...
				output_list{i}.Opref_empirical - output_list{i}.Opref_theory-360);
	Opref_error = min(abs(Opref_error),[],3);
	mn_Opref_error = mean(Opref_error,2);
	std_Opref_err = stderr(Opref_error')';
	p25_Opref_err = prctile(Opref_error',25)';
	p75_Opref_err = prctile(Opref_error',75)';

	subplot(3,3,2+(i-1)*2);
	if plot_type==0,
		myerrorbar(output_list{i}.di_theory(:,1),mn_Opref_error,std_Opref_err,std_Opref_err,'b');
	elseif plot_type==1,
		xaxis_dis = output_list{i}.di_theory(:,1);
		patch([xaxis_dis(1:end)' xaxis_dis(end:-1:1)'], [p25_Opref_err(1:end)' p75_Opref_err(end:-1:1)'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.di_theory(:,1),mn_Opref_error,'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute angle error');
	xlabel('Underlying DI');
	axis([0 1 0 180]);

	di_error = abs(output_list{i}.di_empirical - output_list{i}.di_theory);
	mn_di_error = mean(di_error,2);
	std_di_err = std(di_error')';
	p25_di_err = prctile(di_error',25)';
	p75_di_err = prctile(di_error',75)';

	subplot(3,3,3+(i-1)*2);
	if plot_type==0,
		myerrorbar(output_list{i}.di_theory(:,1),mn_di_error,std_di_err,std_di_err,'b');
	elseif plot_type==1,
		xaxis_dis = output_list{i}.di_theory(:,1);
		patch([xaxis_dis(:)' xaxis_dis(end:-1:1)'], [p25_di_err(:)' p75_di_err(end:-1:1)'],[0.7 0.7 0.7]);
		hold on;
		plot(output_list{i}.di_theory(:,1),mn_di_error,'k','linewidth',2);
	end;
	box off;
	ylabel('Absolute DI error');
	xlabel('Underlying DI');
	axis([0 1 0 1]);

end;
