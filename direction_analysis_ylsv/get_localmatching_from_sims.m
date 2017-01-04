function localmatching = get_localmatching_from_sims(sims,simindex)

localmatching = [];

dist = 11;

for i=1:length(simindex),
	localmatching(end+1) =  sims.lmbd(simindex(i),2,dist);
end;
