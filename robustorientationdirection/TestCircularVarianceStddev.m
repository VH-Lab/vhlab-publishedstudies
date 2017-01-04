function TestCircularVarianceStddev(varargin)


plotit = 1;

pathstr = uigetdir('','Please choose a directory where we should save eps files');

assign(varargin{:});

 % Step 1 - Look at OSI / DSI as a function of noise level

if 1,
disp(['Examining noise level dependence...']);
noise_levels = [1 3 5 7];
noise_level_xlabels = {'Empirical OSI' 'Empirical 1-CirVar' ; 'Empirical DSI' 'Empirical 1-DirCirVar'};
for i=1:length(noise_levels),
	outputs = sTestCircularVarianceOS('num_repeats_per_stim',10000,'doplots',0,'noise_level',noise_levels(i),'numTrials',4);
	qt_noise_levels{1,1,i,1} = outputs.xaxis_ois;
	qt_noise_levels{1,2,i,1} = outputs.xaxis_cvs;
	qt_noise_levels{1,1,i,2} = outputs.ois_theory_stddev;
	qt_noise_levels{1,2,i,2} = outputs.cvs_theory_stddev;
	outputs = sTestCircularVarianceDS('num_repeats_per_stim',10000,'doplots',0,'noise_level',noise_levels(i),'numTrials',7);
	qt_noise_levels{2,1,i,1} = outputs.xaxis_dis;
	qt_noise_levels{2,2,i,1} = outputs.xaxis_dcvs;
	qt_noise_levels{2,1,i,2} = outputs.dis_theory_stddev;
	qt_noise_levels{2,2,i,2} = outputs.dcvs_theory_stddev;
end;

if plotit,
	plot_my_stuff(qt_noise_levels, [-1 -1 ; -1 -1], noise_level_xlabels, 'STD of Underlying OSI values','Noise_dependences',pathstr);
end;
end; % if 0

if 1,
disp(['Examining trial number dependence...']);
numTrials = [8 12 16 20];
numTrials_xlabels = {'Empirical OSI' 'Empirical 1-CirVar' ; 'Empirical DSI' 'Empirical 1-DirCirVar'};
for i=1:length(numTrials),
	i,
	outputs = sTestCircularVarianceOS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',numTrials(i)/2);
	qt_trials{1,1,i,1} = outputs.xaxis_ois;
	qt_trials{1,2,i,1} = outputs.xaxis_cvs;
	qt_trials{1,1,i,2} = outputs.ois_theory_stddev;
	qt_trials{1,2,i,2} = outputs.cvs_theory_stddev;
	outputs = sTestCircularVarianceDS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',numTrials(i));
	qt_trials{2,1,i,1} = outputs.xaxis_dis;
	qt_trials{2,2,i,1} = outputs.xaxis_dcvs;
	qt_trials{2,1,i,2} = outputs.dis_theory_stddev;
	qt_trials{2,2,i,2} = outputs.dcvs_theory_stddev;
end;

if plotit,
	plot_my_stuff(qt_trials, [-1 -1 ; -1 -1], numTrials_xlabels, 'STD of Underlying OSI values','Number_of_trials_dependence',pathstr);
end;
end; % if 0/1

if 1,
disp(['Examining angle step dependence...']);
anglesteps = [11.25 22.5 45 90];
anglesteps_xlabels = {'Empirical OSI' 'Empirical 1-CirVar' ; 'Empirical DSI' 'Empirical 1-DirCirVar'};
for i=1:length(anglesteps),
	i,
	outputs = sTestCircularVarianceOS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',4,'anglestep',anglesteps(i));
	qt_anglesteps{1,1,i,1} = outputs.xaxis_ois;
	qt_anglesteps{1,2,i,1} = outputs.xaxis_cvs;
	qt_anglesteps{1,1,i,2} = outputs.ois_theory_stddev;
	qt_anglesteps{1,2,i,2} = outputs.cvs_theory_stddev;
	outputs = sTestCircularVarianceDS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',7,'anglestep',anglesteps(i));
	qt_anglesteps{2,1,i,1} = outputs.xaxis_dis;
	qt_anglesteps{2,2,i,1} = outputs.xaxis_dcvs;
	qt_anglesteps{2,1,i,2} = outputs.dis_theory_stddev;
	qt_anglesteps{2,2,i,2} = outputs.dcvs_theory_stddev;
end;

if plotit,
	plot_my_stuff(qt_anglesteps, [-1 -1 ; -1 -1], anglesteps_xlabels, 'STD of Underlying OSI values','Angle_dependences',pathstr);
end;
end; % if 0/1

if 1,
disp(['Examining joint angle step / numTrials dependence...']);
anglesteps = [11.25 22.5 45 90];
numTrials = [ 8 16 32 64]/2;
anglesteps_xlabels = {'Empirical OSI' 'Empirical 1-CirVar' ; 'Empirical DSI' 'Empirical 1-DirCirVar'};
for i=1:length(anglesteps),
	i,
	outputs = sTestCircularVarianceOS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',numTrials(i)/2,'anglestep',anglesteps(i));
	qt_anglesteps{1,1,i,1} = outputs.xaxis_ois;
	qt_anglesteps{1,2,i,1} = outputs.xaxis_cvs;
	qt_anglesteps{1,1,i,2} = outputs.ois_theory_stddev;
	qt_anglesteps{1,2,i,2} = outputs.cvs_theory_stddev;
	outputs = sTestCircularVarianceDS('num_repeats_per_stim',10000,'doplots',0,'noise_level',5,'numTrials',numTrials(i),'anglestep',anglesteps(i));
	qt_anglesteps{2,1,i,1} = outputs.xaxis_dis;
	qt_anglesteps{2,2,i,1} = outputs.xaxis_dcvs;
	qt_anglesteps{2,1,i,2} = outputs.dis_theory_stddev;
	qt_anglesteps{2,2,i,2} = outputs.dcvs_theory_stddev;
end;

if plotit,
	plot_my_stuff(qt_anglesteps, [-1 -1 ; -1 -1], anglesteps_xlabels, 'STD of Underlying OSI values','Joint_Angle_NumTrials_dependences',pathstr);
end;
end; % if 0/1

function plot_my_stuff(values, figures, xlabels, ylabelstr, titlestr, pathstr)
for i=1:size(values,3),
	for j=1:size(values,1),
		for k=1:size(values,2),
			if ~ishandle(figures(j,k)),
				figures(j,k) = figure;
			end;
			figure(figures(j,k));
			hold on;
			color = [0 0 0] + (i-1)/(size(values,3)); % make sure we don't quite go to white [1 1 1]
			plot(values{j,k,i,1},values{j,k,i,2},'color',color,'linewidth',2);
			box off;
			xlabel(xlabels{j,k});
			ylabel(ylabelstr);
			title(titlestr,'interp','none');
		end;
	end;
end;
for j=1:size(values,1),
	for k=1:size(values,2),
		figure(figures(j,k));
		if k==1,
			axis([0 1.5 0 0.30]);
		else,
			axis([0 1 0 0.30]);
		end;
	end;
end;

if ~isempty(pathstr),
	for j=1:size(values,1),
		for k=1:size(values,2),
			figure(figures(j,k));
			saveas(figures(j,k),[pathstr filesep titlestr '_' int2str(j) '_' int2str(k) '.eps'],'epsc');
		end;
	end;
end;
