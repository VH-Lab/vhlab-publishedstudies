function [layer4ONinput,layer4OFFinput,layer23conns,oripref,stim_on,stim_off]=make_simplecomplex_model(tsmap,tsmaplocs,connmethod,oris,contrasts)

 % distance units are in degrees of visual space, not mm of cortex
 % returns stencils for each orientation from 0 to 179

numL4Pts = 100;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

PixPerDeg = diff(xi); PixPerDeg = PixPerDeg(1);
linxi = -4:1/PixPerDeg:4;
if mod(length(linxi),2)==0, linxi(end+1)=linxi(end)+1/PixPerDeg; end;
linxi = linxi - mean(linxi);
[lgnx,lgny]=meshgrid(linxi,linxi);
lgnTemp = exp(-(lgnx.*lgnx+lgny.*lgny)/1) - 0.2*exp(-(lgnx.*lgnx+lgny.*lgny)/3);
lgnTemp = lgnTemp/sum(sum(lgnTemp));

%imagedisplay(lgnTemp);

 % to save memory, we will compute the total layer 4 input to each cell
 %   rather than saving all of the connections from layer 4 to 2/3
 % compute layer 4 input to each cell

for i=1:length(oris),
	stim{i} = createmodeloristim(stimspacex,stimspacey,oris(i),5,2);
	stim_on{i} = conv2(stim{i},lgnTemp,'same');
	stim_on{i}(find(stim_on{i}<0)) = 0; % threshold
	stim_off{i} = conv2(stim{i},-lgnTemp,'same');
	stim_off{i}(find(stim_off{i}<0)) = 0; % threshold
	disp(['Just made orientation stim number ' int2str(i) '.']);
end;

layer4ONinput = zeros(size(tsmap,1),size(tsmap,2),length(oris));
layer4OFFinput = zeros(size(tsmap,1),size(tsmap,2),length(oris));

layer23conns = zeros(1);

for i=1:size(tsmap,1),
	for j=1:size(tsmap,2),
		mystimspacex = stimspacex - tsmaplocs(i,j); mystimspacey = stimspacey - tsmaplocs(i,j);
		switch connmethod,
			case 'pushpull',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh] = layer4_layer23_conns_simple(mystimspacex,mystimspacey,tsmap(i,j),1);
			case 'divelong',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh] = layer4_layer23_conns_simple(mystimspacex,mystimspacey,tsmap(i,j),0);
			case 'unielong',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh] = layer4_layer23_conns(mystimspacex,mystimspacey,tsmap(i,j));
			case 'unielongffinhib',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh] = layer4_layer23_conns(mystimspacex,mystimspacey,tsmap(i,j));
				l4ONinh(:,:) = 0.5; L4OFFinh(:,:) = 0.5;
		end;
		for k=1:length(oris),
			for c = 1:length(contrasts),
				layer4ONinput(i,j,k,c) = sum(sum(l4ONexc.*contrasts(c).*stim_on{k}))-sum(sum(l4ONinh.*contrasts(c).*stim_on{k}));
				layer4OFFinput(i,j,k,c) = sum(sum(l4OFFexc.*contrasts(c).*stim_off{k}))-sum(sum(l4OFFinh.*contrasts(c).*stim_off{k}));
			end;
		end;
	%keyboard;
		%layer23conns(i,:) = reshape(layer23_layer23_conns(mystimspacex,mystimspacey,i),1,numPts);
		if 0&i==13&j==13,
			figure;
			image(255*layer4conns);
			%keyboard;
		end;
	end;
	i,
end;

oripref = tsmap;

