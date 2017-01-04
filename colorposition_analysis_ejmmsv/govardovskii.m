function [ssa1] = govardovskii(lm,w);

% this Matlab M file will generate a template for photo-pigment 
% based on A1 rhodopsin (from Misha Vorobyev, orignially from 
% Govardovskii)
%
% From Zoran Radisic, circa 2001

% feature: beta band will move depending upon the alpha band

% lm=input('Maximal wavelength of template: ');
%w=300:700;  N=401;
N=length(w);

a1=69.94;
a=61.6/a1;
b1=27.5;
b=0.9232;
c1=-14.3;
c=1.1;
d=0.639478;

x=lm./w;
alpha=1 ./ (exp(a1.*(a.*ones(1,N)-x)) + exp(b1.*(b.*ones(1,N)-x)) + ...
            exp(c1.*(c.*ones(1,N)-x)) + d.*ones(1,N));
lmb=106+0.484*lm;
bw=147-0.463*lm+0.000555*(lm^2);
beta=0.26*exp(-(((lmb.*ones(1,N)-w)./bw).^2));
ssa1=alpha+beta;
ssa1=ssa1./max(ssa1);
%ssa1=ssa1(101:401);

% figure;plot(400:700,ssa1,'k-');

% k=num2str(lm,'%3d');
% file=['rhodo',k,'.dat'];
% fid=fopen(file,'w');
% fprintf(fid,'%6.8f\n',ssa1);
% fclose(fid);
