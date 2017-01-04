function b = isgooddaceyexpanded(cell)

b = 0;

p = findassociate(cell,'TP CEDE visual response p','','');
bl=findassociate(cell,'TP CEDE Blank Response','','');
res = findassociate(cell,'TP CEDE Response struct','','');

if ~isempty(p)&p.data<0.05&~isempty(res),
    for i=1:length(res.data.ind),
        dpoints = res.data.ind{i};
        dpoints = dpoints(find(~isnan(dpoints)));
        if isnan(bl.data(1)), bl.data(1) = 0; end;
        h = ttest(dpoints,bl.data(1),0.05/length(res.data.ind),'right');
        if isnan(h), h = 0; end;
        if h, b = b+0.5; end;
    end;
end;

if b>1, b = 1; else, b= 0; end;