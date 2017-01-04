function osihistogram(cells)

cla;

cvs{1} = [];
cvs{2} = [];

bins = [ -Inf 0:0.1:1 Inf];


for i=1:length(cells),
    [f1f0,ori,oi,tw,cv] = f1f0ratio(cells{i});
    rd = tsrelative_depth(cells{i})/1000;
    if ~isempty(rd)&~isempty(f1f0),
        hold on;
        oi = rescale(oi,[0 1],[0 1]);
        f1f0 = 2*rescale(f1f0,[0 1],[0 1]);
        if oi>0.6, oiv = 0.15; oiw=0.03; elseif oi<.3, oiv = 0; oiw=0.03; else, oiv = 0.3; oiw=0.06; end;
        h=plotoribox(f1f0,rd,ori,oiw,0.03+0.15*oi,1,'k-');
    end;
end;

set(gca,'ydir','reverse'); axis equal; axis([0 2 0 2]); box off;
plot([0 2],[950 950]/1000,'k--');
plot([0 2],[1350 1350]/1000,'k--');

