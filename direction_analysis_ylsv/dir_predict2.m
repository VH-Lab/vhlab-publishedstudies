function [DP,or,di] = dir_predict2(IMs, angles,plotit)

    %in this version, calculate direction preferences and values based on
    %responses in a 400um (20 pixel?) field around each pixel.  The
    %direction preference and magnitude are calculated by vector averaging
    %all responses in the field weighted by their distance and angular
    %position relative to the pixel of interest

[or,di] = intrinorivectorsum(IMs,angles,0,1);

sz = 20;

 %create a grid for distance dependence

[Dx,Dy] = meshgrid(-sz:sz,-sz:sz);

DD = [Dx(:) Dy(:)];

    % calculate the vector angle to every point
vangle = reshape(angle(DD(:,1)+sqrt(-1)*DD(:,2)),1+2*sz,1+2*sz);
vanglemat = exp(sqrt(-1)*vangle); vanglemat(1+sz,1+sz) = 0; 

DP = zeros(size(or));

bestStim = zeros(size(or));
bestVal = -Inf*ones(size(or));

inc = 1;
for a=0:22.5:180-22.5,
    ra = a*pi/180;
    R = abs(or).*exp(-(myangdiff(ra-mod(angle(or),2*pi)/2).^2)./(2*(25*pi/180)^2));
    
    if ~isempty(find(R>bestVal)),
        bestStim(find(R>bestVal)) = inc;
        bestVal(find(R>bestVal)) = R(find(R>bestVal));
    end;
    inc = inc + 1;
end;

inc = 1;
for a=0:22.5:180-22.5,
%    if a==90, keyboard; end;
    ra = a*pi/180;
    R = abs(or).*exp(-(myangdiff(ra-mod(angle(or),2*pi)/2).^2)./(2*(25*pi/180)^2));

    % variation 2, find mean weight of all simple cell vectors, that
    % determines direction and direction magnitude
    
    theta = compass2cartesian(ra,1);
    DDr = DD * [cos(theta) -sin(theta); sin(theta) cos(theta)];
    DDr(find(abs(DDr(:,1))<0.1),1) = 0;
    ds = abs(DDr(:,1));
    ds(find(ds<1)) = 1;
    D_ = ones(size(DDr(:,1)))./abs(ds);
    D_r = reshape(D_,size(Dx,1),size(Dx,2));
        % D_r now weights by distance along the preferred orientation
    %imagedisplay(D_r);
    
    % find points with this orientation
    [I,J] = find(bestStim==inc);
    % now loop over all points 
    
    for i=1:length(I),
        if I(i)>sz&size(or,1)-sz-1>=I(i) &  J(i)>sz&size(or,2)-sz-1>=J(i),
            %find direction by weighting response by distance and then calculating
            %mean angle for all connected neurons
            DP(I(i),J(i)) = meanfield(R(I(i)+(-sz:sz),J(i)+(-sz:sz)).*D_r,vanglemat);
        end;
    end;
        
    inc = inc + 1;
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

function mf=meanfield(F,vanglemat)
MF = F.*vanglemat;
mf = mean(MF(:));