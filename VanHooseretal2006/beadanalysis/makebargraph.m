

vals = [ -0.1115 0.1910 0.6 1.3];

figure(5);
h=bar([1 2 3 4],vals);
set(h,'facecolor',[0 0 0]);

set(gca,'fontsize',16,'fontweight','bold');
ylabel('Cluster index','fontsize',16,'fontweight','bold');
set(gca,'xticklabel',[],'linewidth',2,'box','off');

A(1)=text(1,-0.3,'Squirrel','fontsize',16,'fontweight','bold');
A(2)=text(2,-0.3,{'Tree' 'shrew'},'fontsize',16,'fontweight','bold');
A(3)=text(3,-0.3,{'P24' 'ferret'},'fontsize',16,'fontweight','bold');
A(4)=text(4,-0.3,{'Adult' 'ferret'},'fontsize',16,'fontweight','bold');

for i=1:4, set(A(i),'horizontalalignment','center'); end;
