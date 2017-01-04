function im = plototdirstack(ds_or_cells,stackname,varargin)

% PLOTOTDIRSTACK - Plot a stack of OT and DIR selective cells
%
%  IM=PLOTOTDIRSTACK(MYDIRSTRUCT_OR_CELLLIST, STACKNAME, ...)
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
%  DIRTHRESH     (value)    Threshold for direction selective cell. Inf for
%                              divided lines.
%  DIR_ASSOC    string      'OT Fit Direction index' (default),
%                           'OT Direction index', or 
%                           'OT Direction index 2 Peak'
%  OT_ASSOC    string       'OT Pref', 'OT Fit Pref', or
%                           'OT Fit Pref 2 Peak'
%  OTGRAY         0/1       Should OT cells be gray?  Default 1.
%  OTDIRGREENBLUE 0/1       Should OT cells be green and dir cells blue? Default 0.

pthreshold=0.05;colorscale=1;rotate=0;imagesize=[512 512];dirthresh=0.5;dir_assoc='OT Fit Direction index';
ot_assoc = 'OT Fit Pref'; pthreshold_assoc = 'OT visual response p'; otdirgreenblue = 0;
supressplot=0;otgray = 1; transparency = 0;


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
	if ~isempty(stackassoc),
		if strcmp(stackassoc.data,stackname),
			mycells(end+1) = i;
		end;
	end;
end;

cells=cells(mycells);

symb = []; cols = []; symsize = [];
for i=1:length(cells),
        dias=findassociate(cells{i},dir_assoc,'','');
        if ~isempty(dias),
            symb(i) = 1 + 5*(dias.data>dirthresh);
            symsize(i,[1 2]) = [12 dias.data*12];
            if otgray,
            	if dias.data<dirthresh, cols(i,:)=[0.7 0.7 0.7];
            	else, cols(i,:) = [-1 -1 -1];
            	end;
            elseif otdirgreenblue,
            	if dias.data>dirthresh, cols(i,:) = [ 0 0 1];
            	else, cols(i,:) = [ 0 1 0];
            	end;
            	symb(i) = 3*(dias.data>=dirthresh)+7*(dias.data<dirthresh);
                symsize(i,[1 2]) = [12 12];
            elseif ordirbarandarrow,
                cols(i,:) = [ 0 0 1 ];
                mymap = jet(101);
                cols(i,:) = mymap(1+round(100*dias.data),:);
                symb(i) = 7;
                symsize(i,[1 2]) = 12;
                if dias.data>-0.33,
                    %cols(i,:) = mymap(1+round(100*dias.data),:);
                    %cols(i,:) = [0 0 1]*(1-dias.data)+[ 1 0 0  ]*(dias.data);
                    %cols(i,:) = [ 0 1 0 ];
                    symb(i) = 3;
                    symsize(i,[1 2]) = [12 dias.data];
                    %symsize(i,[1 2]) = 1.5*[(12-3*(dias.data>.33)-9*(dias.data>.66))/1.5 9*(dias.data>0.33)+6*(dias.data>0.66)];                    
                    %symsize(i,[1 2]) = 1.5*[(12-0*(dias.data>.2)-3*(dias.data>.4)-3*(dias.data>.6)-3*(dias.data>0.8))/1.5 6*(dias.data>0.2)+3*(dias.data>0.4)+3*(dias.data>0.6)+3*(dias.data>0.8)];
                end;
            elseif (dias.data>dirthresh), cols(i,:) = [-1 -1 -1];
            elseif dirthresh==Inf,
                symb(i) = 10;
            else, cols(i,:) = [ 0.7 0.7 0.7];
            end;
        else, symb(i) = 0; cols(i,:) = [ -1 -1 -1]; symsize(i,[1 2]) = [12 0];
        end;
end;
%g = gca;
if exist('ds')==1, varargin = cat(2,varargin,{'ds',ds}); end;

if dirthresh==Inf,
    mathstr = ['getfield(findassociate(cells{i},''' dir_assoc ''','''',''''),''data'')*exp(sqrt(-1)*(x-45)*pi/180)'];
else, mathstr = 'mod(x-45,360)';
end;

[im,scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,mathstr,0:179,~supressplot,'pvalueassoc',pthreshold_assoc,'pvalue',pthreshold,'symbol',symb,'symbolsize',symsize,'colors',cols,...
	'rotate',rotate,'transparency',transparency,varargin{:});

if ~colorscale, delete(scalebarax); end;
