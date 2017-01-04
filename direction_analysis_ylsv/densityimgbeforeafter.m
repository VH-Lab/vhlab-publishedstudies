function [ori_im,dir_im,img_mask,orir_im,dirr_im,img_maskr]=densityimgbeforeafter(cells, plotit)

sigma = 250;

[ori_im,dir_im,img_mask] = tporidirdensityimage(cells,'sigma',sigma);

MN = min(min(min(abs(ori_im))),min(min(abs(dir_im))));
MX = max(max(max(abs(ori_im))),max(max(abs(dir_im))));

thresh = 1e-5;

plottporidirdensityimage(ori_im, dir_im, img_mask, 'thresh',thresh);

otindfunc = ['f=findassociate(cells{j},''Recovery OT Carandini Fit Params'','''','''');' ...
	'bl=findassociate(cells{j},''Recovery Best orientation resp'','''','''');'...
	'fi=findassociate(cells{j},''Recovery OT Carandini Fit'','''','''');'...
	'OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));'...
	'OtO1i=findclosest(0:359,mod(f(1).data(3)+90,360));OtO2i=findclosest(0:359,mod(f(1).data(3)-90,360));'...
	'oi=sum([1 1 -1 -1].*fi(1).data([OtPi OtNi OtO1i OtO2i]))/(sum(fi(1).data([OtPi OtNi]))-2*bl(1).data.blankresp(1));'];

dirindfunc = ['f=findassociate(cells{j},''Recovery OT Carandini Fit Params'','''','''');' ...
	'bl=findassociate(cells{j},''Recovery Best orientation resp'','''','''');'...
	'fi=findassociate(cells{j},''Recovery OT Carandini Fit'','''','''');'...
	'OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));'...
	'di=sum([1 -1].*fi(1).data([OtPi OtNi]))./(fi(1).data(OtPi)-bl(1).data.blankresp(1));'];

inclfunc = ['b=0;p=findassociate(cells{j},''Recovery OT vec varies p'','''','''');if ~isempty(p),b=p(1).data<0.05;end;'];

otpreffunc = ['p=findassociate(cells{j},''Recovery OT Fit Pref'','''','''');op=mod(p(1).data,180);'];
dirpreffunc = ['p=findassociate(cells{j},''Recovery OT Fit Pref'','''','''');dp=mod(p(1).data,360);'];

[orir_im,dirr_im,img_maskr] = tporidirdensityimage(cells,'otindfunc',otindfunc,'dirindfunc',dirindfunc,'inclfunc',inclfunc,'otpreffunc',otpreffunc,'dirpreffunc',dirpreffunc,'sigma',sigma);

plottporidirdensityimage(orir_im, dirr_im, img_maskr, 'thresh',thresh,'scale_mn',MN,'scale_mx',MX);

