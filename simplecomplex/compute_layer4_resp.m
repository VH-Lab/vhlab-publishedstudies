function [stim_on,stim_off]=compute_layer4_input(stim)

 % distance units are in degrees of visual space, not mm of cortex

numL4Pts = 100;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

PixPerDeg = diff(xi); PixPerDeg = PixPerDeg(1);
linxi = -2.5:PixPerDeg:2.5;
if mod(length(linxi),2)==0, linxi(end+1)=linxi(end)+PixPerDeg; end;
linxi = linxi - mean(linxi);
[lgnx,lgny]=meshgrid(linxi,linxi);
lgnTemp = 1.7811*exp(-(lgnx.*lgnx+lgny.*lgny)/0.1383) - 0.0264*exp(-(lgnx.*lgnx+lgny.*lgny)/1.2082);
%lgnTemp = exp(-(lgnx.*lgnx+lgny.*lgny)/1) - 0.3*exp(-(lgnx.*lgnx+lgny.*lgny)/3);
%lgnTemp = lgnTemp/sum(sum(lgnTemp)); lgnTemp = lgnTemp;

%imagedisplay(lgnTemp);

 % to save memory, we will compute the total layer 4 input to each cell
 %   rather than saving all of the connections from layer 4 to 2/3
 % compute layer 4 input to each cell

stim_on = zeros(numL4Pts,numL4Pts,size(stim,3));
stim_off = stim_on;

for i=1:size(stim,3),
	son = conv2(stim(:,:,i),lgnTemp,'same');
	son(find(son<0)) = 0; % threshold
	stim_on(:,:,i) = son;
	soff = conv2(stim(:,:,i),-lgnTemp,'same');
	soff(find(soff<0)) = 0; % threshold
	stim_off(:,:,i) = soff;
end;

