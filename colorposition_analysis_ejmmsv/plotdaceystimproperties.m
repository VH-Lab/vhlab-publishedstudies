function plotdaceystimproperties(dorods)

if nargin==0, dr = 0; else, dr = dorods; end;

figure;

axl = [ 13];
thetitles = {'Color exch. Dacey-like'};

subplot(1,1,1);
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(3);
plot(Lc,'g.-','linewidth',2); hold on;plot(Sc,'b.-','linewidth',2);
axis([1 axl -0.5 0.5]);
if i==1, ylabel('Relative cone contrast'); end;
title(thetitles{1});
if dr, plot(Rc,'r.-','linewidth',2); end;
hold on;
plot([-100 100],[0 0],'k-');


h0=plot(-1.2+0.8*abs(Lc-Sc),'k--','linewidth',2);
h1=plot(-1.2+abs(Lc+0.2*Sc),'g--','linewidth',2);
h2=plot(-1.2+abs(0.2*Lc+Sc),'b--','linewidth',2);

axis([1 13 -1.2 0.5]);

set(gca,'xtick',[1:13])
xlabel('Stimulus number')
set(gca,'ytick',[-0.5 0 0.5])

return;
plot((sign(Sc).*sign(Lc)).*(Sc-Lc),'k.-','linewidth',2);
hold on; plot([-100 100],[0 0],'k-');
axis([1 axl(i) -1 1]);
if i==1, ylabel('S-L phase'); end; 
xlabel('Stim number');
