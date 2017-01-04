function do_divider_plots(prefix,expernames,divider)

%prefix = ['E:\2photon\ferretdirection\'];

%expernames = {'2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07','minis\2007-06-27' ,   'minis\2007-06-28' ,   'minis\2007-08-30'};
%stacknames = {'site1','site1','Site1','site1','site3','site1','site1','site1'};
%divider = [90 -45 0 90 45 45 0 0 ];

for i=1:length(expernames),
	tpf = [prefix expernames{i}];

	ds = dirstruct(tpf);

	stacknames = findallstacks(ds),

	for j=1:length(stacknames),

		[imb,ima] = plot_otdirstack_divide_beforeafter(tpf, stacknames{j}, divider(i));
		%close;
		[imc] = plot_otdirstack_divide_beforeonly(tpf, stacknames{j}, divider(i));
		%close;
	
		if 1,
			imwrite(imb, [fixpath(getscratchdirectory(ds)) expernames{i} '_' stacknames{j} '_before_dividerplot2.tif'],'tiff','compression','none');
			imwrite(ima, [fixpath(getscratchdirectory(ds)) expernames{i} '_' stacknames{j} '_after_dividerplot2.tif'], 'tiff','compression','none');
			imwrite(imc, [fixpath(getscratchdirectory(ds)) expernames{i} '_' stacknames{j} '_beforeall_dividerplot2.tif'], 'tiff','compression','none');
		end;

		clear ima imb imc;
	end;
end;
