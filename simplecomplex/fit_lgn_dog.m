function [P,curve] = fit_lgn_dog(stim);

numL4Pts = 100;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

PixPerDeg = diff(xi); PixPerDeg = PixPerDeg(1);
linxi = -4:PixPerDeg:4;
if mod(length(linxi),2)==0, linxi(end+1)=linxi(end)+PixPerDeg; end;
linxi = linxi - mean(linxi);
[lgnx,lgny]=meshgrid(linxi,linxi);
lgnTemp = 1.7811*exp(-(lgnx.*lgnx+lgny.*lgny)/0.1383) - 0.0264*exp(-(lgnx.*lgnx+lgny.*lgny)/1.2082);
%lgnTemp = lgnTemp/sum(sum(lgnTemp)); lgnTemp = lgnTemp;

P = fminsearch(@(P) mydogerr(P,lgnx,lgny,stim),[0 1 1 -0.3 3]);
[err,curve] = mydogerr(P,lgnx,lgny,stim);

function [err,curve] = mydogerr(P,lgnx,lgny,stim);

SF = [ 0.05 0.1 0.2 0.4 0.8 1.6];
%D = [ 15 26 30 25 14 4];
D = [ 0 15 30 20 0 0];
P = abs(P);
lgnTemp = P(1)+P(2)*exp(-(lgnx.*lgnx+lgny.*lgny)/P(3)) - P(4)*exp(-(lgnx.*lgnx+lgny.*lgny)/5);
%lgnTemp = lgnTemp/sum(sum(lgnTemp)); lgnTemp = lgnTemp;
son = [];
for i=1:size(stim,3),
        son(end+1) = sum(sum(stim(1:53,1:53,i).*lgnTemp));
end;
curve = max(reshape(son,13,6));
err = sum((curve-D).^2);


