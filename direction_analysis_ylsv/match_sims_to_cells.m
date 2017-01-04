function simindex = match_sims_to_cells(sims, cells,expernames)

simindex = {};
simindex{12} = []; simindex{13} = [];

for k=12:13,
	for j=1:length(cells.cellnamevar{k}),
		foundit = 0;
		for i=1:length(sims.mapnaive),
			if isfield(sims.mapnaive(i),'cellname'),
				if strcmp(cells.cellnamevar{k}{j},sims.mapnaive(i).cellname),
					simindex{k}(end+1) = i;	
					foundit = 1;
					break;
				end;
			else, % use expername and position
				if strcmp(expernames{cells.experindex{k}(j)},sims.mapnaive(i).expername)&eqlen(cells.pos{12}(:,j)',sims.mapnaive(i).pos),
					simindex{k}(end+1) = i;	
					foundit = 1;
					break;
				end;
			end;
		end;
		if ~foundit, simindex{k}(end+1) = NaN; end;
	end;
end;


