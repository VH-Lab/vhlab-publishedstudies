
sigv = [];

for j=1:1000,
    Z = randn(100,2);
    m = [max(Z')' min(Z')'];
    p1 = prctile(m(:,1),[5 95]);
    p2 = prctile(m(:,2),[5 95]);
    sigv(j) = all(p1>0)|all(p1<0)|all(p2<0)|all(p2>0);
end;
    