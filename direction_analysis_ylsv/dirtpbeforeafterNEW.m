function dirtpbeforeafterpair(tpf, dirthresh, stackname, traindir)

%myfig = figure;

labels={'Initial', 'Training'};

property = {'TP Ach OT Fit Pref','TP ME Ach OT Fit Pref'};
dirproperty = {'TP Ach OT Fit Direction index blr','TP ME Ach OT Fit Direction index blr'};
pthreshold_assoc={'TP Ach OT vec varies p','TP ME Ach OT vec varies p'};

prefproperty1 = {'TP Ach OT Fit Pref'};
prefproperty2 = {'TP ME Ach OT Fit Pref'};
dirproperty1 = {'TP Ach OT Fit Direction index blr'};
dirproperty2 = {'TP ME Ach OT Fit Direction index blr'};
pthreshold_assoc={'TP Ach OT vec varies p','TP ME Ach OT vec varies p'};

% load cells
ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

%keyboard;

myinds = [];
for j=1:length(cells),
    dirf2 = findassociate(cells{j},'TP Ach OT Fit Direction index blr','','');
    %dirf2t = findassociate(cells{j},'TP ME Ach OT Fit Direction index blr','',''); 
    vp   = findassociate(cells{j},'TP Ach OT vec varies p','',''); 
    %vpt   = findassociate(cells{j},'TP ME Ach OT vec varies p','','');
        
    if ~isempty(dirf2)& vp.data<0.05,
        myinds(end+1) = j; 
    end;
end;

mycells = cells(myinds);
mycellnames = cellnames(myinds);

plototdirstackNEW2(mycells,stackname,'dirgreenbluechange',0,'dirgreenblue',1,'otdirgreenblue',0,'otgray',0,...
        'ot_assoc',property{1},'dir_assoc',dirproperty{1},...
        'ot_assoc1',prefproperty1{1},'ot_assoc2',prefproperty2{1},'dir_assoc1',dirproperty1{1},'dir_assoc2',dirproperty2{1},...
        'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{1},...
        'rotate',0,'traindir',traindir,'ds',ds,'cellnames',mycellnames);
title(labels{1});

myinds = [];
for j=1:length(cells),
    dirf2t = findassociate(cells{j},'TP ME Ach OT Fit Direction index blr','',''); 
    vpt   = findassociate(cells{j},'TP ME Ach OT vec varies p','','');
        
    if ~isempty(dirf2t)& vpt.data<0.05,
        myinds(end+1) = j; 
    end;
end;
mycells = cells(myinds);
mycellnames = cellnames(myinds);

plototdirstackNEW2(mycells,stackname,'dirgreenbluechange',0,'dirgreenblue',1,'otdirgreenblue',0,'otgray',0,...
        'ot_assoc',property{2},'dir_assoc',dirproperty{2},...
        'ot_assoc1',prefproperty1{1},'ot_assoc2',prefproperty2{1},'dir_assoc1',dirproperty1{1},'dir_assoc2',dirproperty2{1},...
        'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{2},...
        'rotate',0,'traindir',traindir,'ds',ds,'cellnames',mycellnames);
title(labels{2});

% figure;
% [Xn,Yn]=tpscatterplot(mycells,mycellnames,'TP Ach OT Fit Direction index blr','x',...
%         'TP ME Ach OT Fit Direction index blr','y',2,...
% 		'markersize',6,'colors',[0 0 0],'marker','o','clickfunction','plottpresponseclick','property','Recovery OT Fit Pref');
% axis([0 1 0 1]);
% hold on
% plot([0 1],[0 1],'k--');
% ylabel('Dir index after(\circ)'); 
% xlabel('Dir index before(\circ)');
%axis equal;

%dirtraintpexpsummary(cells,cellnames);
