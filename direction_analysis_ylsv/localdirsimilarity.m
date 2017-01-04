function [lb] = localdirsimilarity(dp,myxy,dpothers,xyothers,dists, dirorori, annuli)

lb = {};

lengths = sqrt((xyothers(:,1)-myxy(1)).^2 + (xyothers(:,2)-myxy(2)).^2);

if dirorori==0, base = 180; else, base = 360; end;

for j=1:length(dists),
    if j==1, d0 = 0; else, d0 = dists(j-1); end;
    if ~annuli, d0 = 0; end;
    ind = find(lengths>d0&lengths<=dists(j));
    lb{j} = [];
    if length(ind)>=1,
        for k=1:length(dp),
            mydiff = angdiffwrap(dp(k)'-dpothers(k,ind),base);
            lb{j}(k) = (length(find(mydiff<45))-0*length(find(mydiff>(90+45))))/(length(ind)-sum(isnan(mydiff)));
        end;
    else, lb{j}=NaN;
    end;
end;
