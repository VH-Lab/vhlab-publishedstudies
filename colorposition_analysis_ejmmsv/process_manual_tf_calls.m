function [TFS1, TFS2] = process_manual_tf_calls(fnames, minvotes)

for i=1:length(fnames),
	f{i} = load(fnames{i},'-mat');
end;

TFS1 = zeros(1,length(f{1}.out1));
TFS2 = zeros(1,length(f{1}.out2));

for i=1:length(TFS1),
	votes = 0;
	vals_here = [];
	for j=1:length(fnames),
		if ~isnan(f{j}.out1(i)), % first, make sure its a TF value
			vals_here(end+1) = findclosesttf(f{j}.out1(i));
			votes = votes+1;
		end;
	end;
	if votes>=minvotes,
		TFS1(i) = median(vals_here);
	else,
		TFS1(i) = NaN;
	end;
end;

for i=1:length(TFS2),
	votes = 0;
	vals_here = [];
	for j=1:length(fnames),
		if ~isnan(f{j}.out2(i)), % first, make sure its a TF value
			vals_here(end+1) = findclosesttf(f{j}.out2(i));
			votes = votes+1;
		end;
	end;
	if votes>=minvotes,
		TFS2(i) = median(vals_here);
	else,
		TFS2(i) = NaN;
	end;
end;




function newtf_value = findclosesttf(tf_value)
[dummy,newtf_value] = findclosest([0.5 1 2 4 8 16 20 30],tf_value);
