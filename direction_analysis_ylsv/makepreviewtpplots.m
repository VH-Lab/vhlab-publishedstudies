function makepreviewtpplots(ds)

T  = getalltests(ds);
mypwd = getpathname(ds);
mxColors = 1000; if strcmp(computer,'PCWIN'), mxColors = 256; end;
for i=1:length(T),
	%try,
		im=previewprairieview([mypwd filesep T{i}],50,1,1);
		im=im(:,end:-1:1)'; % rotate 90 degrees to align w/ intrinsic
		figure;
		image(rescale(im,[min(min(im)) max(max(im))],[0 mxColors]));
		colormap(gray(mxColors));
		set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
		eval(['print -djpeg90 -r300 ' mypwd filesep 'analysis' filesep 'PREVIEW_' T{i} '.jpg']);
		close;
	%end;
end;

if ~isempty(ds),
	mypwd = [getpathname(ds) filesep 'analysis' filesep];
end;

