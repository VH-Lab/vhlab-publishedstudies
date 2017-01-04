function [lb] = localdirstrengthbias(dp,di,myxy,dpothers,diothers,xyothers, dists, dirorori, annuli)

lb = {};

if dirorori == 0, m = 2; else, m = 1; end;

lengths = sqrt((xyothers(:,1)-myxy(1)).^2 + (xyothers(:,2)-myxy(2)).^2);
for j=1:length(dists),
    if j==1, d0 = 0; else, d0 = dists(j-1); end;
    if ~annuli, d0 = 0; end;
    ind = find(lengths>d0&lengths<=dists(j)&~isnan(diothers(1,:)'));
    if length(ind)>=1,
        lb{j} = [];
        for k=1:length(dp),
            othervecs = diothers(k,ind).*exp(sqrt(-1)*dpothers(k,ind)*m*pi/180);
            myvec = di(k)*exp(sqrt(-1)*dp(k)*m*pi/180);
            mystrength = [real(myvec) imag(myvec)]*[real(othervecs)' imag(othervecs)']';
            lb{j}(k) = mean(mystrength);
        end;
    else, lb{j} = NaN;
    end;
end;
