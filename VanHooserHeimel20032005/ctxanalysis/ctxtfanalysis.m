function [newcell,outstr,assoc,pc]=ctxtfanalysis(cksds,cell,cellname,display)

%  CTXTFANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXTFANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the TF test (associate name in quotes):
%  'TF Response Curve F0'         |   F0 response
%  'TF Pref'                      |   TF w/ max firing
%  'TF Low'                       |   low TF with half of max response 
%  'TF High'                      |   high TF with half of max response 
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF, angle)

newcell = cell;

assoclist = ctxassociatelist('TF Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
	where.figure=figure;
	where.rect=[0 0 1 1];
	where.units='normalized';
	orient(where.figure,'landscape');
else, where = []; end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = []; maxgrating = []; tfpref = []; pc = [];

tftest = findassociate(newcell,'TF Test','protocol_CTX',[]);
if ~isempty(tftest),
  s=getstimscripttimestruct(cksds,tftest(end).data);
  if ~isempty(s),
    inp.paramnames = {'tFrequency'};
    inp.title=['Temporal frequency ' cellname];
    inp.spikes = newcell;
    inp.st = s;
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    [mf0,if0]=max(f0curve(2,:)); 
    [mf1,if1]=max(f1curve(2,:)); 
    maxfiring = [mf0 mf1];
    f1f0=mf1/mf0;
    
    
    [lowf0, maxf0, highf0] = compute_halfwidth(f0curve(1,:),f0curve(2,:));
    [lowf1, maxf1, highf1] = compute_halfwidth(f1curve(1,:),f1curve(2,:));
    
    
    assoc(end+1)=ctxnewassociate('TF Test',...
				 tftest(end).data,...
				 'TF Test');
    assoc(end+1)=ctxnewassociate('TF Response Curve F0',...
			f0curve,'TF Response Curve F1');
    assoc(end+1)=ctxnewassociate('TF Response Curve F1',...
			f1curve,'TF Response Curve F1');
    assoc(end+1)=ctxnewassociate('TF Max drifting grating firing',...
			maxfiring,'Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF Pref',[maxf0 maxf1],...
			'Temporal frequency preference [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF Low',[lowf0 lowf1],...
			'Temporal frequency low half response point [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF High',[highf0 highf1],...
			'Temporal frequency high half response point [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF F1/F0',f1f0,...
			'TF F1/F0');
    

  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f0curve = f0curve; % no longer used
