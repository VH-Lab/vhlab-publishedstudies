function [p_nlvsln]=isnonlinearcolor2(cell)

R4NK = findassociate(cell,'TP CEDE Color R4NK Fit','','');
R4 = findassociate(cell,'TP CEDE Color R4 Fit','','');
RC = findassociate(cell,'TP CEDE Response struct','','');

if isempty(R4NK),
	R4NK = findassociate(cell,'TP CED Color R4NK Fit','','');
	R4 = findassociate(cell,'TP CED Color Fit R4','','');
	RC = findassociate(cell,'TP CED Response struct','','');
end;

R4NK = R4NK.data,
R4 = R4.data;

% use only mean values
err2 = R4NK.err+R4NK.se.^2+R4NK.si^2+R4NK.le^2+R4NK.li^2;
err1 = R4.err+R4.se.^2+R4.si^2+R4.le^2+R4.li^2;
Dpts = length(RC.data.curve(1,:));

p_nlvsln = 1-fcdf( ((err1-err2)/err2)/ ( ((Dpts-4)-(Dpts-8))/(Dpts-8) ), 2, Dpts-8);
