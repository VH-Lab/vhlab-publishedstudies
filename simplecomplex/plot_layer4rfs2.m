function plot_layer4rfs(ori);

figure; colormap(gray(256));

numL4Pts = 100;
oris = 0:22.5:180;
phases = 0:pi/6:2*pi;
sfs = [0.05 0.1 0.2 0.4 0.8 1.6 ];
c = [0.04 0.08 0.16 0.32 0.64 1];
%c = 1;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

% make oriented gratings

stimoris2 = [];
for i=1:length(oris),
	for p=1:length(phases),
		stimoris2 = cat(3,stimoris2,make_ori_grating(stimspacex,stimspacey,oris(i),0.2,phases(p)));
	end;
end;
[stimoris2_on,stimoris2_off] = compute_layer4_resp(stimoris2);

stimphase2 = [];
for p=1:length(phases),
	stimphase2 = cat(3,stimphase2,make_ori_grating(stimspacex,stimspacey,ori,0.2,phases(p)));
end;
[stimphase2_on,stimphase2_off] = compute_layer4_resp(stimphase2);

stimsf = [];
for s=1:length(sfs),
	for p=1:length(phases),
		stimsf = cat(3,stimsf,make_ori_grating(stimspacex,stimspacey,ori,sfs(s),phases(p)));
	end;
end;
[stimsf_on,stimsf_off] = compute_layer4_resp(stimsf);

ylabs = {'Divided elong','Push/pull elong','Uniform elong','Elong FFi'};

plotinc = 1;
for i=4:4,
	if i==4,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns(...
			stimspacex,stimspacey,ori);
		connmethod = 'unielongffinhib';
		stimoris_on = stimoris2_on; stimoris_off = stimoris2_off; stimphase_on = stimphase2_on; stimphase_off=stimphase2_off;
	elseif i==3,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns(...
			stimspacex,stimspacey,ori);
		l4ION(:,:) = 0.0; l4IOFF(:,:) = 0.0;
		connmethod = 'unielong';
		stimoris_on = stimoris2_on; stimoris_off = stimoris2_off; stimphase_on = stimphase2_on; stimphase_off=stimphase2_off;
	elseif i==2,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns_simple(...
			stimspacex,stimspacey,ori,1);
		connmethod = 'pushpull';
		stimoris_on = stimoris2_on; stimoris_off = stimoris2_off; stimphase_on = stimphase2_on; stimphase_off=stimphase2_off;
	elseif i==1,
		[l4EON,l4EOFF,l4ION,l4IOFF]=layer4_layer23_conns_simple(...
			stimspacex,stimspacey,ori,0);
		connmethod = 'divelong';
		stimoris_on = stimoris2_on; stimoris_off = stimoris2_off; stimphase_on = stimphase2_on; stimphase_off=stimphase2_off;
	else, return;
	end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(l4EON-l4ION,[-1 1],[0 255]));
	ylabel(ylabs{i});
	if i==1, title(['ON input']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	image(rescale(-l4EOFF+l4IOFF,[-1 1],[0 255]));
	if i==1, title(['OFF input']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	for cont = 1:length(c),
		if cont==1, hold off; else, hold on; end;
		[layer4ONinput,layer4OFFinput] = compute_layer4_input(ori,0,connmethod,stimoris_on*c(cont),stimoris_off*c(cont));
		l4resp=mean(reshape(layer4ONinput,length(phases),length(oris)))+mean(reshape(layer4OFFinput,length(phases),length(oris)));
		plot(oris,l4resp);
	end;
	if i==1, title(['Orientation tuning']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	[layer4ONinput,layer4OFFinput] = compute_layer4_input(ori,0,connmethod,stimsf_on,stimsf_off);
	l4resp=mean(reshape(layer4ONinput,length(phases),length(sfs)))+mean(reshape(layer4OFFinput,length(phases),length(sfs)));
	plot(sfs,l4resp);
	A = axis;
	axis([0 sfs(end) A(3) A(4)]);
	if i==1, title(['SF tuning']); end;
	subplot(4,5,plotinc); plotinc=plotinc+1;
	[layer4ONinput,layer4OFFinput] = compute_layer4_input(ori,0,connmethod,stimphase_on,stimphase_off);
	l4resp=(reshape(layer4ONinput,length(phases),1))+(reshape(layer4OFFinput,length(phases),1));
	plot(phases,l4resp);
	A = axis;
	axis([0 2*pi A(3) A(4)]);
	if i==1, title(['Phase']); end;
end;
