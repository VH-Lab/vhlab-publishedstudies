
ds = dirstruct(tpf);

gf=figure;


axes('position',[0.04 0.5+0.1 0.38 0.38],'box','off');
%im = previewprairieview([tpf '/t00005'],50,1,1);
im = previewprairieview([tpf '/t00001'],50,1,1);
image(rescale(im,[min(min(im)) max(max(im))],[0 1000]));
colormap(gray(1000));
set(gca,'xtick',[],'ytick',[]);

mycellplot=axes('position',[0.05+0.38+0.025 0.5+0.1 0.38 0.38],'box','off');
DB = load(getexperimentfile(ds),'cell_tp_00*','-mat');
cellnames = fieldnames(DB); clear newcell;
for i=1:length(cellnames), newcell{i}=getfield(DB,cellnames{i}); end;
symb = [];
cols = [];
myprob = [];
for i=1:length(cellnames),
	dias=findassociate(newcell{i},'OT Direction index','','');
	if ~isempty(dias),
		symb(i) = 1 + (dias.data>0.5);
		if (dias.data>0.5), cols(i,:) = [-1 -1 -1];
		else, cols(i,:) = [ 0.7 0.7 0.7];
		end;
	else, symb(i) = 0; cols(i,:) = [ -1 -1 -1];
	end;
	myprob(i) = 0;
	probassoc = findassociate(newcell{i},'OT varies p','','');
	if ~isempty(probassoc),
		if probassoc.data<0.05, myprob(i) = 1; end;
	end;
	cellloc{i} = findassociate(newcell{i},'pixellocs','','');
end;

im = pvcontinuousmap([512 512],1,newcell,cellnames,'OT Fit Pref','',1:359,1,'pvalueassoc','OT visual response p','pvalue',0.05,'symbol',symb,'symbolsize',12,'color',cols);
nf = gcf;
scalebar = gca;
set(gca,'parent',gf,'position',[0.94 0.5+0.1 0.04 0.38]);
axes(scalebar); ylabel('Direction of motion (\circ)');
close(nf);
figure(gf);
axes(mycellplot);
image(im); set(gca,'xtick',[],'ytick',[]);

mydircells = find(myprob&symb>1);
myotcells = find(myprob&symb==1);


if 0,
 % dir select:  211, 210*,304*  (corresponds to 9, 10)
 % ot select: 229*, 245, 215, 91, 
for i=1:length(mydircells),
	figure;
	plototresponse(newcell{mydircells(i)},1,1);
	title(cellnames{mydircells(i)},'interp','none');
end;
for i=1:length(myotcells),
	figure;
	plototresponse(newcell{myotcells(i)},1,1);
	title(cellnames{myotcells(i)},'interp','none');
end;
end; % if 0

axl{1} = [0.12 0.35 0.20 0.18];
axl{3} = [0.12 0.1 0.20 0.18];
axl{2} = [0.12+0.20+0.05 0.35 0.20 0.18];
axl{4} = [0.12+0.20+0.05 0.1 0.20 0.18];
axl{5} = [0.12+2*0.20+0.2 0.35 0.20 0.18];
axl{6} = [0.12+2*0.20+0.2 0.1 0.20 0.18];
CLS = [ mydircells(10) mydircells(9) myotcells(18) myotcells(20)];

for i=1:4,
	axes('position',axl{i});
	plototresponse(newcell{CLS(i)},1,1);
	axis([-1 360 -0.03 0.2]);
	if i==2|i==4, set(gca,'ytick',[]); else, ylabel('\DeltaF/F'); end;
	if i==1|i==2, set(gca,'xtick',[]); else, xlabel('Direction (\circ)'); end;
	title([int2str(i)]);
	axes(mycellplot);
	%text(mean(cellloc{CLS(i)}.data.x),mean(cellloc{CLS(i)}.data.y),int2str(i),...
	%	'horizontalalignment','center','color',[1 1 1],'fontsize',12,'fontweight','bold');
end;

 % shift of 0.5 is to correct for bin widths
load timecourses -mat;
axes('position',axl{5});
plot(timecourse2_x-0.5,timecourse2_y,'--','color',[0.7 0.7 0.7]);
hold on;
plot(timecourse2_xd-0.5,timecourse2_yd,'k-');
set(gca,'box','off');
axis([-4 8 -0.03 0.2]);
title('2'); set(gca,'xtick',[]);

axes('position',axl{6});
plot(timecourse3_x-0.5,timecourse3_y,'--','color',[0.7 0.7 0.7]);
hold on;
plot(timecourse3_xd-0.5,timecourse3_yd,'k-');
set(gca,'box','off');
axis([-4 8 -0.03 0.2]);
title('3');xlabel('Time(s)');

vals = [ '2357'];
for k=8:1:4,
subplot(2,3,2+k);
DB = load(getexperimentfile(ds),['cell_tp_00' vals(k) '*'],'-mat'),
cellnames = fieldnames(DB); clear newcell; clear symb;
for i=1:length(cellnames), newcell{i}=getfield(DB,cellnames{i}); end;
symb = [];
for i=1:length(cellnames),
	dias=findassociate(newcell{i},'OT Direction index','','');
	if ~isempty(dias),
		symb(i) = 1 + (dias.data>0.5);
	else, symb(i) = 0;
	end;
end;

im = pvcontinuousmap([tpf '/t0000' vals(k)],1,newcell,cellnames,'OT Fit Pref','',1:359,0,'pvalueassoc','OT varies p','pvalue',0.05,'symbol',symb,'symbolsize',12);
image(im);
end; % k


set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
