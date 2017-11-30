function z  = make_gaussian_image(filename);

pts = load([filename '_results.txt'],'-ascii');
roi = load([filename '_roi.txt'],'-ascii');
roipts = roi(:,2:3)-repmat([pts(1,2) pts(1,3)],length(roi),1);
cellpts = pts(:,2:3)-repmat([pts(1,2) pts(1,3)],length(pts),1); 
data = load([filename '_data'],'-mat');

scale = data.scale;
scalepts = cellpts / scale;
scaleroi = roipts / scale;

S=-3.5:0.01:3.5;

[x,y]=meshgrid(S,S);

z = zeros(size(x));

R = [ 0.005 0 ; 0 0.005 ];
sig = (det(R)); sig_ = diag(inv(R));

[x_,y_]=meshgrid(-0.25:0.01:0.25);
l = length(x_);

patch = ((0.01)^2)*exp(-0.5*((sig_(1)*x_.^2+sig_(2)*y_.^2)))/(2*pi*sqrt(sig));

for i=2:length(scalepts),
	[pt,ptlocx] = min(abs(x(1,:)-scalepts(i,1)));
	[pt,ptlocy] = min(abs(y(:,1)-scalepts(i,2)));

	[ptlocx ptlocy]
	
	z(ptlocx-(l-1)/2:ptlocx+(l-1)/2,ptlocy-(l-1)/2:ptlocy+(l-1)/2)=...
	z(ptlocx-(l-1)/2:ptlocx+(l-1)/2,ptlocy-(l-1)/2:ptlocy+(l-1)/2)+patch;
	i,
end;
