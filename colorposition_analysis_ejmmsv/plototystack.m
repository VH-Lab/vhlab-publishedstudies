function im = plototdirstack(ds_or_cells,stackname,varargin)

% PLOTOTDIRSTACK - Plot a stack of OT and another variable 
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
%  Extra arguments can be given in pairs (e.g., 'pthreshold', 0.05):
%
%  PTHRESHOLD               P threshold for including cells.
%                           Default is 0.05.  If more than one
%                           index is provided, then this can be
%                           an array or the same value will be used.
%  PTHRESHOLD_ASSOC         Associate that holds the P value
%                           (default 'OT visual response p')
%  COLORSCALE       0/1     Include color scale? Default 1 (yes).
%  ROTATE         (0 or 90) Angle to rotate the image.  Default 0.
%  IMAGESIZE    [X Y]       Size of image to be generated.
%                           Default is [512 512].
%  SUPRESSPLOT   0/1        If 1, plotting of IM is supressed.
%                           Default 0.
%  Y_ASSOC      string      String that says what associate to read, e.g.
%                           'OT Fit Direction index' (default),
%                           'OT Direction index', or 
%                           'OT Direction index 2 Peak'
%  OT_ASSOC    string       'OT Pref', 'OT Fit Pref', or
%                           'OT Fit Pref 2 Peak'
%  YVALUES       (vector)   YVALUES (e.g., if orientation, 0:179, default)
%  YFUNC          string    YFUNC (e.g., 'mod(x,180), default)
%  SCALEBARTICKS vector     Scalebar indices to label

pthreshold=0.05;colorscale=1;rotate=0;imagesize=[512 512];y_assoc='OT Fit Direction index';
ot_assoc = 'OT Fit Pref 2 Peak'; pthreshold_assoc = 'OT visual response p';
supressplot=0;otgray = 1;
yvalues = 0:179;
yfunc='mod(x,180)';
scalebarticks = 1:10:length(yvalues);


if nargin>3, assign(varargin{:}); end;

if isa(ds_or_cells,'dirstruct'),
	ds = ds_or_cells;
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
else, cells = ds_or_cells; for i=1:length(cells), cellnames{i} = ''; end;
end;

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
	yassoc = findassociate(cells{i},y_assoc,'','');
	otassoc = findassociate(cells{i},ot_assoc,'','');
	if ~isempty(stackassoc)&~isempty(yassoc)&~isempty(otassoc),
		if strcmp(stackassoc.data,stackname),
			mycells(end+1) = i;
		end;
	end;
end;

cells=cells(mycells);

symb = []; cols = []; symsize = [];
for i=1:length(cells),
	symb(i) = 8; %an elongated bar using unmodified OT data
	cols(i,:) = [-1 -1 -1]; % use index value to choose color
	symsize(i,[1 2]) = [16 16];
end;
%g = gca;
ctab = jet(length(yvalues)); ctab = ctab(end:-1:1,:);

[im,scalebarax,scalebarimg]=pvcontinuousmap2(imagesize,1,cells,cellnames(mycells),...
	ot_assoc,yfunc,yvalues,~supressplot,...
	'pvalueassoc',pthreshold_assoc,...
	'pthreshold',pthreshold,'symbol',symb,'symbolsize',symsize,...
	'color',cols,'rotate',rotate,'ctab',ctab,'scalebarticks',scalebarticks);

if ~colorscale, delete(scalebarax); end;
