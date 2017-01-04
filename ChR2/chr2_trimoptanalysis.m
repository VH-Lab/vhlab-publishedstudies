
 % trim out a bogus record from Neil's data

%for totrim = [100 172 200],

for totrim = [85]

chr2_analysis.cellnames = chr2_analysis.cellnames([1:totrim-1 totrim+1:end]);
chr2_analysis.cells= chr2_analysis.cells([1:totrim-1 totrim+1:end]);
chr2_analysis.output = chr2_analysis.output([1:totrim-1 totrim+1:end]);
chr2_analysis.experids = chr2_analysis.experids([1:totrim-1 totrim+1:end]);
chr2_analysis.i = 1:length(chr2_analysis.output);
chr2_analysis.incl = 1:length(chr2_analysis.output);
chr2_analysis.included = 1:length(chr2_analysis.output);

end;
