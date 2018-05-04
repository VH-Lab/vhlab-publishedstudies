function mousevision_ipsicontraresps(cells,cellnames,output)

for i=1:length(output.totals{1}),
	figure; 
	plottpresponse(cells{output.totals{1}(i)},...
		cellnames{output.totals{1}(i)},...
		'CONTRAIPSI',1,1);

	A=axis;
	z = mean(A([3 4]));
	text(180,z,['CI = ' num2str(output.CI{1}(i)) '.']);
end;
