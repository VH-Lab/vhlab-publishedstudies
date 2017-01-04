function [DIs,angdir] = calc_bootstrap_di(BSf, blankind,BSresp)

DIs = [];
DIsr = [];

vec = 0;

for i=1:size(BSf,1),
	bl = nanmean(blankind);
	DIsr(end+1) = fit2fitdibr(BSf(i,:),bl,squeeze(BSresp(:,:,i)));
	vec = vec + exp(sqrt(-1)*2*pi*mod(BSf(i,3),180)/180);
end;

if 0,  % if use vector method
	angori = mod(angle(vec),pi);

	for i=1:size(BSf,1),
		DIs(i) = DIsr(i) * real ( dot(exp(sqrt(-1)*angori), exp(sqrt(-1)*pi*BSf(i,3)/180)) );
	end;

	I = find(DIs<0);

	angori = angori * 180 / pi;
	angdir = angori;

	if 2*length(I)>size(BSf,1), DIs = -DIs; angdir = angori + 180;  end;

	DIs = DIs';

	return;
end;

 % divide directions into positive and negative

DIs = DIsr;

angori = mod(angle(vec)*180/(2*pi),180);

I = find(angdiff(angori-BSf(:,3)')>90);

if length(I)>0.5*size(BSf,1),  % if more guys with this direction
	DIs = -DIs; % flip around so positive will be preferred direction
	angdir = angori + 180;
else, angdir = angori;
end;

DIs(I) = - DIs(I);

DIs = DIs';

