function plot_layer4rfs(ori);

figure; colormap(gray(256));

numL4Pts = 100;
oris = 0:22.5:180;
c = [0.04 0.08 0.16 0.32 0.64 1];

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

ylabs = {'Divided elong','Push/pull elong','Uniform elong','Elong FFi'};

plotinc = 1;
for i=1:4,
	if i==4,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns(...
			stimspacex,stimspacey,ori);
		l4ION(:,:) = 0.5; l4IOFF(:,:) = 0.5;
		connmethod = 'unielongffinhib';
	elseif i==3,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns(...
			stimspacex,stimspacey,ori);
		connmethod = 'unielong';
	elseif i==2,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns_simple(...
			stimspacex,stimspacey,ori,1);
		connmethod = 'pushpull';
	elseif i==1,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns_simple(...
			stimspacex,stimspacey,ori,0);
		connmethod = 'divelong';
	else, return;
	end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(l4EON,[-1 1],[0 255]));
	ylabel(ylabs{i});
	if i==1, title(['Excitatory ON']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(-l4EOFF,[-1 1],[0 255]));
	if i==1, title(['Excitatory OFF']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(l4ION,[-1 1],[0 255]));
	if i==1, title(['Inhibitory ON']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(-l4IOFF,[-1 1],[0 255]));
	if i==1, title(['Inhibitory OFF']); end;
	[layer4ONinput,layer4OFFinput] = make_simplecomplex_model(ori,0,connmethod,oris,c);
	subplot(4,5,plotinc); plotinc=plotinc+1;
	plot_sim_results(layer4ONinput,layer4OFFinput,1,1,1);
end;
