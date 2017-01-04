function [p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct, p_r4vsln, p_r4vsnl, linvsr4, nlvsr4, whichmodel]=isnonlinearcolor(cell)

if 1,
    NK = findassociate(cell,'TP CEDE Color NK Fit Params','','');
    LIN = findassociate(cell,'TP CEDE Color Fit Params','','');
    RCT = findassociate(cell,'TP CEDE Color D Fit','','');
    RC = findassociate(cell,'TP CEDE Response struct','','');
    R4=findassociate(cell,'TP CEDE Color R4 Fit','','');
end;
    
if isempty(NK),
	NK = findassociate(cell,'TP CED Color NK Fit Params','','');
	LIN = findassociate(cell,'TP CED Color Fit Params','','');
	RC = findassociate(cell,'TP CED Response struct','','');
	RCT = findassociate(cell,'TP CED Color D Fit','','');
    R4=findassociate(cell,'TP CED Color R4 Fit','','');
end;

if isempty(NK),
    NK = findassociate(cell,'SP F0 CEDE Color NK Fit Params','','');
    LIN = findassociate(cell,'SP F0 CEDE Color Fit Params','','');
    RCT = findassociate(cell,'SP F0 CEDE Color D Fit','','');
    RC = findassociate(cell,'SP F0 CEDE Response struct','','');
    R4=findassociate(cell,'SP F0 CEDE Color R4 Fit','','');
end;


    % use only mean values
err2 = NK.data(7);
err1 = LIN.data(3);
err3 = RCT.data.err;
err4 = R4.data.err;
err0 = sum(RC.data.curve(2,:)-mean(RC.data.curve(2,:)).^2);
Dpts = length(RC.data.curve(1,:));

p_nlvsln = 1-fcdf( ((err1-err2)/err2)/ ( ((Dpts-2)-(Dpts-6))/(Dpts-6) ), 2, Dpts-6);
p_lnvsmn = 1 - fcdf( ((err0-err1)/err1) / ( ((Dpts-1)-(Dpts-2))/(Dpts-2)), 2, Dpts-2);
p_rctvsln = 1-fcdf( ((err1-err3)/err3)/ ( ((Dpts-2)-(Dpts-3))/(Dpts-3) ), 2, Dpts-3);
p_nlvsrct = 1-fcdf( ((err3-err2)/err2)/ ( ((Dpts-3)-(Dpts-6))/(Dpts-6) ), 2, Dpts-6);
p_r4vsln = 1-fcdf( ((err1-err4)/err4) / ( ((Dpts-2)-(Dpts-4))/(Dpts-4) ), 2, Dpts-4);
p_r4vsnl = 1-fcdf( ((err4-err2)/err2) / ( ((Dpts-4)-(Dpts-6))/(Dpts-6) ), 2, Dpts-6);
linvsr4=err1<err4; nlvsr4=err2<err4;

whichmodel = 1;
if p_r4vsln<.05&p_nlvsln<0.05,
    whichmodel = 4;
    if err2<err4, whichmodel = 2; end;
elseif p_r4vsln<0.05,
    whichmodel = 4;
elseif p_nlvsln<0.05,
    whichmodel = 2;
end;
    
