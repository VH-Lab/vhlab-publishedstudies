function [newcell,outstr,assoc]=lgnctxintrinsicanalysis(cksds,cell,cellname,display)

%  LGNCTXINTRINSICANALYSIS - Analysis of intrinsic properties of cell
%
%  [NEWSCELL,OUTSTR,ASSOC]=LGNCTXINTRINSICANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the OT Test (associate name in quotes):
%  'IT firing rate'i              |   Mean firing rate to injected current
%  'IT burster'                   |   F0 response
%  'OT Pref'                      |   Direction w/ max firing
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF)
%  'Circular variance'            |   Circular variance
%  'Tuning width'                 |   Tuning width (half width at half height)
%  'Direction index'              |   Directionality index
%  'Spontaneous rate'             |   Spontaneous rate and std dev.

newcell = cell;

assoclist = lgnctxassosciatelist('Intrinsic Firing Properties');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_lgnctx',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

pathname = getpathname(cksds);
nameref = cellname2nameref(cellname);

thedir = [ pathname filesep nameref.name '_' int2str(nameref.ref) ...
		'_igordata' filesep ];


citest = findassociate(newcell,'Current Injection Test','protocol_lgnctx',[]);
if isempty(citest), tnum = 1;  % assume first, second tests are curr injects
elseif isempty(citest.data), tnum = []; % no test performed
else, tnum = citest.data;
end;

twobad = findassociate(newcell,'Current Injection Test 2 bad',...
	'protocol_lgnctx',[]);
if ~isempty(twobad), tb = 1; else, tb = 0; end;


tnum,
if ~isempty(tnum),
	% two reps
	r1 = loadIgor([thedir 'r' sprintf('%0.3d',tnum) '_i1']);
	r1 = r1 - r1(4100); 

	dd = dotdiscriminator('default');
	p = getparameters(dd);
	spikethresh = findassociate(newcell,'CI spike thresh','protocol_lgnctx',...
		[]);
	if isempty(spikethresh),
		p.dots = [0.03 1 0];
	else, p.dots = [spikethresh.data 1 0];
	end;
	p.refractory_period = round(0.002*length(r1)/2);
	if display, disp(['Using spike threshold ' num2str(p.dots(1)) '.']); end;
	dd = dotdiscriminator(p);

	locs1 = dotdiscr(dd,r1,p.dots');
	t = 0:2/length(r1):2-2/length(r1); % time of samples
	spiketimes1 = t(locs1);
	if strcmp(cellname,'cell_ctx_0002_001_2004_03_04'),
		spiketimes1 = [0.2552 spiketimes1]; % manual fix
		locs1 = [5105 locs1']';
	elseif strcmp(cellname,'cell_ctx_0005_001_2004_03_16'),
		spiketimes1 = spiketimes1(find(spiketimes1<0.8));
		locs1 = locs1(find(locs1<16001));
	elseif strcmp(cellname,'cell_ctx_0003_001_2004_05_12'),
		spiketimes1 = [0.20425 0.2075 0.2124 0.2228 0.2352 0.2494 0.2656 0.2833 0.3019];
		locs1 = [];
		for j=1:length(spiketimes1),
			jj=findclosest(t,spiketimes1(j));
			locs1(end+1) = jj(1);
		end;
	end;

	if ~tb,
		r2 = loadIgor([thedir 'r' sprintf('%0.3d',tnum+1) '_i1']);
		r2 = r2 - r2(4100);
		locs2 = dotdiscr(dd,r2,p.dots');
		spiketimes2 = t(locs2);
		if strcmp(cellname,'cell_ctx_0005_001_2004_03_16'),
			spiketimes2=spiketimes2(find(spiketimes2<0.8));
			locs2 = locs2(find(locs2<16001));
		elseif strcmp(cellname,'cell_ctx_0003_001_2004_05_12'),
			sti=find(spiketimes2<0.8|spiketimes2>1.4);
			spiketimes2=spiketimes2(sti); locs2 = locs2(sti);
		end;
	else, spiketimes2 = [];
	end;

	if display
	  figure;
	  subplot(2,1,1);
      plot(t,r1); hold on; plot(spiketimes1,r1(locs1),'ro');
	  title([cellname ' intrinsic analysis'],'Interpreter','none');
	  if ~tb,
		  subplot(2,1,2);
	      plot(t,r2); hold on; plot(spiketimes2,r2(locs2),'ro');
	  end;
	end % display

	% look for bursters
	b1=find(diff(spiketimes1)>0.002&diff(spiketimes1)<0.008);
	if ~tb,
		b2=find(diff(spiketimes2)>0.002&diff(spiketimes2)<0.008);
	else, b2 = [];
	end;
	if ~isempty(b2)|~isempty(b1), burster=1; else, burster=0; end;
	burstfraction = (length(b1)+length(b2))/(length(spiketimes1)+length(spiketimes2));
	isis = [diff(spiketimes1) diff(spiketimes2)]; % list of ISIs

	% there is a 1.6s current injection for two trials
	if ~tb,
	    avgrate = (length(spiketimes1)+length(spiketimes2))/3.2;
	else, avgrate = length(spiketimes1)/1.6;
	end;

	% adaptation index

	if ~tb,
		init = length(find(spiketimes1<0.6))+ length(find(spiketimes2<0.6));
		late = length(find(spiketimes1>1.4))+ length(find(spiketimes2>1.4));
	else,
		init = length(find(spiketimes1<0.6));
		late = length(find(spiketimes1>1.4));
	end;

	adapt = (init-late)/(init+late+0.0001);

	if display,
		disp(['Burster ' int2str(burster) '.']);
		disp(['Burst fraction: ' num2str(burstfraction) '.']);
		disp(['Avg firing rate ' num2str(avgrate) '.']);
		disp(['ISI variability ' num2str(std(isis)/mean(isis)) '.']);
		disp(['Adaptation index ' num2str(adapt) '.']);
		disp(['Initial spike count ' int2str(init) '.']);
		disp(['Later spike count ' int2str(late) '.']);
	end;

    assoc(end+1)=newassoc('IT burster','protocol_lgnctx',burster,...
			'Is cell a burster?');
    assoc(end+1)=newassoc('IT firing rate','protocol_lgnctx',avgrate,...
			'Average firing rate to current injection');
    assoc(end+1)=newassoc('IT adaptation','protocol_lgnctx',adapt,...
			'Adaptation index');
    assoc(end+1)=newassoc('IT early spikes','protocol_lgnctx',init,...
			'Initial spike count');
    assoc(end+1)=newassoc('IT late spikes','protocol_lgnctx',late,...
			'Later spike count');
	assoc(end+1)=newassoc('IT interspikeintervals','protocol_lgn',isis,...
		'Interspike intervals');
	assoc(end+1)=newassoc('IT ISI variability','protocol_lgn',...
		std(isis)/mean(isis),'Interspike intervals standard deviation');
	assoc(end+1)=newassoc('IT burst fraction','protocol_lgn',burstfraction,...
		'burst fraction');
end;

rstest1 = findassociate(newcell,'Series resistance test 1',...
	'protocol_lgnctx',[]);
rstest2 = findassociate(newcell,'Series resistance test 2',...
	'protocol_lgnctx',[]);
rsteste1 = findassociate(newcell,'Series resistance 1 excepts',...
	'protocol_lgnctx',[]);
rsteste2 = findassociate(newcell,'Series resistance 2 excepts',...
	'protocol_lgnctx',[]);

if isempty(rstest1), rnum = 3;  % assume third, fourth tests are series tests
elseif isempty(rstest1.data), rnum = []; % no test performed
else, rnum = rstest1.data;
end;

r2bad = 0;

if ~isempty(rstest2),
	if isempty(rstest2.data), r2bad = 1;
	else, r2num = rstest2.data;
	end;
else, r2num = 4; % assume fourth test is second series test
end;

if ~isempty(rnum),
    
	rst1e = []; rst2e = [];
	if ~isempty(rsteste1), rst1e = rsteste1.data; end;
	if ~isempty(rsteste2), rst2e = rsteste2.data; end;

	fname1 = ['r' sprintf('%0.3d',rnum) '_i1'];
	[Rs,Cm,Rm,waves]=lgnctx_cellprops(cksds,nameref,{fname1},[0 0.050],rst1e,...
			display);
	if display,
		disp(['First series measurement: Rs = ' int2str(Rs) '.']);
		disp(['First capacitance meas.:  Cm = ' num2str(Cm) '.']);
		disp(['First membrane res mes.:: Rm = ' int2str(Rm) '.']);
	end;

	assoc(end+1)=newassoc('Cm','protocol_lgnctx',Cm,'Cell capacitance');
	assoc(end+1)=newassoc('Rm','protocol_lgnctx',Rm,'Membrane resistance');
	assoc(end+1)=newassoc('Rs','protocol_lgnctx',Rs,'Series resistance');

	if r2bad==0,
		fname2 = ['r' sprintf('%0.3d',r2num) '_i1'];
		[Rs2,Cm2,Rm2,waves]=lgnctx_cellprops(cksds,nameref,{fname2},[0 0.050],...
				rst2e,display);
		assoc(end+1)=newassoc('Cm2','protocol_lgnctx',Cm2,'Cell capacitance2');
		assoc(end+1)=newassoc('Rm2','protocol_lgnctx',Rm2,'Membrane resistance2');
		assoc(end+1)=newassoc('Rs2','protocol_lgnctx',Rs2,'Series resistance2');
		if display,
			disp(['2nd series measurement: Rs = ' int2str(Rs2) '.']);
			disp(['2nd capacitance meas.:  Cm = ' num2str(Cm2) '.']);
			disp(['2nd membrane res mes.:: Rm = ' int2str(Rm2) '.']);
		end;
	end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used
