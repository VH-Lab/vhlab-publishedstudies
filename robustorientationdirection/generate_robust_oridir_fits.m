function generate_robust_oridir_fits(pathname)

 % figure 7 - basic curves

output=sTestDoubleGaussDS('numTrials',8);
eval(['save ' pathname filesep 'output_DS.mat output']);
output=sTestDoubleGaussOS('numTrials',4);
eval(['save ' pathname filesep 'output_OS.mat output']);

% vary noise, number of trials, and number of angles

% first noise
noises = [1 3 7 5];
for i=1:length(noises)-1,
	output = sTestDoubleGaussDS('noise_level',noises(i),'numTrials',8);
	eval(['save ' pathname filesep 'output_DS_noise' int2str(noises(i)) '.mat output noises i']);
	output = sTestDoubleGaussOS('noise_level',noises(i),'numTrials',4);
	eval(['save ' pathname filesep 'output_OS_noise' int2str(noises(i)) '.mat output noises i']);
end;

% second number of angles
anglestep= [90 45 11.5 22.5];
for i=2:length(anglestep)-1,
	output = sTestDoubleGaussDS('anglestep',anglestep(i),'numTrials',8);
	eval(['save ' pathname filesep 'output_DS_angles' int2str(i) '.mat output anglestep i']);
	output = sTestDoubleGaussOS('anglestep',anglestep(i),'numTrials',4);
	eval(['save ' pathname filesep 'output_OS_angles' int2str(i) '.mat output anglestep i']);
end;

% vary number of trials
numTrials = [ 1 2 4 6];
for i=1:length(numTrials),
	output = sTestDoubleGaussDS('numTrials',numTrials(i)*2,'anglestep',45);
	eval(['save ' pathname filesep 'output_DS_numTrials2_' int2str(i) '.mat output numTrials i']);
	%output = sTestDoubleGaussOS('numTrials',numTrials(i),'anglestep',22.5);
	%eval(['save ' pathname filesep 'output_OS_numTrials2_' int2str(i) '.mat output numTrials i']);
end;

