
 % trim out a bogus record from Neil's data

for totrim = [100 172 200],

%for totrim = [200]

chr2_visanalysis.cellnames = chr2_visanalysis.cellnames([1:totrim-1 totrim+1:end]);
chr2_visanalysis.cells= chr2_visanalysis.cells([1:totrim-1 totrim+1:end]);
chr2_visanalysis.output = chr2_visanalysis.output([1:totrim-1 totrim+1:end]);
chr2_visanalysis.experids = chr2_visanalysis.experids([1:totrim-1 totrim+1:end]);
chr2_visanalysis.i = 1:length(chr2_visanalysis.output);
chr2_visanalysis.incl = 1:length(chr2_visanalysis.output);
chr2_visanalysis.included = 1:length(chr2_visanalysis.output);

end;
