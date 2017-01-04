function dirtpsingle(tpf, dirthresh, stackname)
% filename='W:\2photon\ferretdirection\2006-12-20\analysis\experiment_all'; 
%myfig = figure;

labels={''};

property = {'OT Fit Pref'};
dirproperty = {'OT Direction index'};
%pthreshold_assoc = {'OT visual response p'};
pthreshold_assoc = {'OT vec varies p'};

% load cells
ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

myinds = [];
for j=1:length(cells),
    %dirf2 = findassociate(cells{j},'OT Direction index 2 peak','','');
    dirf2 = findassociate(cells{j},'OT Direction index','','');
    %dirf2t = findassociate(cells{j},'Recovery OT Direction index 2 peak','','');
%     dirf2t = findassociate(cells{j},'Recovery OT Direction index','',''); 
    vvp = findassociate (cells{j},'OT vec varies p','','');
    %vp   = findassociate(cells{j},'OT visual response p','','');
    %vpt   = findassociate(cells{j},'Recovery OT visual response p','','');
    tw = findassociate(cells{j},'OT Tuning width','','');
    %twt = findassociate(cells{j},'Recovery OT Tuning width','','');
    OTr = findassociate(cells{j},'OT Response curve','','');
    if ~isempty(vvp)& vvp.data<0.05,% & max(OTr.data(2,:))>0.05,
     myinds(end+1) = j; 
    end;
end;
mycells = cells(myinds);
mycellnames = cellnames(myinds);

for i=1:1,
    plototdirstack(mycells,stackname,'otdirgreenblue',1,'otgray',0,'ot_assoc',property{i},...
         'dir_assoc',dirproperty{i},'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{i},'rotate',0,'ds',ds,'cellnames',mycellnames);
    title('');
end;