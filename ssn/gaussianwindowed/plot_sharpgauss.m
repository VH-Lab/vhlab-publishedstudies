function h=plot_sharpgauss(cell,cellname,varargin)
% PLOT_SHARPGAUSS - Plot size tuning for sharp/gaussian windowing
% 
%    Plots the raw data and fit results for the regular and MLE-smoothed
%    responses to sharp and gaussian windows.
%

prefix = {'SP F0 ', 'SP F1 '};
names = {'MLE gauss ', 'MLE sharp ', 'gauss ', 'sharp '};

p_ = 1;

for k=1:length(prefix),
	for j=1:length(names),
		resp = findassociate(cell,[prefix{k} names{j} 'SZ Response curve'],'','');
		fitssm =  findassociate(cell,[prefix{k} names{j} 'SZ SSM Fit'],'','');
		fitdog =  findassociate(cell,[prefix{k} names{j} 'SZ DOG Fit'],'','');

		subplot(3,3,p_);
		h2 = myerrorbar(resp.data(1,:),resp.data(2,:),resp.data(4,:),'k-');
		delete(h2(2));
		hold on;
		plot(fitssm.data(1,:),fitssm.data(2,:),'r-');
		plot(fitdog.data(1,:),fitdog.data(2,:),'b-');

		if p_==1,
			title({cellname, [' ' prefix{k} names{j}(1:end-1)]},'interp','none');
		else,
			title([prefix{k} names{j}(1:end-1)]);
		end;
		box off;
		p_ = p_ + 1;
	end;
end;

 % plot the stimuli

stim_gauss = findassociate(cell,['Contrast/length gauss stimsize'],'','');
stim_sharp = findassociate(cell,['Contrast/length sharp stimsize'],'','');

max_gauss = 3*max(stim_gauss.data.thelengths);
sigma_gauss = 0.33*max_gauss/sqrt(8*log(2));

x_gauss_positions = stim_gauss.data.x_center(1) + 3*0.5*(-max_gauss:max_gauss);
x_gauss_stimstrength = exp(-( (x_gauss_positions-stim_gauss.data.x_center(1)).^2)/(2*sigma_gauss^2));
x_gauss_stimstrength(find(x_gauss_positions>800 | x_gauss_positions<0)) = 0;

y_gauss_positions = stim_gauss.data.y_center(1) + 3*0.5*(-max_gauss:max_gauss);
y_gauss_stimstrength = exp(-( (y_gauss_positions-stim_gauss.data.y_center(1)).^2)/(2*sigma_gauss^2));
y_gauss_stimstrength(find(y_gauss_positions>600 | y_gauss_positions<0)) = 0;

max_sharp = max(stim_sharp.data.thelengths);

x_sharp_positions = stim_sharp.data.x_center(1) + 0.5*(-max_sharp:max_sharp);
x_sharp_stimstrength = 1 * ones(size(x_sharp_positions));
x_sharp_stimstrength(find(x_sharp_positions<0 | x_sharp_positions>800)) = 0;

y_sharp_positions = stim_sharp.data.y_center(1) + 0.5*(-max_sharp:max_sharp);
y_sharp_stimstrength = 1 * ones(size(y_sharp_positions));
y_sharp_stimstrength(find(y_sharp_positions>600 | y_sharp_positions<0)) = 0;

subplot(3,3,9);
plot(x_gauss_positions,4+x_gauss_stimstrength,'b');
hold on;
plot(y_gauss_positions,0+y_gauss_stimstrength,'r');
plot(x_sharp_positions,2+y_sharp_stimstrength,'b');
plot(y_sharp_positions,-2+y_sharp_stimstrength,'r');

axis([-100 900 -3 5]);

ylabel('Stimulus strength');
xlabel('Position');
box off;

