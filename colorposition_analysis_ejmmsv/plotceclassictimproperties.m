function plotceclassicstimproperties(dorods)

if nargin==0, dr = 0; else, dr = dorods; end;

figure;

axl = [ 13];
thetitles = {'Color exch. classic'};

subplot(1,1,1);
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(1);
plot(abs(Lc),'g.-','linewidth',2); hold on;plot(abs(Sc),'b.-','linewidth',2);
axis([1 axl -0.5 0.5]);
if i==1, ylabel('Absolute cone contrast'); end;
title(thetitles{1});
if dr, plot(Rc,'r.-','linewidth',2); end;
hold on;
plot([-100 100],[0 0],'k-');


h0=plot(-1+abs(Lc-Sc),'k--','linewidth',2);
h1=plot(-1+abs(Lc+0*Sc),'g--','linewidth',2);
h2=plot(-1+abs(0*Lc+Sc),'b--','linewidth',2);

axis([1 10 -1 0.6]);

set(gca,'xtick',[1:10])
xlabel('Stimulus number')
set(gca,'ytick',[ 0 0.5])
