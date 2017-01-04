function [comps] = lgnctxanalyzecurrentsteps(cksmd,sts,p,curr_inj,Rs,timeres,howanalyze,spikes,cksm)

% LGNCTXANALYZECURRENTSTEPS Analyze a periodicscript with multiple current steps
%
%   [COMPS]=ANALYZE_PERIODICSCRIPT_CONT(CKSMD,STS,PARAMETER,CURR_INJ,TIMERES,...
%        HOWANALYZE)
%
%  Computes individual, mean, standard deviations, and standard errors of the
%  F0, F1, and F2 components of the response to a periodic_script for different
%  current injections listed in CURR_INJ.  CMSMD is a CKSMEASUREDDATA object
%  with continuously-measured data, STS is a
%  stimscripttimestruct containing a periodic_script and its timing record,
%  PARAMETER is the varied parameter of interest (e.g., 'angle'), and TIMERES
%  is the time resolution of the desired answer (e.g., 1e-3s,1e-4s, etc.).
%  HOWANALYZE is one of the following strings:
%     'whole'            analyze over all of each stimulus
%  
%  COMPS is a structure containing fields f0, f1, f2, f0mean, f1mean, f2mean,
%  f0stddev,f1stddev,f2stddev,f0stderr,f1stderr, f2stderr,indwaves,meanwaves,
%  stdwaves,samptimes (the sample times for indwaves,meanwaves,stdwaves).
%  All of these fields are cells.  If the analysis is 'whole', then there are
%  as many cells for each parameter as stimuli in the periodic_script.
%  If the analysis is 'cycle-by-cycle', then the cells are
%  numofcyclesXnumofstim.
%
%  See also:  PERIODICSCRIPT, STIMSCRIPTTIMESTRUCT

ps = sts.stimscript;
params = getparameters(ps);
nCyc = params.nCycles;

do = getDisplayOrder(ps);
d0 = curr_inj;
injs = unique(d0);
stims = unique(do);

BEFORE_TIME = 0.3;
BEFORE_INTERVAL=0.1;

for d=1:length(injs),
	stimsatinj=find(d0==injs(d));
	sptrigs = [];
	for i=1:length(stims),
		i,
		stiminds=stimsatinj(find(do(stimsatinj)==stims(i)));
		pp=getparameters(get(ps,i));
		curve{d}(i)=getfield(pp,p);
		switch howanalyze
		case 'whole',
			trigs=[]; len=[]; meanfdt=[];
			for j=1:length(stiminds),
				trigs(j)=sts.mti{stiminds(j)}.frameTimes(1);
				meanfdt(j)=mean(diff(sts.mti{stiminds(j)}.frameTimes));
				len(j)=sts.mti{stiminds(j)}.frameTimes(end)-trigs(j)+meanfdt(j);
				sptrigs = [ sptrigs spikes(find(spikes>trigs(j)&spikes<trigs(j)+len(j))) ];
			end;
			[indwaves{d}{i},meanwaves{d}{i},stdwaves{d}{i},sampletimes{i}]=...
				raster_continuous(cksmd,trigs,0,median(len),timeres);
			indwaves{d}{i}=indwaves{d}{i}-Rs*injs(d);
			meanwaves{d}{i}=meanwaves{d}{i}-Rs*injs(d);
			b4trigs = trigs - BEFORE_TIME;
			[b4indwaves{d}{i},b4meanwaves{d}{i},b4stdwaves{d}{i},...
				b4sampletimes{d}{i}]=...
				raster_continuous(cksmd,b4trigs,0,BEFORE_INTERVAL,timeres);
			b4indwaves{d}{i} = b4indwaves{d}{i}-Rs*injs(d);
			b4meanwaves{d}{i} = b4meanwaves{d}{i}-Rs*injs(d);
			dp=struct(getdisplayprefs(get(ps,i)));
			fpc=length(unique(dp.frames));
			estper=fpc*mean(meanfdt);
			curve{d}(i)=getfield(pp,p);
			f0{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',0,1/timeres);
			f1{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',1/estper,1/timeres);
			f2{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',2/estper,1/timeres);
			f0mean{d}(i)=mean(f0{d}{i}); f1mean{d}(i)=mean(f1{d}{i});
			f2mean{d}(i)=mean(f2{d}{i});
			f0stddev{d}(i)=std(f0{d}{i}); f1stddev{d}(i)=std(f1{d}{i});
			f2stddev{d}(i)=std(f2{d}{i});
			f0stderr{d}(i)=stderr(f0{d}{i}');
			f1stderr{d}(i)=stderr(f1{d}{i}');
			f2stderr{d}(i)=stderr(f2{d}{i}');
		case 'cycle-by-cycle'
			trigs=[]; b4trigs=[];
			meanfdt = mean(diff(sts.mti{stiminds(1)}.frameTimes));
			dp=struct(getdisplayprefs(get(ps,i)));
			fpc=length(unique(dp.frames));
			estper=fpc*meanfdt;
			for j=1:length(stiminds),
				b4trigs(j)=sts.mti{stiminds(j)}.frameTimes(1)-BEFORE_TIME;
				sptrigs = [ sptrigs spikes(find(spikes>sts.mti{stiminds(j)}.frameTimes(1)&spikes<sts.mti{stiminds(j)}.frameTimes(end))) ];
				for c=1:nCyc, trigs(end+1)=sts.mti{stiminds(j)}.frameTimes(1+(c-1)*fpc); end;
			end;
			[indwaves{d}{i},meanwaves{d}{i},stdwaves{d}{i},sampletimes{i}]=...
				raster_continuous(cksmd,trigs,0,estper,timeres);
			indwaves{d}{i}=indwaves{d}{i}-Rs*injs(d);
			meanwaves{d}{i}=meanwaves{d}{i}-Rs*injs(d);
			[b4indwaves{d}{i},b4meanwaves{d}{i},b4stdwaves{d}{i},...
				b4sampletimes{d}{i}]=...
				raster_continuous(cksmd,b4trigs,0,BEFORE_INTERVAL,timeres);
			b4indwaves{d}{i} = b4indwaves{d}{i}-Rs*injs(d);
			b4meanwaves{d}{i} = b4meanwaves{d}{i}-Rs*injs(d);
			curve{d}(i)=getfield(pp,p);
			f0{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',0,1/timeres);
			f1{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',1/estper,1/timeres);
			f2{d}{i}=fouriercoeffs_tf(indwaves{d}{i}',2/estper,1/timeres);
			f0mean{d}(i)=mean(f0{d}{i}); f1mean{d}(i)=mean(f1{d}{i});
			f2mean{d}(i)=mean(f2{d}{i});
			f0stddev{d}(i)=std(f0{d}{i}); f1stddev{d}(i)=std(f1{d}{i});
			f2stddev{d}(i)=std(f2{d}{i});
			f0stderr{d}(i)=stderr(f0{d}{i}');
			f1stderr{d}(i)=stderr(f1{d}{i}');
			f2stderr{d}(i)=stderr(f2{d}{i}');
		end;
	end;
	if length(sptrigs),
		sptrigs = sort(sptrigs(find(sptrigs<sts.mti{end}.frameTimes(end)-0.1)));
		[indspikes{d},meanspikes{d}]=raster_continuous(cksm,sptrigs,-0.010,0.010,0.00005);
	else, indspikes{d} = []; meanspikes{d} = [];
	end;
	spiketrigs{d} = sptrigs;
end;

disp(['Starting conductance calculation']);
 % calculate conductance
for i=1:length(stims),
	i,
	TT=size(indwaves{1}{i},2);
	for d=2:length(injs), if size(indwaves{d}{i},2)<TT,TT=size(indwaves{d}{i},2);end;end;
	for t=1:TT,
		x = []; y = [];
		for d=1:length(injs),
			for d_ = 1:(length(d0)/(length(injs)*length(stims))), % each trial
				x(end+1)=injs(d);
				y(end+1)=indwaves{d}{i}(d_,t);
			end;
		end;
		[poly,s]=polyfit(x,y,1); % linear fit
		g{i}(t) = 1/poly(1);
		[b,bint]=regress(y'-poly(2),x',0.05); % get 95% confidence interval
		  % might need to transpose above
		g_nconf{i}(t) = 1/bint(1); g_pconf{i}(t) = 1/bint(2);
	end;
	TT=size(b4indwaves{1}{i},2);
	for d=2:length(injs), if size(b4indwaves{d}{i},2)<TT,TT=size(b4indwaves{d}{i},2);end;end;
	for t=1:TT,
		x = []; y = [];
		for d=1:length(injs),
			for d_=1:(length(d0)/(length(injs)*length(stims))), % each trial
				x(end+1)=injs(d);
				y(end+1)=b4indwaves{d}{i}(d_,t);
			end;
		end;
		[poly,s]=polyfit(x,y,1);
		gsp{i}(t)=1/poly(1);
		[b,bint]=regress(y'-poly(2),x',0.05);
		gsp_nconf{i}(t)=1/bint(1); gsp_pconf{i}(t)=1/bint(2);
	end;
end;

comps.f0=f0;comps.f1=f1;comps.f2=f2;comps.indwaves=indwaves;
comps.meanwaves=meanwaves;comps.stdwaves=stdwaves;
comps.f0mean=f0mean; comps.f1mean=f1mean; comps.f2mean=f2mean;
comps.f0stddev=f0stddev; comps.f1stddev=f1stddev; comps.f2stddev=f2stddev;
comps.f0stderr=f0stderr; comps.f1stderr=f1stderr; comps.f2stderr=f2stderr;
comps.curve = curve;comps.sampletimes=sampletimes;
comps.b4indwaves=b4indwaves;
comps.b4meanwaves=b4meanwaves;
comps.b4stdwaves=b4stdwaves;
comps.b4sampletimes=b4sampletimes;
comps.g = g; comps.g_nconf = g_nconf; comps.g_pconf=g_pconf;
comps.gsp=gsp; comps.gsp_nconf=gsp_nconf; comps.gsp_pconf=gsp_pconf;
comps.indspikes=indspikes; comps.meanspikes=meanspikes;
comps.spiketrigs = spiketrigs;
