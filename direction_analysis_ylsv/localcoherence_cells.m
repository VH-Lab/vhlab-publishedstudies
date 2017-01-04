function [lci,n,inds] = localcoherence_cells(celllist, theangle, dirorori, dists, annuli, varargin)

% LOCALCOHERENCE_CELLS Compute local coherence index for 2-photon data
%
%  [LCI,N,INDS]=LOCALCOHERENCE_CELLS(CELLLIST, ANGLE, DIRORORI, DISTS, ANNULI, ...
%                  [PARAMETERNAME1, VALUE1, PARAMETERNAME2, VALUE2,...])
%
%  This function calculates the local coherence index from Li/Van Hooser
%  et al., Nature 2008.
%
%  LCI is calculated for each cell in the imaging field. It is
%  defined to be the percentage of NEIGHBORING cells of the
%  reference cell that are similar to the angle ANGLE minus
%  the percentage of NEIGHBORING cells whose tuning is opposite to
%  the angle ANGLE.
%
%  About the INPUTS:  
%
%  CELLLIST:  List of cells in an imaging field for which to
%     calculate the LCI.
%
%  PARAMETERS THAT DEFINE THE ANGLE SIMILARITY 
%
%  ANGLE:  The angle to which the local coherence is calculated.
%  If ANGLE is NaN, then the local coherence will be calculated
%  with respect to the reference cell's own tuning property. If
%  ANGLE is given as a value, then local coherence will be
%  calculated for each cell with respect to that particular angle.
%  If ANGLE is -Inf, then the local coherence will be computed 
%  with respect to the cell's initial preferences, as defined
%  by the PARAMTERNAME/VALUE pair:
%   INITIAL_DIRECTION_TUNING_FIT_PARAMS
%    (default: 'TP Ach OT Bootstrap Carandini Fit Params')
%
%  DIRORORI: Use 1 to indicate that direction preferences should
%  be used, or 0 if orientation preferences should be used. 
%
%  PARAMETERS THAT DEFINE THE NEIGHBORHOODS: 
%
%  DISTS:  A vector list of radial distances around the cell to
%  include (in image pixels).
%
%  ANNULI: 0/1 Use 0 if the distances above are meant to define
%  inclusive radii around the reference cell. Use 1 if you wish
%  to calculate neighborhood as annuli, where neighborhood 1 includes
%  cells closer than DISTS(1), neighborhood 2 includes cells 
%  farther than DISTS(1) but closer than DISTS(2), etc.
%
%  About the OUTPUTS: %
%
%  LCI is the local coherence calculated for each cell and each
%  neighborhood.  It has size NUM_OF_CELLS x NUM_OF_NEIGHBORHOODS.
%  That is, LCI(I,J) is the LCI of cell I within neighborhood J.
%
%  N is the number of cells in each neighborhood for each cell.
%  It is an NUM_OF_CELLS x NUM_OF_NEIGHBORHOODS matrix.
%
%  INDS is a cell list of size NUM_OF_CELLS x NUM_OF_NEIGHBORHOODS.
%  For each cell and each neighborhood, it returns the index values
%  in CELLLIST that correspond to the neighbors that were used in
%  the LCI calculation.
%
%  OPTIONAL INPUT ARGUMENTS: (given in PARAMETERNAME, VALUE pairs)
%
%  PIXELLOCATION_ASSOC: The associate that contains the pixel locations
%  of the cell.  Default is 'pixellocs'.
%
%  DIRECTION_TUNING_FIT_PARAMS: The associate that contains the
%  direction tuning curve fit parameters for each cell.  Default
%  is 'TP Ach OT Bootstrap Carandini Fit Params' (might want to use
%  'TP ME Ach OT Bootstrap Carandini Fit Params' for motion-exposure
%  condition).
%
%  LCI_STAT: The LCI is calculated for all bootstrap simulations (typically
%  at least 100).  This is the statistic that is pulled out from these simulations.
%  If it is a number, then that percentile is pulled out.  If it is the string
%  'mean', then the mean is used, if it is the string 'median' then the median is
%  used.
%
%  RANDOMIZE_POSTION: If 1, then positions will be scrambled randomly.
%
%  NORMALIZE_BY_NUMBER_OF_CELLS: Normally 1; if it is 1, then the
%  LCI will be the fraction of cells in a given neighborhood; otherwise, it will
%  be the raw number of cells.


 % defaults
PIXELLOCATION_ASSOC = 'pixellocs';

NORMALIZE_BY_NUMBER_OF_CELLS = 1;

DIRECTION_TUNING_FIT_PARAMS = 'TP Ach OT Bootstrap Carandini Fit Params';
INITIAL_DIRECTION_TUNING_FIT_PARAMS = 'TP Ach OT Bootstrap Carandini Fit Params';

LCI_STAT = 50; % 50% percentile (that is, the median)

RANDOMIZE_POSITION = 0;

lci = zeros(length(celllist), length(dists));
n = zeros(length(celllist), length(dists));
inds = cell(length(celllist), length(dists));

 % assign any caller-specified parameters
assign(varargin{:});

 % first get the position and tuning curves for all cells

pos_xy = [];
dir_pref = [];
initial_dir_pref = [];

for i=1:length(celllist),
	pixelassoc = findassociate(celllist{i},PIXELLOCATION_ASSOC,'','');
	if isempty(pixelassoc),
		error(['Could not find associate ' PIXELLOCATION_ASSOC ' for cell number ' int2str(i) '.']);
	end;
	pos_xy(i,[1 2]) = [mean(pixelassoc.data.x) mean(pixelassoc.data.y)]';

	dirtuning = findassociate(celllist{i},DIRECTION_TUNING_FIT_PARAMS,'','');
	dir_pref(:,i) = dirtuning.data(:,3);

	initial_dirtuning = findassociate(celllist{i},INITIAL_DIRECTION_TUNING_FIT_PARAMS,'','');
	if isempty(initial_dirtuning),
		initial_dir_pref(:,i) = NaN*ones(size(dirtuning.data(:,3))); 
	else,
		initial_dir_pref(:,i) = initial_dirtuning.data(:,3);
	end;
end;

if RANDOMIZE_POSITION, pos_xy = pos_xy(randperm(length(celllist)),:); end;

angleparam = theangle;

if isinf(theangle),
	reference_dir_pref = initial_dir_pref;
	angleparam = NaN;
else,
	reference_dir_pref = dir_pref;
end;


for i=1:length(celllist),
	othercellinds = [1:i-1 i+1:length(celllist)];
	[lcii,ni,indsi] = localcoherence(angleparam, dirorori, reference_dir_pref(:,i), pos_xy(i,:), dir_pref(:,othercellinds), pos_xy(othercellinds,:), dists, annuli, NORMALIZE_BY_NUMBER_OF_CELLS);
	for j=1:length(dists),
		inds{i,j} = indsi{j};
		n(i,j) = ni(j);
		if isnumeric(LCI_STAT)
			lci(i,j) = prctile(lcii(j,:),LCI_STAT);
		elseif strcmp(LCI_STAT,'median'),
			lci(i,j) = nanmedian(lcii(j,:));
		elseif strcmp(LCI_STAT,'mean'),
			lci(i,j) = nanmean(lcii(j,:));
		elseif ischar(LCI_STAT),
			try,
				lci(i,j) = eval([LCI_STAT]);
			catch,
				error(['Tried to evaluate LCI_STAT string ' LCI_STAT ' as a function but got an error: ' lasterr]);
			end;
		end;	
	end;
end;


