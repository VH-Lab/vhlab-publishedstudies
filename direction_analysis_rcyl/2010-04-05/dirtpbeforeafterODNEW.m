function dirtpbeforeafterODNEW(tpf, dirthresh, stackname, traindir, shift)

%  DIRTPBEFOREAFTERODNEW - Generate ARROW/BAR images (before and after) of
%  ocular transfer experiment
%  
%  tpf, the file path of the twophoton file (e.g., 'E:\2photon\ferretdirection\oculartransfer\2010-01-07') 
%
%  dirthresh, if 0, then all the cells ploted as arrow, size indicated DSI,
%  if not 0, then bar/arrow dependent upon the value 
%  
%  stackname, (e.g., 'Site 1')
%  
%  traindir, train angle,(e.g., 22.5), feature to add: bidir or uni
%  
%  shift, angle of head to shift, default is 0

%slice: all or slicename (001,002,003,004 etc)
%myfig = figure;

labels={'Before Ipsi-eye', 'Before Contral-eye','After Ipsi-eye', 'After Contral-eye'};

property = {'TP IPSI Ach OT Fit Pref','TP CONT Ach OT Fit Pref',...
    'TP IPSI ME Ach OT Fit Pref','TP CONT ME Ach OT Fit Pref',};
dirproperty = {'TP IPSI Ach OT Fit Direction index blr','TP CONT Ach OT Fit Direction index blr',...
    'TP IPSI ME Ach OT Fit Direction index blr','TP CONT ME Ach OT Fit Direction index blr'};
pthreshold_assoc={'TP IPSI Ach OT vec varies p','TP CONT Ach OT vec varies p',...
    'TP IPSI ME Ach OT vec varies p','TP CONT ME Ach OT vec varies p'};
pthreshold_assoc2={'TP IPSI Ach OT visual response p','TP CONT Ach OT visual response p',...
    'TP IPSI ME Ach OT visual response p','TP CONT ME Ach OT visual response p'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Before training
% load cells
ds = dirstruct(tpf);
%if just for one depth,
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
%if include all depths,
%[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

%keyboard;

%cuthere
%figure;
for m = 1 : length(property),
    figure;
    %subplot(2,2,m)
    myinds = [];
    for j=1:length(cells),
        dirf2 = findassociate(cells{j},dirproperty{m},'','');
        %dirf2t = findassociate(cells{j},'TP FE Ach OT Fit Direction index blr','',''); 
        vp   = findassociate(cells{j},pthreshold_assoc{m},'',''); 
        rp   = findassociate(cells{j},pthreshold_assoc2{m},'',''); 
        %vpt   = findassociate(cells{j},'TP FE Ach OT vec varies p','','');
        
        %the threshold for selecting cells, (e.g., p value of 'OT visual response p' or 'OT vec varies p')
        if ~isempty(dirf2)& ~isnan(dirf2.data)& ~isempty(vp) & vp.data<.05 & rp.data<.05
            myinds(end+1) = j; 
        end;
    end; 

    mycells = cells(myinds);
    mycellnames = cellnames(myinds); 
    
    if dirthresh == 0, I = 1; J = 0; else I = 0; J = 1; end;
    %keyboard; 
    %otdirgreenblue for green and red bar arrow; 
    %dirgreenblue for arrow and size of the direction bias
    
    plototdirstackODNEW2(mycells,stackname,'dirgreenbluechange',0,'dirgreenblue',I,'otdirgreenblue',J,'otgray',0,...
            'ot_assoc',property{m},'dir_assoc',dirproperty{m},...
            'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{m},...
            'rotate',0,'traindir',traindir,'shift',shift,'ds',ds,'cellnames',mycellnames,'pair',0);
    title(labels{m});axis square
    % cuthere
end;