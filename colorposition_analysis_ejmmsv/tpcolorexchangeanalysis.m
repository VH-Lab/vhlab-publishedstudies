function [newcell,assoc]=tpcolorexchangeanalysis(ds,cell,cellname,display)

%  TPCOLOREXCHANGEANALYSIS
%
%  [NEWSCELL,ASSOC]=TPCOLOREXCHANGEANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the color exchange tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%
%  Measures gathered from the CE Test (associate name in quotes):
%
%  'CE visual response'           |   0/1 Was response significant w/ P<0.05?
%  'CE visual response p'         |   Anova p across stims and blank (if available)
%  'CE varies'                    |   0/1 Was response significant across CE?
%  'CE varies p'                  |   Anova p across stims
%
%  A list of associate types that TPCOLOREXCHANGEANALYSIS computes is returned if
%  the function is called with no arguments.

if nargin==0,
        % edit these to reflect new indices
	newcell = { 'CE visual response','CE visual response p','CE varies','CE varies p'};
	return;
end;

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

ceresp = findassociate(newcell,'Color exchange resp','',[]);
cetest = findassociate(newcell,'Color exchange test','',[]);

if ~isempty(cetest),  % do analysis
  g=load([getpathname(ds) cetest(end).data filesep 'stims.mat'],'saveScript','MTI2','-mat');
  s=stimscripttimestruct(g.saveScript,g.MTI2);
  
  % now loop through list and do fits

  assoclist = tpcolorexchangeanalysis;

  for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
  end;

  maxresp = []; 
  fdtpref = []; 
  circularvariance = [];
  tuningwidth = [];

  resp = ceresp.data.curve;  % example: find the maximum location
  %%% resp(1,:) is the 'x' variable; if the user selected 'analyzebystimnumber',
  %%% it will be equal to 1..numStims.  You 
  %%% might want to edit resp(1,:) to reflect stimulus parameter rather
  %%% than stimulus number; see how this is done in tpotanalysis

  [maxresp,if0]=max(resp(2,:)); 
  cepref = [resp(1,if0)];  % which stim position is max?

  groupmem = [];
  vals = [];
  for i=1:length(ceresp.data.ind),
	vals = cat(1,vals,ceresp.data.ind{i});
	groupmem = cat(1,groupmem,i*ones(size(ceresp.data.ind{i})));
  end;
  ot_varies_p = anova1(vals,groupmem,'off');
  if isfield(ceresp.data,'blankresp'),
 	vals = cat(1,vals,ceresp.data.blankind);
	groupmem = cat(1,groupmem,(length(ceresp.data.ind)+1)*ones(size(ceresp.data.blankind)));
  	ot_vis_p = anova1(vals,groupmem,'off');
  end;

if 0,  % this is what is done for orientation stims
  circularvariance = compute_circularvariance(tuneangles,tuneresps);
  tuningwidth = compute_tuningwidth(tuneangles,tuneresps);
  orientationindex = compute_orientationindex(tuneangles,tuneresps);
  da = diff(sort(angles)); da = da(1);

  if(1)  % fit with Carandini function
	%[rcurve,n_otpref,n_tuningwidth]=fit_otcurve([tuneangles; tuneresps],otpref,90,maxresp,0);
	% tuning_width is not calculated with spontaneous rate subtracted
	[Rsp,Rp,Ot,sigm,Rn,fitcurve,er] = otfit_carandini(tuneangles,0,maxresp,otpref,90,'widthint',[da/2 180],...
		'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
	[Rsp_,Rp_,Ot_,sigm_,Rn_,OnOff_,fitcurve_,er_]=otfit_carandini2(tuneangles,0,maxresp,otpref,90,...
		'widthint',[da/2 180],'OnOffInt',[130 230],'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
	%[Rsp Rp Ot sigm Rn ],
	%[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_],
	if max(angles)<=180&Ot>180, Ot = Ot-180; end;
						 
	if display&(ot_vis_p<0.05)
	  figure;
	  errorbar(tuneangles,tuneresps,tuneerr,'o'); 
	  hold on
	  plot(0:359,fitcurve,'r');
	  plot(0:359,fitcurve_,'g');
	  xlabel('Direction')
	  ylabel('\Delta F/F');
          title(cellname,'interp','none');
	end % display
  end  % function fitting
  end;  % if 0

  assoc(end+1)=myassoc('CE varies',ot_varies_p<0.05);
  assoc(end+1)=myassoc('CE varies p',ot_varies_p);
  if exist('ot_vis_p')==1,
	  assoc(end+1)=myassoc('CE visual response',ot_vis_p<0.05);
	  assoc(end+1)=myassoc('CE visual response p',ot_vis_p);
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

