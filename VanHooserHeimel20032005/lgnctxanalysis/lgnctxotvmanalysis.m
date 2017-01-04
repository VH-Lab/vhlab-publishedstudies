function [newcell,outstr,assoc,pc]=lgnctxotanalysis(cksds,cell,cellname,display)

%  LGNCTXOTVMANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=LGNCTXOTVMANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
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
%                                 |      (at optimal TF, SF)
%  'Circular variance'            |   Circular variance
%  'Tuning width'                 |   Tuning width (half width at half height)
%  'Direction index'              |   Directionality index
%  'Spontaneous rate'             |   Spontaneous rate and std dev.
%
MINWIDTH = 7; % min with of carandini orientation fit

newcell = cell;

assoclist = lgnctxassosciatelist('OTVM Analysis');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = []; f1curve = []; 
maxgrating = []; fdtpref = []; 
circularvariance = []; tuningwidth = [];
directionindex = []; pc = [];

ottest = findassociate(newcell,'OT best test','protocol_lgnctx',[]);
if ~isempty(ottest),
  s=getstimscripttimestruct(cksds,ottest(end).data);
  if ~isempty(s),

	A.t0 = 0.002; A.t1 = 0.009;
	A.spiketimes = get_data(newcell,[0 Inf], 2);
	nameref = cellname2nameref(cellname);
    cksmd = cksfiltereddata(getpathname(cksds),nameref.name,nameref.ref,...
			3,A,'','');
	if strcmp(cellname,'cell_ctx_0003_001_2003_05_27')|strcmp(cellname,'cell_ctx_0001_001_2003_05_27'), % trials ended early
		do=getDisplayOrder(s.stimscript); do=do(1:6*12);
		s.mti=s.mti(1:6*12);
		s.stimscript=setDisplayMethod(s.stimscript,2,do);
	elseif strcmp(cellname,'cell_ctx_0001_001_2003_06_30'),
		do=getDisplayOrder(s.stimscript); do=do(1:4*12);
		s.mti=s.mti(1:4*12);
		s.stimscript=setDisplayMethod(s.stimscript,2,do);
	end;
    co = analyze_periodicscript_cont(cksmd,s,'angle',1e-3,'whole'),

	if display, plot_periodicscript_comps(co); end;

    lgnctxglobals;
	if lgnctxwriteotvmraw,
		eval([cellname 'vm=co;']);
		if exist(lgnctxwriteotvmloc)~=2,
			try,
				eval(['save ' lgnctxwriteotvmloc ' ' cellname 'vm -mat']);
			catch, disp(['WARNING: could not save ' cellname 'vm to new file']); end;
		else,
			try,
				eval(['save ' lgnctxwriteotvmloc ' ' cellname 'vm -append -mat']);
			catch, disp(['WARNING: could not append ' cellname 'vm']); end;
		end;
	end;

    [mf0,if0]=max(co.f0curve(2,:)); 
    [mf1,if1]=max(abs(co.f1curve(2,:))); 
    maxgrating = [mf0 mf1];
    f1f0=mf1/(mf0+0.00001);  
    otpref = [co.f0curve(1,if0) abs(co.f1curve(1,if1))];
    
    f0curve = [f0curve; co.f0curve];
    f1curve = abs([f1curve; co.f1curve]);
    
    circularvariance = ...
	[compute_circularvariance(co.f0curve(1,:),co.f0curve(2,:)-co.spontf0mean) ...
	 compute_circularvariance(co.f1curve(1,:),abs(co.f1curve(2,:)-co.spontf1mean))];
    tuningwidth = ...
	[compute_tuningwidth(co.f0curve(1,:),co.f0curve(2,:)-co.spontf0mean) ...
	 compute_tuningwidth(co.f1curve(1,:),abs(co.f1curve(2,:)-co.spontf1mean))];
    directionindex = ...
	[compute_directionindex(co.f0curve(1,:),...
				co.f0curve(2,:)-co.spontf0mean) ...
	 compute_directionindex(co.f1curve(1,:),abs(co.f1curve(2,:)-co.spontf1mean))];

    orientationindex = ...
	[compute_orientationindex(co.f0curve(1,:),...
				  co.f0curve(2,:)-co.spontf0mean) ...
	 compute_orientationindex(co.f1curve(1,:),abs(co.f1curve(2,:)-co.spontf1mean))];

	 disp(['here']);

    if(1)  % fit with Von Misen function
      if display
		figure;
      end
    for cmsmp=1:2
	  if cmsmp==2 % simple
	    curve=f1curve; spont_hint=abs(co.spontf1mean); ylab='F1 (Hz)';
		data=abs(co.f1vals);
		spontint = [ 0 1];
	  else
	    curve=f0curve; spont_hint=co.spontf0mean; ylab='F0 (Hz)';
		data=co.f0vals;
		spontint = [ -0.080 -0.020]; % constrain spontaneous interval
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
		'widthint',[15 180],'spontint',spontint,'data',curve(2,:));
		%spont_hint,otpref(cmsmp),maxgrating(cmsmp),
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

    assoc(end+1)=newassoc('OTVM F1 Response Curve','protocol_lgnctx',...
			f1curve,'OTVM F1 Response Curve');
    assoc(end+1)=newassoc('OTVM F0 Response Curve','protocol_lgnctx',...
			f0curve,'OTVM F0 Response Curve');
    assoc(end+1)=newassoc('OTVM Max drifting grating voltage','protocol_lgnctx',...
				 maxgrating,...
				 'OTMV Max voltage to a drifting grating [F0 F1]');
    assoc(end+1)=newassoc('OTVM Pref','protocol_lgnctx',...
			n_otpref,'OTVM Direction with max. response [F0 F1]');
    assoc(end+1)=newassoc('OTVM Circular variance','protocol_lgnctx',...
			circularvariance,'OTVM Circular variance [F0 F1]');
    assoc(end+1)=newassoc('OTVM Tuning width','protocol_lgnctx',...
				 tuningwidth,'OTVM Tuning width [F0 F1]');
    assoc(end+1)=newassoc('OTVM Orientation index','protocol_lgnctx',...
				 orientationindex,...
				 'OTVM Orientation index [F0 F1]');
    assoc(end+1)=newassoc('OTVM Direction index','protocol_lgnctx',...
				 directionindex,'OTVM Direction index [F0 F1]');
    assoc(end+1)=newassoc('OTVM Spontaneous rate','protocol_lgnctx',...
				 [co.spontf0mean abs(co.spontf1mean)],'OTVM Spontaneous rate [F0 F1]');
       % transpose of co.spont in order not to confuse with F0 F1
	assoc(end+1)=newassoc('OTVM Carandini Fit','protocol_lgnctx',[CarandiniF0 ; CarandiniF1],...
		'OTVM Carandini params F0: [Rsp Rp Op sigm Rn]');
	assoc(end+1)=newassoc('OTVM Carandini Fit Sp','protocol_lgnctx',[CarandiniF0sp;CarandiniF1sp],...
		'OTVM Carandini params F1: [Rsp Rp Op sigm Rn], Rsp not fixed');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f1curve = f1curve; % no longer used
