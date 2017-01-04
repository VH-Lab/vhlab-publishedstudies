function recoverferretassocs(tpf)

ds = dirstruct(tpf);
[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

f(1)=findassociate(cells{1},'Age','','');
f(2)=findassociate(cells{1},'Ferret number','','');
f(3)=findassociate(cells{1},'Dark reared','','');
f(4)=findassociate(cells{1},'Eyes open','','');
g = findassociate(cells{1},'Training direction','','');
if ~isempty(g), f(end+1) = g; end;

tpassociatelistglobals;

for j=1:length(f),
	gotmatch = 0;
	for i=1:length(tpassociatelist),
		if strcmp(tpassociatelist(i).type,f(j).type),
			gotmatch=1;
			tpassociatelist(i) = f(j);
			break;
		end;
	end;
	if ~gotmatch, tpassociatelist(end+1) = f(j); end;
end;
