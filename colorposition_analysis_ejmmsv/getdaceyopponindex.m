function [OpNo] = getdaceyopponindex(cell,model)

% GETDACEYOPPONINDEX - Get opponency index from Dacey Expanded fits
%
%  [OpNo] = GETDACEYOPPONINDEX(CELL,MODEL)
%
%     CELL is a two-photon cell, MODEL is one of
%        'linear'
%        'NK'
%
%  Will first try to get a Dacey Expanded version, falling back to regular Dacey


L = []; S = [];

model = upper(model);

a1=findassociate(cell,'TP CEDE Response curve','','');
bl=findassociate(cell,'TP CEDE Blank Response','','');

if isempty(a1),
	a1=findassociate(cell,'TP CEDE Response curve','','');
	bl=findassociate(cell,'TP CEDE Blank Response','','');
	useCEDE = 0;
else, useCEDE = 1;
end;

resp = a1.data(2,1:12) - bl.data(1);

if useCEDE,
	[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(4);
	Lc = Lc(1:12); Sc = Sc(1:12); Rc = Rc(1:12);
else,
	[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(3);
	Lc = Lc(1:12); Sc = Sc(1:12); Rc = Rc(1:12);
end;	

switch(model),
	case 'linear',
		if useCEDE, cefitparams=findassociate(cell,'TP CEDE Color Fit Params','','');
		else, cefitparams = findassociate(cell,'TP CED Color Fit Params','','');
		end;
	case 'NK',
		cefitparamsnk=findassociate(cell,'TP CEDE Color NK Fit Params','','');
		if ~useCEDE, cefitparamsnk=findassociate(cell,'TP CED Color NK Fit Params','',''); end;
		Lc = naka_rushton_func(Lc,cefitparamsnk.data(3),cefitparamsnk.data(5));
		Sc = naka_rushton_func(Sc,cefitparamsnk.data(4),cefitparamsnk.data(6));
end;

resp = resp./max(resp);

Op = (Sc-Lc)'; No = abs(Sc+Lc)';
Op = Op./max(Op); No=No./max(No);
Opmn = mean([Op No]')';
Op_ = (Op-Opmn); No_ = (No-Opmn);
Op_ = Op_./(Op_'*Op_); No_ = No_./(No_'*No_);

OpNo = (resp-Opmn') * Op_;

figure;

plot(Op); hold on; plot(No,'g');
