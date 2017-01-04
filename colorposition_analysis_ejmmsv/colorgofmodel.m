function [gf] = colorgofmodel(cell,modelnum)

NK = findassociate(cell,'TP CEDE Color NK Fit Params','','');
NKf = findassociate(cell,'TP CEDE Color NK Fit','','');
LIN = findassociate(cell,'TP CEDE Color Fit Params','','');
LINf = findassociate(cell,'TP CEDE Color Fit','','');
RECT = findassociate(cell,'TP CEDE Color D Fit','','');
RC = findassociate(cell,'TP CEDE Response struct','','');
BL = findassociate(cell,'TP CEDE Blank Response','','');
R4 = findassociate(cell,'TP CEDE Color R4 Fit','','');
R4 = findassociate(cell,'TP CEDE Color R4 Fit','','');



if isempty(NK),
	NK = findassociate(cell,'TP CED Color NK Fit Params','','');
	NKf = findassociate(cell,'TP CED Color NK Fit','','');
	LIN = findassociate(cell,'TP CED Color Fit Params','','');
	LINf = findassociate(cell,'TP CED Color Fit','','');
	RC = findassociate(cell,'TP CED Response struct','','');
	RECT = findassociate(cell,'TP CED Color D Fit','','');
	RC.data.curve = RC.data.curve(:,1:13);
	BL = findassociate(cell,'TP CED Blank Response','','');
    R4 = findassociate(cell,'TP CED Color R4 Fit','','');
else,
	RC.data.curve = RC.data.curve(:,1:16);
end;

D = RC.data.curve(2,:);
MD = 0*mean(D);

switch(modelnum),
    case 1, % linear
        fit = LINf.data;
    case 2, % NK
        fit = NKf.data;
    case 4,
        fit = R4.data.fit;
    case 5,
        fit = R4R.data.fit;
end;

gf = 1-sum((fit(2,:)-D).^2)./sum((D-MD).^2);
