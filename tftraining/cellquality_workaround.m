function quality_label = cellquality_workaround(cell)
% CELLQUALITY_WORKAROUND - A workaround to get cell quality 
%
%  QUALITY_LABEL = CELLQUALITY_WORKAROUND(CELL)
%
%  Returns the correct quality label from the 'vhlv_loadcelldata' associate
%

quality_label = 'Not useable';

A=findassociate(cell,'vhlv_loadcelldata','','');

if isempty(A), return; end;

for i=1:length(A.data),
	for j=1:length(A.data(i).clusterinfo),
		if ~strcmp(A.data(i).clusterinfo(j).qualitylabel,'Not useable'),
			quality_label = A.data(i).clusterinfo(j).qualitylabel;
			return;
		end;
	end;
end;

