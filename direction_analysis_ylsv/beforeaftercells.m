function mycells = beforeaftercells(cells)

incl = [];
for i=1:length(cells),
	VVp = findassociate(cells{i},'OT vec varies p','','');
	RVp = findassociate(cells{i},'Recovery OT vec varies p','','');
	if ~isempty(VVp) & ~isempty(RVp),
		if (VVp.data < 0.05) & (RVp.data < 0.05),
			incl(end+1) = i;
		end;
	end;
end;

if isempty(incl),

	for i=1:length(cells),
		VVp = findassociate(cells{i},'TP Ach OT vec varies p','','');
		RVp = findassociate(cells{i},'TP ME Ach OT vec varies p','','');
		if ~isempty(VVp) & ~isempty(RVp),
			if (VVp.data < 0.05) & (RVp.data < 0.05),
				incl(end+1) = i;
			end;
		end;
	end;

end;

mycells = cells(incl);
