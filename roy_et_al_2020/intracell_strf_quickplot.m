function h = intracell_strf_quickplot(x,y,isold)

if isold,
	c = [ 1 0 1];
else,
	c = [0 1 0];
end;

mn = nanmean(y);

h=bar(x,mn,0.5);
set(h,'facecolor',c);

hold on;

h2 = myerrorbar(x,mn,nanstderr(y),nanstderr(y));
set(h2,'color','k','linewidth',2);
delete(h2(2));

h(end+1,1) = h2(2);

h = cat(1,h,plot(x+0.5,y,'o','color',c));

box off;
