function [x,y,shape,inds]=plotcolorori(cells)

cla;
inds = [];
x = []; y = []; shape = [];
for i=1:length(cells),
    [f1f0,ori,oi,tunewidth,cv] = f1f0ratio(cells{i});
    SconeFrac = tsdaceyexpcolor(cells{i});
    rd = tsrelative_depth(cells{i})/1000;
    if ~isempty(rd)&~isempty(SconeFrac),
        inds(end+1) = i;
        hold on;
        oi = rescale(oi,[0 1],[0 1]);
        f1f0 = 2*rescale(f1f0,[0 1],[0 1]);
        if oi>0.6, oiv = 0.15; oiw=0.03; elseif oi<.3, oiv = 0; oiw=0.03; else, oiv = 0.3; oiw=0.06; end;
        xval = (SconeFrac);
        if xval<0, str='b-'; else, str='r-'; end;
        h=plotoribox(abs(xval),rd,ori,oiw,0.03+0.15*oi,1,str);
        if xval<0,set(h,'color',[0.2 .2 .2]); end;
        x(end+1) = xval; y(end+1) = rd; shape(end+1)=ori;
    end;
end;

set(gca,'ydir','reverse'); axis equal; axis([0 2 0 2]); box off;
plot([0 2],[950 950]/1000,'k--');
plot([0 2],[1350 1350]/1000,'k--');
