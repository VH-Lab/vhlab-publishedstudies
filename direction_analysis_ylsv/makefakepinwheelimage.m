function ims=makefakepinwheelimage;
  % makes pinwheel image like Fig 3A, in cartesian space

ims = zeros(120,252,16);

im0 = ims(:,:,1);

[Dx,Dy] = meshgrid(linspace(-252/2,252/2,252),linspace(-60,60,120));

% in compass units, 135, 90, 45
% in cartesian, -45/135, 0, 45 

im_ = im0;
g = find( Dy<0& 30>sqrt(Dy.^2+Dx.^2) & 30<sqrt(3*Dy.^2+Dx.^2));
im_(g) = -1;

ims(:,:,7) = im_;
ims(:,:,15) = im_;

im_ = im0;
g = find(  30>sqrt(3*Dy.^2+Dx.^2));
im_(g) = -1;

ims(:,:,1) = im_;
ims(:,:,9) = im_;

im_ = im0;
g = find( Dy>0& 30>sqrt(Dy.^2+Dx.^2) & 30<sqrt(3*Dy.^2+Dx.^2));
im_(g) = -1;

ims(:,:,3) = im_;
ims(:,:,11) = im_;

