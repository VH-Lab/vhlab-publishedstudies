function dirtpbeforeafter(tpf, dirthresh, stackname)

myfig = figure;

labels={'Initial', 'Training'};

property = {'OT Fit Pref','Recovery OT Fit Pref'};
dirproperty = {'OT Direction index','Recovery OT Direction index'};
pthreshold_assoc = {'OT visual response p','Recovery OT visual response p'};

% load cells
ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

myinds = [];
for j=1:length(cells),
    %dirf2 = findassociate(cells{j},'OT Direction index 2 peak','','');
    dirf2 = findassociate(cells{j},'OT Direction index','','');
    %dirf2t = findassociate(cells{j},'Recovery OT Direction index 2 peak','','');
    dirf2t = findassociate(cells{j},'Recovery OT Direction index','',''); 
    vp   = findassociate(cells{j},'OT visual response p','','');
    vpt   = findassociate(cells{j},'Recovery OT visual response p','','');
    OTi  = findassociate(cells{j},'OT Fit Orientation index','','');
    OTit  = findassociate(cells{j},'Recovery OT Fit Orientation index','','');
%     tw = findassociate(cells{j},'OT Tuning width','','');
%     twt = findassociate(cells{j},'Recovery OT Tuning width','','');
    if ~isempty(dirf2)&~isempty(dirf2t)&vp.data<0.05&vpt.data<0.05& OTi.data>0.3 & OTit.data>0.3,
     myinds(end+1) = j; 
    end;
end;
mycells = cells(myinds);
mycellnames = cellnames(myinds);

for i=1:2,
    plototdirstack(mycells,stackname,'otdirgreenblue',1,'otgray',0,'ot_assoc',property{i},...
         'dir_assoc',dirproperty{i},'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{i},'rotate',0,'ds',ds,'cellnames',mycellnames);
    title(labels{i});
end;

