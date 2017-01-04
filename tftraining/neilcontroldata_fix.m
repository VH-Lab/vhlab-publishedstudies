

assoc = newassoc('Training TF','steve',0,'training tf');
for i=1:length(cells), [B,I]=findassociate(cells{i},'Training TF','',''); if ~isempty(I), cells{i}=disassociate(cells{i},I); end; end;
cells=associate_all(cells,assoc);


