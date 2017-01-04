function [Rs,Cm,Rm,waves]=lgnctx_cellprops(cksds,nameref,filenames,ints,exclude,plotit)

p = [getpathname(cksds) filesep nameref.name '_' int2str(nameref.ref) ...
	'_igordata' filesep];

I_inj = -100e-12;

FS = 20000;

T = 0:1/FS:10-1/FS;

t0 = ints(1); t1 = ints(2);

T_wave = 0:1/FS:0.3-1/FS;  % 300 ms pulses

Tpulses = [ 0.2 1.2 2.2 3.2 4.2 5.2 6.2 7.2 8.2 9.2];
waves = [];

for i=1:length(filenames),
	fn = [p filenames{i}]; r = loadIgor(fn);
	for j=1:10, % ten pulses per file
		if isempty(exclude)|isempty(find(j==exclude)),
			i = findclosest(T,Tpulses(j));
			wave = r(i+1:i+length(T_wave)) - r(i+1);
			waves = [waves; wave'];
		end;
	end;
end;

wvs = mean(waves);

t_0 = findclosest(T,t0); t_1 = findclosest(T,t1);

%[tau,b,k,err,fit]=exp_fit(T_wave(t_0:t_1),wvs(t_0:t_1));
[Re,taue,Rm,taum,err,fit]=seriesresfit(T_wave(t_0:t_1),wvs(t_0:t_1),I_inj);

Rs = Re;
Cm = taum/Rm;

if nargin>4&plotit,
	figure; plot(T_wave,wvs'/I_inj);
	hold on; plot(T_wave(t_0:t_1),fit','g','linewidth',2);
end;
