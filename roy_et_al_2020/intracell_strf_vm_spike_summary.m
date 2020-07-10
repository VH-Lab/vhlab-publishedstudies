function intracell_strf_vm_spike_summary(simplecomplexonly)

% SIMPLECOMPLEXONLY - 0 means include all cells, 1 means include only simple cells, 2 means include only non-simple cells

old_data = load('experienced_data','-mat');

[c,ia] = unique({old_data.summary_curves.name});

old_data.summary_curves = old_data.summary_curves(ia);

incl_fr = find(strcmp('linepowerthreshold',{old_data.fit_curves_global.fittype}));
old_data.fit_curves_global = old_data.fit_curves_global(incl_fr);
allnames = {old_data.fit_curves_global.name};
incl_names = [];
for i=1:numel(old_data.summary_curves),
	if ~isempty(intersect({old_data.summary_curves(i).name}, allnames)),
		incl_names(end+1) = i;
	end;
end;

old_data.summary_curves = old_data.summary_curves(incl_names);

young_data = load('young_data','-mat');


[c,ia] = unique({young_data.summary_curves.name});

young_data.summary_curves = young_data.summary_curves(ia);

incl_fr = find(strcmp('linepowerthreshold',{young_data.fit_curves_global.fittype}));
young_data.fit_curves_global = young_data.fit_curves_global(incl_fr);
allnames = {young_data.fit_curves_global.name};
incl_names = [];
for i=1:numel(young_data.summary_curves),
	if ~isempty(intersect({young_data.summary_curves(i).name}, allnames)),
		incl_names(end+1) = i;
	end;
end;

young_data.summary_curves = young_data.summary_curves(incl_names);

if simplecomplexonly, 
	incl2 = [];
	for i=1:numel(old_data.fit_curves_global),
		b=intracell_strf_issimple(old_data.fit_curves_global(i).name);
		if simplecomplexonly==1 & b,
			incl2(end+1) = i;
		elseif simplecomplexonly==2 & ~b,
			incl2(end+1) = i;
		end;
	end;
	old_data.fit_curves_global = old_data.fit_curves_global(incl2);
	allnames = {old_data.fit_curves_global.name};
	incl_names = [];
	for i=1:numel(old_data.summary_curves),
		if ~isempty(intersect({old_data.summary_curves(i).name}, allnames)),
			incl_names(end+1) = i;
		end;
	end;
	old_data.summary_curves = old_data.summary_curves(incl_names);


	incl2 = [];

	for i=1:numel(young_data.fit_curves_global),
		b=intracell_strf_issimple(young_data.fit_curves_global(i).name);
		if simplecomplexonly==1 & b,
			incl2(end+1) = i;
		elseif simplecomplexonly==2 & ~b,
			incl2(end+1) = i;
		end;
	end;
	young_data.fit_curves_global = young_data.fit_curves_global(incl2);
	allnames = {young_data.fit_curves_global.name};
	incl_names = [];
	for i=1:numel(young_data.summary_curves),
		if ~isempty(intersect({young_data.summary_curves(i).name}, allnames)),
			incl_names(end+1) = i;
		end;
	end;
	young_data.summary_curves = young_data.summary_curves(incl_names);

end;



Ny = [];

for i=1:numel(young_data.summary_curves)
	Ny(i) = numel(find(young_data.summary_curves(i).firingrate_observations>0));
end;

No = [];

for i=1:numel(old_data.summary_curves)
	No(i) = numel(find(old_data.summary_curves(i).firingrate_observations>0));
end;

young_data.summary_curves = young_data.summary_curves(find(Ny>15));

[c,ai,bi] = intersect({young_data.summary_curves.name}, {young_data.fit_curves_global.name});
young_data.summary_curves = young_data.summary_curves(ai);
young_data.fit_curves_global = young_data.fit_curves_global(bi);

[c,ai,bi] = intersect({old_data.summary_curves.name}, {old_data.fit_curves_global.name});
old_data.summary_curves    = old_data.summary_curves(ai);
old_data.fit_curves_global = old_data.fit_curves_global(bi);

p_o = [];
p_y = [];

for i=1:numel(young_data.fit_curves_global),
	p_y(i,:) = young_data.fit_curves_global(i).fitdoc.document_properties.fitcurve.fit_parameters(:)';
end;

for i=1:numel(old_data.fit_curves_global),
	p_o(i,:) = old_data.fit_curves_global(i).fitdoc.document_properties.fitcurve.fit_parameters(:)';
end;

slope = 1;
threshold = 2;
offset = 3;
exponent = 4;

d_25y =   (p_y(:,exponent) .* p_y(:,slope)) .* rectify(0.025 - p_y(:,threshold)) .^ (p_y(:,exponent)-1);
fr_25y =  (p_y(:,slope)) .* rectify(0.025 - p_y(:,threshold)) .^ (p_y(:,exponent));

d_25o =   (p_o(:,exponent) .* p_o(:,slope)) .* rectify(0.025 - p_o(:,threshold)) .^ (p_o(:,exponent)-1);
fr_25o =  (p_o(:,slope)) .* rectify(0.025 - p_o(:,threshold)) .^ p_o(:,exponent);

v = 0:0.001:0.050;
vplot = -0.10:0.001:0.050;

v_fr_y = (p_y(:,slope)) .* rectify(v - p_y(:,threshold)) .^ (p_y(:,exponent));
v_fr_o = (p_o(:,slope)) .* rectify(v - p_o(:,threshold)) .^ (p_o(:,exponent));

v_fre_y = 0*(p_y(:,slope)) .* rectify(v - p_y(:,threshold)) .^ (p_y(:,exponent));  % make the vector for the interpolated empirical observations
v_fre_o = 0*(p_o(:,slope)) .* rectify(v - p_o(:,threshold)) .^ (p_o(:,exponent));  % make the vector for the interpolated empirical observations

N_fre_y = 0*(p_y(:,slope)) .* rectify(vplot - p_y(:,threshold)) .^ (p_y(:,exponent));  % make the vector for the measurement counting
N_fre_o = 0*(p_o(:,slope)) .* rectify(vplot - p_o(:,threshold)) .^ (p_o(:,exponent));  % make the vector for the measurement counting

d_y =   (p_y(:,exponent) .* p_y(:,slope)) .* rectify(v - p_y(:,threshold)) .^ (p_y(:,exponent)-1);
d_o =   (p_o(:,exponent) .* p_o(:,slope)) .* rectify(v - p_o(:,threshold)) .^ (p_o(:,exponent)-1);


for i=1:numel(old_data.summary_curves),
	N_loc = find(old_data.summary_curves(i).Xn>0 & old_data.summary_curves(i).Nn<50,1,'first');
	if ~isempty(N_loc),
		old_data.summary_curves(i).Yn(N_loc:end) = NaN;
	end;
end;
for i=1:numel(young_data.summary_curves),
	N_loc = find(young_data.summary_curves(i).Xn>0 & young_data.summary_curves(i).Nn<50,1,'first');
	if ~isempty(N_loc),
		young_data.summary_curves(i).Yn(N_loc:end) = NaN;
	end;
end;


  %%%%%%%%%

    % Empirical summary curves

figure('tag',['Empirical_summary_curves_simplecomplex_flag' int2str(simplecomplexonly) ]);


for i=1:numel(old_data.summary_curves),
	subplot(3,2,1);
	hold on;
	plot(old_data.summary_curves(i).Xn,old_data.summary_curves(i).Yn,'color',0.7*[1 0 1]);
	v_fre_o(i,:) = interp1(old_data.summary_curves(i).Xn(~isnan(old_data.summary_curves(i).Yn)), ...
			old_data.summary_curves(i).Yn(~isnan(old_data.summary_curves(i).Yn)),v,'linear',NaN);
	N_fre_o(i,:) = slidingwindowfunc(old_data.summary_curves(i).voltage_observations,old_data.summary_curves(i).voltage_observations,vplot(1)-0.001, diff(vplot(1:2)), vplot(end)+0.001, 0.001, 'numel', 1); 
	box off;
	axis([-0.010 0.050 0 150]);
	xlabel('Voltage');
	ylabel('Firing rate, spikes/sec');
	title(['Individual cells, empirical']);
	subplot(3,2,2);
	hold on;
	plot(v,v_fr_o(i,:),'color',0.7*[1 0 1]);
	box off;
	axis([-0.010 0.050 0 150]);
	xlabel('Voltage');
	ylabel('Firing rate, spikes/sec');
	title(['Individual cells, fits']);
	subplot(3,2,3);
	hold on;
	plot(v,v_fre_o(i,:),'color',0.7*[1 0 1]);
	box off;
	axis([-0.010 0.050 0 150]);
	xlabel('Voltage');
	ylabel('Firing rate, spikes/sec');
	title(['Individual cells, empirical']);
end;

for i=1:numel(young_data.summary_curves),
	subplot(3,2,1);
	hold on;
	plot(young_data.summary_curves(i).Xn,young_data.summary_curves(i).Yn,'color',0.7*[0 1 0]);
	v_fre_y(i,:) = interp1(young_data.summary_curves(i).Xn(~isnan(young_data.summary_curves(i).Yn)),...
			young_data.summary_curves(i).Yn(~isnan(young_data.summary_curves(i).Yn)),v,'linear',NaN);
	N_fre_y(i,:) = slidingwindowfunc(young_data.summary_curves(i).voltage_observations,young_data.summary_curves(i).voltage_observations,vplot(1)-0.001, diff(vplot(1:2)), vplot(end)+0.001, 0.001, 'numel', 1); 
	box off;
	subplot(3,2,2);
	hold on;
	plot(v,v_fr_y(i,:),'color',0.7*[0 1 0]);
	box off;
	subplot(3,2,3);
	hold on;
	plot(v,v_fre_y(i,:),'color',0.7*[0 1 0]);
	box off;
end;

subplot(3,2,4);

h=myerrorbar(v,nanmean(v_fre_y,1),nanstderr(v_fre_y),nanstderr(v_fre_y));
set(h,'color',[0 1 0],'linewidth',1);
hold on
h2=myerrorbar(v,nanmean(v_fre_o,1),nanstderr(v_fre_o),nanstderr(v_fre_o));
set(h2,'color',[1 0 1],'linewidth',1);

axis([-0.010 0.050 0 100]);
xlabel('Voltage');
ylabel('Firing rate, spikes/sec');
title(['Population average, empirical']);
box off;

for i=5:6,

subplot(3,2,i);

set(gca,'yscale','log');

h =  errorbar(vplot,nanmean(N_fre_y,1),0*nanstderr(N_fre_y),nanstderr(N_fre_y));
set(h,'color',[0 1 0],'linewidth',1);
hold on
h2 = errorbar(vplot,nanmean(N_fre_o,1),0*nanstderr(N_fre_o),nanstderr(N_fre_o));
set(h2,'color',[1 0 1],'linewidth',1);

xlabel('Voltage');
ylabel('Observations');
title(['Population average, empirical']);
box off;

axis([-0.010 0.050 0.1 10000]);
set(gca,'yscale','log','ytick',[1 10 100 1000 10000])

end; % for loop


 %%%%%%%%%%%%%%%

 % FIT AVERAGES

figure('tag',['Fitaverages_simplecomplex_flag' int2str(simplecomplexonly) ]);

subplot(2,2,1);

h=myerrorbar(v,nanmean(v_fr_y,1),nanstderr(v_fr_y),nanstderr(v_fr_y));
set(h,'color',[0 1 0],'linewidth',1);
hold on
h2=myerrorbar(v,nanmean(v_fr_o,1),nanstderr(v_fr_o),nanstderr(v_fr_o));
set(h2,'color',[1 0 1],'linewidth',1);
title(['Average of the fits']);

subplot(2,2,2);

h=myerrorbar(v,nanmean(d_y,1),nanstderr(d_y),nanstderr(d_y));
set(h,'color',[0 1 0],'linewidth',1);
hold on
h2=myerrorbar(v,nanmean(d_o,1),nanstderr(d_o),nanstderr(d_o));
set(h2,'color',[1 0 1],'linewidth',1);
title(['Average of the fits']);

title(['Average of the derivatives']);
box off;

 %%%%%%%%%%%%%

 % Specific values

figure('tag',['Fit_parameters_simplecomplex_flag' int2str(simplecomplexonly) ]);

subplot(2,3,1);
intracell_strf_quickplot(1,fr_25y,0);
intracell_strf_quickplot(2,fr_25o,1);
ylabel('Firing rate at 25mV, spikes/sec')
[h,p_v] = ttest2(fr_25y,fr_25o);
title(['p=' num2str(p_v)]);

subplot(2,3,2);
intracell_strf_quickplot(1,d_25y/1000,0);
intracell_strf_quickplot(2,d_25o/1000,1);
ylabel('Gain at 25mV, spikes/sec/mV')
[h,p_v] = ttest2(d_25y,d_25o);
title(['p=' num2str(p_v)]);

subplot(2,3,3);
intracell_strf_quickplot(1,p_y(:,threshold),0);
intracell_strf_quickplot(2,p_o(:,threshold),1);
ylabel('Threshold parameter, mV')
[h,p_v] = ttest2(p_y(:,threshold),p_o(:,threshold));
title(['p=' num2str(p_v)]);

subplot(2,3,4);
intracell_strf_quickplot(1,p_y(:,slope)/1000,0);
intracell_strf_quickplot(2,p_o(:,slope)/1000,1);
ylabel('Slope parameter, spikes/sec/mV')
[h,p_v] = ttest2(p_y(:,slope),p_o(:,slope));
title(['p=' num2str(p_v)]);

subplot(2,3,5);
intracell_strf_quickplot(1,p_y(:,exponent),0);
intracell_strf_quickplot(2,p_o(:,exponent),1);
ylabel('Exponent, 1-4')
[h,p_v] = ttest2(p_y(:,exponent),p_o(:,exponent));
title(['p=' num2str(p_v)]);


 %%%%%%%%%

 % Summary figures


figo = get(figure('tag',['old_simplecomplex' int2str(simplecomplexonly)]),'Number');

for i=1:numel(old_data.summary_curves),
	intracell_strf_quickvmfplot(old_data, i, 1, figo)
end;

z = get(gcf,'Number');
for i=figo:z,
	set(i,'tag',['old_' int2str(i-figo+1)  '_simplecomplex' int2str(simplecomplexonly)]);
end;

figy = get(figure('tag',['young_simplecomplex' int2str(simplecomplexonly)]),'Number');

for i=1:numel(young_data.summary_curves),
	intracell_strf_quickvmfplot(young_data, i, 0, figy);
end;

z = get(gcf,'Number');
for i=figy:z,
	set(i,'tag',['young_' int2str(i-figy+1)  '_simplecomplex' int2str(simplecomplexonly)]);
end;

