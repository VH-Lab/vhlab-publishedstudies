function [psame,pdiff,pdiffori,angori,Isame,Idiff,Idiffori] = dpuncertaintytot(dp, usethisangori)

if nargin==1,
    vec = 0;

    for i=1:length(dp),
        vec = vec + exp(sqrt(-1)*2*pi*mod(dp(i),180)/180);
    end;

    angori = mod(angle(vec)*180/(2*pi),180);

    J = find(angdiff(angori-dp')>90);
    I = find(angdiff(angori-dp')<=90);

    if length(J)>length(I), angori = angori + 180; end;
else, angori = usethisangori;
end;
    
Isame = find(angdiff(angori-dp')<=45);
Idiff = find(angdiff(angori-dp')>135);
Idiffori = find(angdiff(angori-dp')>45&angdiff(angori-dp')<=135);

psame = length(Isame)/length(dp);
pdiff = length(Idiff)/length(dp);
pdiffori = length(Idiffori)/length(dp);