function im=dirtpplotsingledepth(tpf, dirthresh, stackname,depth,image)

%myfig = figure;

property = {'TP Ach OT Fit Pref'};
dirproperty = {'TP Ach OT Fit Direction index blr'};
pthreshold_assoc = {'TP Ach OT vec varies p'};

% load cells
ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

myinds = [];
for j=1:length(cells),
    vp   = findassociate(cells{j},'TP Ach OT vec varies p','','');
    xyz = tpgetcellposition(cells{j}),
    if ~isempty(vp)&&~isempty(xyz)&&vp.data<0.05&&xyz(3)==depth,
         myinds(end+1) = j; 
    end;
end;
mycells = cells(myinds);
mycellnames = cellnames(myinds);

for i=1:1,
    im=plototdirstack(mycells,stackname,'otdirgreenblue',1,'otgray',0,'ot_assoc',property{i},...
         'dir_assoc',dirproperty{i},'dirthresh',dirthresh,...
         'pthreshold_assoc',pthreshold_assoc{i},'rotate',0,'ds',ds,'cellnames',mycellnames,'imagesize',image,...
            'usepolar',1,'subtractblank',0);
end;

