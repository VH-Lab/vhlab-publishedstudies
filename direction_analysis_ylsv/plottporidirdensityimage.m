function plottporidirdensityimage(img_ot, img_di, img_mask, varargin)

scale_mn = [];
scale_mx = [];
thresh = 1e-5;

if nargin > 3, assign(varargin{:}); end;

ctab = [fitzlabclut(128); gray(128)];

or_angs = rescale(mod(angle(img_ot),2*pi),[0 2*pi],[1 128]); 
di_angs = rescale(mod(angle(img_di),2*pi),[0 2*pi],[1 128]);
di_mag = abs(img_di); or_mag = abs(img_ot);
MN = min([min(min(di_mag)) min(min(or_mag))]);
MX = max([max(max(di_mag)) max(max(or_mag))]);

if ~isempty(scale_mn), MN = scale_mn; end;
if ~isempty(scale_mx), MX = scale_mx; end;
di_mag = rescale(di_mag,[MN MX],[129 256]);
or_mag = rescale(or_mag,[MN MX],[129 256]);

mask = find(img_mask<thresh);

or_angs(mask) = 129; di_angs(mask) = 129;
figure;
colormap(ctab);

subplot(2,2,1);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
image(or_angs);
title('Orientation angles');

subplot(2,2,2);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
image(or_mag);
title('Orientation magnitude');

subplot(2,2,3);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
image(di_angs);
title('Direction angles');

subplot(2,2,4);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
image(di_mag);
title('Direction magnitude');
