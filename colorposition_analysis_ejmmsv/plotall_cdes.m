function [output]=plotalltptfs(prefix,expernames,M,N)
  % might use 
  % prefix = '/Volumes/Data2/treeshrew/ZabWoodySteve/';
  % expernames = {'2007-09-19','2013-06-03','2013-06-06'}

[cells,cellnames]=readcellsfromexperimentlist(prefix,expernames,1,5);

pref1 = [];
pref2 = [];
pref3 = [];
high = [];
low = [];

all_splinefits = [];
splinefits_x = [];

all_x = [];
all_raw = [];


fig = figure;
p = 1;

for i=1:length(cells),
	CEDEp = findassociate(cells{i},'TP CEDE visual response p','','');
	CEDEfit = findassociate(cells{i},'TP CEDE D Fit','','');
	CEDEresp = findassociate(cells{i},'TP CEDE Response curve','','');
	if ~isempty(CEDEp),
		if CEDEp.data<0.05,
			figure;
			plottpresponse(cells{i},cellnames{i},'Color Dacey Fit Fig Plot',1,1);
			p = p + 1;
		end;
	end;
end;

output = workspace2struct;
