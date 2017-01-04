function [gf, modelnum] = colorgof(cell)

NK = findassociate(cell,'TP CEDE Color NK Fit Params','','');
NKf = findassociate(cell,'TP CEDE Color NK Fit','','');
LIN = findassociate(cell,'TP CEDE Color Fit Params','','');
LINf = findassociate(cell,'TP CEDE Color Fit','','');
RECT = findassociate(cell,'TP CEDE Color D Fit','','');
RC = findassociate(cell,'TP CEDE Response struct','','');
BL = findassociate(cell,'TP CEDE Blank Response','','');

if isempty(NK),
	NK = findassociate(cell,'TP CED Color NK Fit Params','','');
	NKf = findassociate(cell,'TP CED Color NK Fit','','');
	LIN = findassociate(cell,'TP CED Color Fit Params','','');
	LINf = findassociate(cell,'TP CED Color Fit','','');
	RC = findassociate(cell,'TP CED Response struct','','');
	RECT = findassociate(cell,'TP CED Color D Fit','','');
	RC.data.curve = RC.data.curve(:,1:13);
	BL = findassociate(cell,'TP CED Blank Response','','');
else,
	RC.data.curve = RC.data.curve(:,1:16);
end;

[p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct] = isnonlinearcolor(cell);

D = RC.data.curve(2,:);
MD = 0*mean(D);

 % branching:
 %   first, which cone addition model is best, NK or simple?
 %   then, is the rectification fit better than the additive fit?


if p_nlvsln<0.05, % nonlinear is better than simple linear
	%[gf, vres, vexpl, vnoise] = gof([RC.data.ind{:}],NKf.data(2,:));
	gf = 1-sum((NKf.data(2,:)-D).^2)./sum((D-MD).^2);
	modelnum = 2;
else, % linear is best
	%[gf, vres, vexpl, vnoise] = gof([RC.data.ind{:}],LINf.data(2,:));
	gf = 1-sum((LINf.data(2,:)-D).^2)./sum((D-MD).^2);
	modelnum = 1;
end;

return;
if (modelnum==2&p_nlvsrct>0.95)|(modelnum==1&p_rctvsln<0.05),
	gf = 1-sum((RECT.data.fit(2,:)-D).^2)./sum((D-MD).^2);
	modelnum = 3;
end;
