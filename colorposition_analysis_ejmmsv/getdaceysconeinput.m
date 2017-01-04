function [L,S,R] = getdaceysconeinput(cell,model)

% GETDACEYSCONEINPUT - Get S cone input from Dacey Expanded fits
%
%  [L,S] = GETDACEYSCONEINPUT(CELL,MODEL)
%
%     CELL is a two-photon cell, MODEL is one of
%        'linear'
%        'NK'
%
%  Will first try to get a Dacey Expanded version, falling back to regular Dacey


L = []; S = []; R =[];

model = upper(model);

switch(model),
	case 'LINEAR',
		cefitparams=findassociate(cell,'TP CEDE Color Fit Params','','');
		if isempty(cefitparams), cefitparams = findassociate(cell,'TP CED Color Fit Params','',''); end;
		L = cefitparams.data(1); S = cefitparams.data(2);
	case 'NK',
		cefitparamsnk=findassociate(cell,'TP CEDE Color NK Fit Params','','');
        if isempty(cefitparamsnk), cefitparamsnk=findassociate(cell,'TP CED Color NK Fit Params','',''); end;
		L = cefitparamsnk.data(1)*naka_rushton_func(0.5,cefitparamsnk.data(3),cefitparamsnk.data(5));
		S = cefitparamsnk.data(2)*naka_rushton_func(0.5,cefitparamsnk.data(4),cefitparamsnk.data(6));
    case 'R4',
        cefitparams=findassociate(cell,'TP CEDE Color R4 Fit','','');
        if isempty(cefitparams), cefitparams = findassociate(cell,'TP CED Color R4 Fit','',''); end;
        L = [cefitparams.data.le cefitparams.data.li]; S = [cefitparams.data.se cefitparams.data.si];
    case 'R4R',
        cefitparams=findassociate(cell,'TP CEDE Color R4R Fit','','');
        if isempty(cefitparams), cefitparams = findassociate(cell,'TP CED Color R4R Fit','',''); end;
        L = [cefitparams.data.le cefitparams.data.li]; S = [cefitparams.data.se cefitparams.data.si];
        R = [cefitparams.data.re cefitparams.data.ri];
end;