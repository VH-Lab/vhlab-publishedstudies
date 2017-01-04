function cv = cvdirection(cell,before)

dir_assoc='TP Ach OT Response curve';

if before==0,
	dir_assoc='TP ME Ach OT Response curve';
end;

if before==2,
	dir_assoc='TP FE Ach OT Response curve';
end;

f=findassociate(cell,dir_assoc,'','');
if isempty(f), cv = []; return; end;

[mx,i] = max(f.data(2,:));
cv = f.data(3,i); %/f.data(2,i);
cv = f.data(2,i); %/f.data(2,i);
