function plotexampledaceyresponses

% plot Dacey example responses

[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(4);

Lc = Lc(1:12); Sc = Sc(1:12);

Op = (Sc-Lc)'; No = abs(Sc+Lc)';
Op = Op./max(Op); No=No./max(No);
S = abs(Sc)'; L = abs(Lc)'; S=S./max(S); L=L./max(L);

figure;
subplot(2,2,1);
plot(Op,'k.-');
axis square off;

subplot(2,2,2);
plot(No,'k.-');
axis square off;

subplot(2,2,3);
plot(S,'k.-');
axis square off;

subplot(2,2,4);
plot(L,'k.-');
axis square off;