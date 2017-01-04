function [DP,or,di] = dir_predict(IMs, angles,plotit)

[or,di] = intrinorivectorsum(IMs,angles,0,1);

sz = 10;

[Dx,Dy] = meshgrid(-sz:sz,-sz:sz);

DD = [Dx(:) Dy(:)];

D = 1./sqrt(Dx.^2+0*Dy.^2);
D(find(isinf(D))) = 0;

DP = zeros(size(or));

inc = 1;
for a=0:22.5:180-22.5,
    
%    if a==90, keyboard; end;
    ra = a*pi/180;
    R = abs(or).*exp(-(myangdiff(ra-mod(angle(or),2*pi)/2).^2)./(2*(25*pi/180)^2));

    theta = compass2cartesian(ra,1);
    DDr = DD * [cos(theta) -sin(theta); sin(theta) cos(theta)];
    DDr(find(abs(DDr(:,1))<0.1),1) = 0;
    ds = abs(DDr(:,1));
    ds(find(ds<1)) = 1;
    
    D_ = (-(DDr(:,1)>0)+(DDr(:,1)<0))./abs(ds);
    D_r = reshape(D_,size(Dx,1),size(Dx,2));
    %imagedisplay(D_r);
    
    %DC = D.*D_r;

    DP = DP + exp(sqrt(-1)*ra) * conv2(R,D_r,'same');
end;

if plotit,
	ctab = [fitzlabclut(128) ;gray(128)];
	or_angs = rescale(mod(angle(or),2*pi),[0 2*pi],[1 128]); 
	di_angs = rescale(mod(angle(di),2*pi),[0 2*pi],[1 128]);
    dip_angs =rescale(mod(angle(DP),2*pi),[0 2*pi],[1 128]);
	di_mag = abs(di);or_mag = abs(or); dip_mag = abs(DP);
	MN = min([min(min(di_mag)) min(min(or_mag))]); MX = max([max(max(di_mag)) max(max(or_mag))]);
	di_mag = rescale(di_mag,[MN MX],[129 256]);
	or_mag = rescale(or_mag,[MN MX],[129 256]);
    dip_mag = rescale(dip_mag,[min(min(dip_mag)) max(max(dip_mag))],[129 256]);
	figure;
	colormap(ctab);

	subplot(3,2,1);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(or_angs);
	title('Orientation angles');axis equal;

	subplot(3,2,2);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(or_mag);
	title('Orientation magnitude');axis equal;

	subplot(3,2,3);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_angs);
	title('Direction angles');axis equal;

	subplot(3,2,4);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_mag);
	title('Direction magnitude');axis equal;
    
	subplot(3,2,5);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(dip_angs);
	title('Direction angles');axis equal;

	subplot(3,2,6);p=get(gca,'position'); %set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(dip_mag);
	title('Direction magnitude');axis equal;
end;


function d=myangdiff(a)

d=min(abs(cat(3,a,a-pi,a+pi)),[],3);
