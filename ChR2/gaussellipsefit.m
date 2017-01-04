function gaussellipsefit
z = load('t00043_75')

[xmesh,ymesh]=meshgrid(1:800,1:600);
x_ctr = z.location_response(:,1);
y_ctr = z.location_response(:,2);
response = z.location_response(:,3);
radius = ones(size(z.location_response(:,2))) * 75;
rotation = 0*radius;

[mu, C, a] = gaussspotfit(1:800, 1:600, x_ctr, y_ctr,radius,response);

figure;
p = mvnpdf([xmesh(:) ymesh(:)],mu,C);
colormap(jet(256));
image(1.3*[1:800],1.3*[1:600],255 *reshape(p,600,800)/max(p(:)));

