function [N,mn,p33,p67,individuals,indsofindividuals] = chr2_histogramovertime(cellindexes, values, times, bins, morevalues)
% CHR2_HISTOGRAMOVERTIME - Compute histograms over time
%
%   [N,MN,STDE,INDIVIDUALS] = CHR2_HISTOGRAMOVERTIME(VALUES, TIMES, BINS)
%
%
%   BINS - Each row indicates a different bin with 3 values: the start of the bin,
%   the end of the bin, and the bin center (if there is more than one point in the bin
%   identity, then the one closest to bin center will be used).  If bin center is NaN,
%   then all points will be included.
%
%   INFINITE values are ignored here
%   

num_bins = size(bins,1);

cellnumbers = unique(cellindexes);

mn = [];
p33= [];
p67= [];
N = [];
individuals = {};
indsofindividuals = {};

for i=1:num_bins,
	individuals{i} = [];
    indsofindividuals{i} = [];
	for j=1:length(cellnumbers),
		indexes = find(cellindexes==cellnumbers(j) &  ~isnan(values) & times>=bins(i,1) & times<=bins(i,2) & ~isinf(values) & ~isnan(morevalues));
		if ~isnan(bins(i,3)) & ~isempty(indexes),
			bestindex = findclosest(times(indexes),bins(i,3));
			indexes = indexes(bestindex);
		end;
		individuals{i} = cat(2,individuals{i}, values(indexes));
		indsofindividuals{i} = cat(2,indsofindividuals{i}, (indexes));
	end;
	mn(i) = nanmedian(individuals{i});
	p33(i) = prctile(individuals{i},33);
	p67(i) = prctile(individuals{i},67);
	N(i) = length(individuals{i});
end;

