function [newcell,outstr,assoc,pc]=lgnctxotanalysis(cksds,cell,cellname,display)

%  CTXOTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=LGNCTXOTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the OT Test (associate name in quotes):
%  'OT Response Curve F1'         |   F1 response
%  'OT Response Curve F0'         |   F0 response
%  'OT Pref'                      |   Direction w/ max firing
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF)
%  'Circular variance'            |   Circular variance
%  'Tuning width'                 |   Tuning width (half width at half height)
%  'Direction index'              |   Directionality index
%  'Spontaneous rate'             |   Spontaneous rate and std dev.
%
% If is intracellular,
%
%  'OT Response Curve F1V'        |   F1 response, membrane potential
%  'OT Response Curve F0V'        |   F0 response, membrane potential
%  'OT PrefV'                     |   
%  'Circular varianceV'           |   Circular variance, membrane potential
%  'Tuning widthV'                |   Tuning width (half width at half height)
%  'Direction indexV'             |   Directionality index, membrane potential
%  'Spontaneous rateV'            |   Spontaneous rate and std dev, membrane potential

MINWIDTH = 7; % minimum width for Carandini fit below

newcell = cell;

assoclist = lgnctxassosciatelist('OT Analysis');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = []; f1curve = []; 
maxgrating = []; fdtpref = []; 
circularvariance = []; tuningwidth = [];
directionindex = []; pc = [];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = []; 
end;
    

ottest = findassociate(newcell,'OT best test','protocol_lgnctx',[]);
if ~isempty(ottest),
  s=getstimscripttimestruct(cksds,ottest(end).data);
  if ~isempty(s),
    if strcmp(cellname,'cell_ctx_0003_001_2003_05_27')|strcmp(cellname,'cell_ctx_0001_001_2003_05_27'), % trials ended early
		do=getDisplayOrder(s.stimscript); do=do(1:6*12);
		s.mti=s.mti(1:6*12);
		s.stimscript=setDisplayMethod(s.stimscript,2,do);
	elseif strcmp(cellname,'cell_ctx_0001_001_2003_06_30'),
		do=getDisplayOrder(s.stimscript); do=do(1:4*12);
		s.mti=s.mti(1:4*12);
		s.stimscript=setDisplayMethod(s.stimscript,2,do);
	end;
    inp.paramnames = {'angle'};
    inp.title=['Orientation Tuning' cellname];
    inp.spikes = newcell;
    inp.st = s;

    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
	p.res = 0.050;
    pc = setparameters(pc,p);
    co = getoutput(pc); 

    lgnctxglobals;
	if lgnctxwriteotraw,
		eval([cellname 'pc=co;']);
		if exist(lgnctxwriteotloc)~=2,
			try,
				eval(['save ' lgnctxwriteotloc ' ' cellname 'pc -mat']);
			catch, disp(['WARNING: could not save ' cellname 'pc to new file']); end;
		else,
			try,
				eval(['save ' lgnctxwriteotloc ' ' cellname 'pc -append -mat']);
			catch, disp(['WARNING: could not append ' cellname 'pc']); end;
		end;
	end;

    [mf0,if0]=max(co.f0curve{1}(2,:)); 
    [mf1,if1]=max(co.f1curve{1}(2,:)); 
    maxgrating = [mf0 mf1];
    f1f0=mf1/(mf0+0.00001);  
    otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];
    
    f0curve = [f0curve; co.f0curve{1}];
    f1curve = [f1curve; co.f1curve{1}];

    circularvariance = ...
	[compute_circularvariance(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_circularvariance(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
    tuningwidth = ...
	[compute_tuningwidth(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_tuningwidth(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
    directionindex = ...
	[compute_directionindex(co.f0curve{1}(1,:),...
				co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_directionindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];

    orientationindex = ...
	[compute_orientationindex(co.f0curve{1}(1,:),...
				  co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_orientationindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];

    if(1)  % fit with Von Misen function
      if display
		figure;
      end
	spontint = [0 1000];
    for cmsmp=1:2
	  if cmsmp==2 % simple
	    curve=f1curve; spont_hint=0; ylab='F1 (Hz)'; 
		data=abs(co.f1vals{1});
	  else
	    curve=f0curve; spont_hint=co.spont(1); ylab='F0 (Hz)';
		data=abs(co.f0vals{1});
	  end
	  [rcurve,n_otpref(cmsmp),tuningwidth(cmsmp)]=...
		 	fit_otcurve(curve,otpref(cmsmp),90,...
						    maxgrating(cmsmp),spont_hint );
	% tuning_width is not calculated with spontaneous rate subtracted

    [Rsp,Rp,Ot,sigm,Rn,fitcurve,er]=otfit_carandini(curve(1,:),...
	    spont_hint,maxgrating(cmsmp)-spont_hint,otpref(cmsmp),90,...
		'widthint',[15 180],'spontfixed',spont_hint,'data',curve(2,:));
	if cmsmp==2, % f1
		CarandiniF1 = [Rsp Rp Ot sigm Rn ];
	else, CarandiniF0 = [Rsp Rp Ot sigm Rn ];
	end;

	[Rsp,Rp,Ot,sigm,Rn,fitcurve,er]=otfit_carandini(curve(1,:),...
		spont_hint,maxgrating(cmsmp)-spont_hint,otpref(cmsmp),90,...
		'spontint',spontint,'widthint',[15 180],'data',curve(2,:));  
	if cmsmp==2, % f1
		CarandiniF1sp = [Rsp Rp Ot sigm Rn ];
	else, CarandiniF0sp = [Rsp Rp Ot sigm Rn ];
	end;

	if display
	  subplot(2,1,cmsmp)
	  errorbar( curve(1,:),curve(2,:),curve(4,:),'o'); 
	  hold on
	  plot(rcurve(1,:),rcurve(2,:),'r');
	  plot(0:359,cfit,'g');
	  
	  xlabel('Orientation')
	  ylabel(ylab);
	end % display
      end % loop over F0, F1
    end  % function fitting

    assoc(end+1)=ctxnewassociate('OT F1 Response Curve',...
			f1curve,'OT F1 Response Curve');
    assoc(end+1)=ctxnewassociate('OT F0 Response Curve',...
			f0curve,'OT F0 Response Curve');
    assoc(end+1)=ctxnewassociate('OT Max drifting grating firing',...
				 maxgrating,...
				 'OT Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Pref',...
			n_otpref,'OT Direction with max. response [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Circular variance',...
			circularvariance,'OT Circular variance [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Tuning width',...
				 tuningwidth,'OT Tuning width [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Orientation index',...
				 orientationindex,...
				 'OT Orientation index [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Direction index',...
				 directionindex,'OT Direction index [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Spontaneous rate',...
				 co.spont','OT Spontaneous rate [mean std]');
       % transpose of co.spont in order not to confuse with F0 F1
    assoc(end+1)=ctxnewassociate('Carandini Fit',[CarandiniF0 ; CarandiniF1],'Carandini Fit parameters [Rsp Rp Ot sigm Rn]');
	assoc(end+1)=ctxnewassociate('Carandini Fit Sp',[CarandiniF0sp; CarandiniF1sp],'Carandini Fit parameters [Rsp Rp Ot sigm Rn], Rsp not fixed');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f1curve = f1curve; % no longer used
