function plotdaceystimproperties(dorods)

if nargin==0, dr = 0; else, dr = dorods; end;

figure;
i1 = 1:12;
i2 = [15 16];
i3 = [13 14];
ix1 = 1:12;
ix2=13:14;
ix3=15:16;


axl = [ 13];
thetitles = {'Color exch. Dacey extended'};

subplot(1,1,1);
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(4);
Lc,Sc,
Lc(14) = abs(Lc(14)); Sc(14) = abs(Sc(14));
plot(ix1,Lc(i1),'gs-','linewidth',2);
hold on;plot(ix1,Sc(i1),'bo-','linewidth',2);
plot(ix2,Lc(i2),'gs-','linewidth',2);
hold on;plot(ix2,Sc(i2),'bo-','linewidth',2);
plot(ix3,Lc(i3),'gs','linewidth',2);
hold on;plot(ix3,Sc(i3),'bo','linewidth',2);
axis([1 axl -0.5 0.5]);
if i==1, ylabel('Relative cone contrast'); end;
title(thetitles{1});
if dr, plot(Rc,'r.-','linewidth',2); end;
hold on;
plot([-100 100],[0 0],'k-');


h0=plot(ix1,-1.2+0.8*abs(Lc(i1)-Sc(i1)),'k--','linewidth',2);
h1=plot(ix1,-1.2+abs(Lc(i1)+0.2*Sc(i1)),'g--','linewidth',2);
h2=plot(ix1,-1.2+abs(0.2*Lc(i1)+Sc(i1)),'b--','linewidth',2);
h0=plot(ix2,-1.2+0.8*abs(Lc(i2)-Sc(i2)),'k--','linewidth',2);
h1=plot(ix2,-1.2+abs(Lc(i2)+0.2*Sc(i2)),'g--','linewidth',2);
h2=plot(ix2,-1.2+abs(0.2*Lc(i2)+Sc(i2)),'b--','linewidth',2);
h0=plot(ix3,-1.2+0.8*abs(Lc(i3)-Sc(i3)),'kd','linewidth',2);
h1=plot(ix3,-1.2+abs(Lc(i3)+0.2*Sc(i3)),'gd','linewidth',2);
h2=plot(ix3,-1.2+abs(0.2*Lc(i3)+Sc(i3)),'bd','linewidth',2);

axis([0 17 -1.2 0.5]);

set(gca,'xtick',[1:16])
xlabel('Stimulus number')
set(gca,'ytick',[-0.5 0 0.5])

return;
plot((sign(Sc).*sign(Lc)).*(Sc-Lc),'k.-','linewidth',2);
hold on; plot([-100 100],[0 0],'k-');
axis([1 axl(i) -1 1]);
if i==1, ylabel('S-L phase'); end; 
xlabel('Stim number');
