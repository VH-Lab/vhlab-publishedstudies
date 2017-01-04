function [lci,n,inds] = localcoherence(theangle,dirorori, myangleprefs,myxy,othersangleprefs,othersxy, dists, annuli, donorm)

% LOCALCOHERENCE_CELLS Compute local coherence index for 2-photon data
%
%  [LCI,N,INDS]=LOCALCOHERENCE_CELLS(ANGLE, DIRORORI, MYANGLEPREFS,...
%                  MYXY, OTHERSANGLEPREFS, OTHERSXY, DISTS, ANNULI, NORM)
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
%  NORM (default 1): normalize by number of cells in the neighborhood.
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

if nargin<9, norm = 1; else, norm = donorm; end;

sz = size(othersangleprefs,1);

lci = zeros(length(dists),sz);
n = zeros(1,length(dists));
inds = cell(1,length(dists));

if dirorori==0, base = 90; tolerance = 22.5; shift = 45; else, base = 180; tolerance = 45; shift = 90; end;

lengths = sqrt((othersxy(:,1)-myxy(1)).^2 + (othersxy(:,2)-myxy(2)).^2);

for j=1:length(dists),
    if j==1, d0 = 0; else, d0 = dists(j-1); end;
    if ~annuli, d0 = 0; end;    
    ind = find(lengths>d0&lengths<=dists(j));
    n(j) = length(ind);
    inds{j} = ind;
    if length(ind)>=1,
        for k=1:size(othersangleprefs,1),
	    if isnan(theangle), myang = myangleprefs(k); else myang = theangle; end;
            mydiff = mod(angdiff(myang-othersangleprefs(k,ind)),base);
            if norm, denom = (length(ind)-sum(isnan(mydiff)));
            else, denom = 1;
            end;
            lci(j,k) = (length(find(mydiff<tolerance))-length(find(mydiff>(shift+tolerance))))/denom;
        end;
    else, lci(j,:) = NaN;
    end;
end;
