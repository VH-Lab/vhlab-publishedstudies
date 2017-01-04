function ds = DS_dos_tf(TFs,responses)
% DS_DOS_TF = Compute DS, difference over sum, for a variety of measurements at different TFs
%
%   DS = DS_DOS_TF(TFS, RESPONSES)
%
%   Given response measurements at a variety of TFs (positive and negative, indicating the 'preferred' axis of
%   direction and negative directions, respectively), and corresponding responses RESPOSNES, compute direction
%   selectivity as the difference over the sum.
%
%     DS = (PREF - NULL) / (PREF + NULL)
%
%   It is assumed that there are as many entries in RESPONSES as in TFS.  It is assumed that for each
%   entry in TFS(i), there is corresponding measurement at -TFS(i).
%
%   If neither direction exhibits a response, then DS is 0. If PREF+NULL is 0, then the DS is 1 if PREF-NULL
%   is positive, and -1 otherwise.  If DS is > 1, then DS is constrained to be 1. If DS < -1, then DS is constrained
%   to be -1.
%
%   (Wait: you ask, how can PREF-NULL be negative? Here, we assume the direction axis is being defined by
%   some other criteria, such as the response at a particular speed.)
%
%   DS is a 2 row matrix; the first row indicates the TF (absolute value). The second row is a vector with the same
%   number of entries as TFS and RESPONSES, indicating the DS at each TF.
%
 
tfs_here = unique(abs(TFs));
ds = [];
for t = 1:length(tfs_here),
	[lia,locb] = ismember([tfs_here(t) -tfs_here(t)],TFs);
	if ~all(lia),
		error(['Could not find both positive and negative TF entry for TF ' num2str(tfs_here(t)) '.']);
	end;

	num =   responses(:,locb(1)) - responses(:,locb(2));
	denom = responses(:,locb(1)) + responses(:,locb(2));

	ds(:,t) = num./denom;
	denom_0c1 = find((denom==0)&(num==0));
	denom_0c2 = find((denom==0)&(num>0));
	denom_0c3 = find((denom==0)&(num<0));
	ds(denom_0c1,t) = 0;
	ds(denom_0c2,t) = 1;
	ds(denom_0c3,t) = -1;
end;

ds(find(ds>1)) = 1;
ds(find(ds<-1)) = -1;

ds = [ tfs_here; ds]; 


