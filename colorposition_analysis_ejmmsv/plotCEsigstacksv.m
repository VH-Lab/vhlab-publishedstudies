function im = plotCEsigstacksv(ds_or_cells,stackname,varargin)

% PLOTCESIGSTACK - Plot a stack of sig color-exchange responsive cells and
% indicates whether S- or L-cone.
%
%  IM=PLOTCESIGSTACK(MYDIRSTRUCT_OR_CELLLIST, STACKNAME, ...)
%
%  MYDIRSTRUCT_OR_CELLLIST can be either the directory structure
%  where the experiment files are stored.
%  Alternatively,
%  STACKNAME is the name of the stack as described in ANALYZETPSTACK.
%  Might be 'Site 1' or 'Test' or some such name.  If STACKNAME is
%  empty, the user is prompted for the proper name or, if only one
%  stack is present, that stack is used.
%
%  IM is a Matlab image handle.  It is plotted in the current
%  axes.
%
%  Extra arguments can be given in pairs (e.g., 'pthreshold', 1):
%
%  PTHRESHOLD               P threshold for including cells.
%                           Default is 0.05.  If more than one
%                           index is provided, then this can be
%                           an array or the same value will be used.
%  PTHRESHOLD_ASSOC         Associate that holds the P value
%                           (default 'OT visual response p')
%  COLORSCALE       0/1     Include color scale? Default 1 (yes).
%  TRANSPARENCY     0..1    Transparency of symbols drawn in plot
%  ROTATE         (0 or 90) Angle to rotate the image.  Default 0.
%  IMAGESIZE    [X Y]       Size of image to be generated.
%                           Default is [512 512].
%  SUPRESSPLOT   0/1        If 1, plotting of IM is supressed.
%                           Default 0.
%  DIRTHRESH     (value)    Threshold for direction selective cell.
%  DIR_ASSOC    string      'OT Fit Direction index' (default),
%                           'OT Direction index', or
%                           'OT Direction index 2 Peak'
%  OT_ASSOC    string       'OT Pref', 'OT Fit Pref', or
%                           'OT Fit Pref 2 Peak'
%  OTGRAY         0/1       Should OT cells be gray?  Default 1.
%  OTDIRGREENBLUE 0/1       Should OT cells be green and dir cells blue? Default 0.

pthreshold=0.05;rotate=0;imagesize=[512 512];Scone_assoc='TP sig S cone';
ot_assoc = 'TP sig S cone'; pthreshold_assoc = 'TP CE visual response p';
supressplot=0; transparency = 0; sigCE_assoc = 'TP CE visual response p';



if isa(ds_or_cells,'dirstruct'),
    ds = ds_or_cells;
    [cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
    %[cells2,cellnames2]=load2celllist(getexperimentfile(ds),'cell_tp_002*','-mat');
    %[cells3,cellnames3]=load2celllist(getexperimentfile(ds),'cell_tp_005*','-mat');
    %cells = cat(1,cells',cells2',cells3'); cellnames = cat(2,cellnames',cellnames2',cellnames3');
else, cells = ds_or_cells; for i=1:length(cells), cellnames{i} = ''; end;
end;

if nargin>3, assign(varargin{:}); end;

if isempty(stackname),
    possiblestacks = findallstacks(cells);
    if length(possiblestacks)>1,
        disp(['Following stack names are possible: ' possiblestacks '.']);
        done = 0;
        r = input('Which stack?','s');
        for j=1:length(possiblestacks),
            if strcmp(r,possiblestacks{j}),
                stackname=possiblestacks{j};
                break;
            end;
        end;
        if isempty(stackname), error(['No stackname selected.']); end;
    elseif length(possiblestacks)==1, stackname = possiblestacks{1};
    elseif length(possiblestacks)==0, error(['No stacks found.']);
    end;
end;

mycells = [];

for i=1:length(cells),
    stackassoc = findassociate(cells{i},'analyzetpstack name','','');
    %pthresholda=findassociate(cells{i},pthreshold_assoc,'','');
    sigCE=findassociate(cells{i},sigCE_assoc,'','');
    Scone=findassociate(cells{i},Scone_assoc,'','');
    if ~isempty(stackassoc)&~isempty(sigCE),
        if strcmp(stackassoc.data,stackname)&sigCE.data<0.05,
            mycells(end+1) = i;
        end;
    end;
end;

cells=cells(mycells);

symb = []; cols = []; symsize = [];
for i=1:length(cells),
    Scone=findassociate(cells{i},Scone_assoc,'','');
    %Achot=findassociate(cells{i},ot_assoc,'','');
    %pthresholda=findassociate(cells{i},pthreshold_assoc,'','');
    sigCE=findassociate(cells{i},sigCE_assoc,'','');
        if Scone.data==1,
        symb(i) = 1;
        symsize(i,[1 2]) = [12 12];
        cols(i,:)=[0 0 1];
        else
            symb(i) = 1;
            symsize(i,[1 2]) = [12 12];
            cols(i,:)=[0 1 0];
        end
   


end;

%g = gca;
if exist('ds')==1,
    [im,scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,'mod(x,180)',0:179,~supressplot,'pvalueassoc',pthreshold_assoc,'pvalue',1,'symbol',symb,'symbolsize',symsize,'colors',cols,...
        'rotate',rotate,'ds',ds,'transparency',transparency);
else,
    [im,scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,'mod(x,180)',0:179,~supressplot,'pvalueassoc',pthreshold_assoc,'pvalue',1,'symbol',symb,'symbolsize',symsize,'colors',cols,...
        'rotate',rotate,'transparency',transparency);
end;
axis square;
delete(scalebarax);
