function [N,mn,stde,individuals] = chr2_histogramovertime(cellindexes, values, times, bins)
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

num_bins = size(bins,1);

cellnumbers = unique(cellindexes);

mn = [];
stde = [];
N = [];
individuals = {};

for i=1:num_bins,
	individuals{i} = [];
	for j=1:length(cellnumbers),
		indexes = find(cellindexes==cellnumbers(j) &  ~isnan(values) & times>=bins(i,1) & times<=bins(i,2));
		if ~isnan(bins(i,3)) & ~isempty(indexes),
			bestindex = findclosest(times(indexes),bins(i,3));
			indexes = indexes(bestindex);
		end;
		individuals{i} = cat(2,individuals{i}, values(indexes));
	end;
	mn(i) = nanmean(individuals{i});
	stde(i) = nanstderr(individuals{i});
	N(i) = length(individuals{i});
end;

