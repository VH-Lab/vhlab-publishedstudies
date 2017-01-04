function svnrsa_plots(cells,cellnames)

inds = [ 39 11 38 32];
titles = {'Cell 1','Cell 2','Cell 3','Cell 4'};
figure;

for i=1:4,

subplot(2,4,i); 
plottpresponse(cells{inds(i)},cellnames{inds(i)},'OT Fit Pref 2 Peak',1,1);
if i~=1, ylabel(''); set(gca,'yticklabel',[]); end;
ch = get(gca,'children');
for j=1:length(ch),
	set(ch(j),'linewidth',1);
end;
xlabel('direction (\circ)'); 
title(titles{i});
A=axis; axis([0 180 -0.02 0.13]);
set(gca,'xtick',[0 90 180]);
set(gca,'linewidth',1);
subplot(2,4,i+4); 
plottpresponse(cells{inds(i)},cellnames{inds(i)},'POS Fit Pref',1,1);
ch = get(gca,'children');
for j=1:length(ch),
	xd = get(ch(j),'xdata'); xd = xd / 18; set(ch(j),'xdata',xd);
	set(ch(j),'linewidth',1);
end;
A=axis; axis([10 20 -0.02 0.13]);
if i~=1, ylabel(''); set(gca,'yticklabel',[]);end;
title('');
xlabel('position (\circ)');
set(gca,'linewidth',1);
end;

try, delete(findobj(gcf,'style','pushbutton')); end;
