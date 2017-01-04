function [layer4ONinput,layer4OFFinput]=compute_layer4_input(tsmap,tsmaplocs,connmethod,stim_on,stim_off)

 % distance units are in degrees of visual space, not mm of cortex

numL4Pts = 100;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

layer4ONinput = zeros(size(tsmap,1),size(tsmap,2),size(stim_on,3));
layer4OFFinput = zeros(size(tsmap,1),size(tsmap,2),size(stim_on,3));

for i=1:size(tsmap,1),
	for j=1:size(tsmap,2),
		mystimspacex = stimspacex - tsmaplocs(i,j); mystimspacey = stimspacey - tsmaplocs(i,j);
		switch connmethod,
			case 'pushpull',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh,inhT,inhG,l4gain] = layer4_layer23_conns_simple(mystimspacex,mystimspacey,tsmap(i,j),1);
			case 'divelong',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh,inhT,inhG,l4gain] = layer4_layer23_conns_simple(mystimspacex,mystimspacey,tsmap(i,j),0);
			case 'unielong',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh,inhT,inhG,l4gain] = layer4_layer23_conns(mystimspacex,mystimspacey,tsmap(i,j));
				l4ONinh(:,:) = 0; l4OFFinh(:,:) = 0;
			case 'unielongffinhib',
				[l4ONexc,l4OFFexc,l4ONinh,l4OFFinh,inhT,inhG,l4gain] = layer4_layer23_conns(mystimspacex,mystimspacey,tsmap(i,j));
		end;
		for k=1:size(stim_on,3),
			exc = sum(sum(l4gain*l4ONexc.*stim_on(:,:,k)));
			inh = sum(sum(l4gain*l4ONinh.*stim_on(:,:,k))); inh = (inh-inhT)*inhG; inh(find(inh<0)) = 0;
			layer4ONinput(i,j,k) = exc-inh;
			exc = sum(sum(l4gain*l4OFFexc.*stim_off(:,:,k)));
			inh = sum(sum(l4gain*l4OFFinh.*stim_off(:,:,k))); inh = (inh-inhT)*inhG; inh(find(inh<0)) = 0;
			layer4OFFinput(i,j,k) = exc-inh;
		end;
	end;
	%i,
end;
