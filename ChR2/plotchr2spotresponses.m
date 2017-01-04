function f=plotchr2spotresponse(filename,sz)

z = load(filename);
[xmesh,ymesh]=meshgrid(1:800,1:600);

f = double(zeros(size(xmesh)));

x_ctr = z.location_response(:,1);
y_ctr = z.location_response(:,2);
response = z.location_response(:,3);
radius = ones(size(z.location_response(:,2))) * sz;
rotation = 0*radius;

for i=1:length(x_ctr),
	in = inside_ellipse(xmesh,ymesh,x_ctr(i),y_ctr(i),radius(i),radius(i),0);
	inds = find(in);
	f(inds) = max([f(inds(:)) response(i)*ones(size(f(inds(:))))],[],2);
end;

size(f)

figure;
colormap(jet(256));
imagesc(1.3*[1:800],1.3*[1:600],f);
colorbar;
axis equal
box off
