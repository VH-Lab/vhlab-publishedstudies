function sl_dsiovertime(out, thetitle)
% SL_DSIOVERTIME - quick plot of DSI over time
% 
%  Not in a new figure

if isfield(out,'inhib_r_up'),
	numplots = 4;
else,
	numplots = 3;
end;

subplot(numplots,1,1);
dsi = (out.r_up - out.r_down)./(out.r_up + out.r_down);
plot(dsi,'k','linewidth',1.67);
A = axis;
axis([A([1 2]) -1 1]);
ylabel('DSI');
box off;
title(thetitle);

subplot(numplots,1,2);  
   % like paper figures -- red is up, green is down
plot(out.r_up,'r','linewidth',1.87);
hold on;
plot(out.r_down,'g','linewidth',1.87);
box off;
A = axis;
axis([A(1) A(2) 0 A(4)]);
ylabel('Spikes per bar');

[early,late] = sl_earlylate(sqrt(size(out.gmaxes,1)));
earlymatrix = zeros(sqrt(size(out.gmaxes,1)));
earlymatrix(early) = 1;
alt_early_matrix = earlymatrix(:,end:-1:1);
alt_early = find(alt_early_matrix(:));
g_early = out.gmaxes(early,:);
g_early_mean = mean(g_early,1);
g_altearly = out.gmaxes(alt_early,:);
g_altearly_mean = mean(g_altearly,1);
g_late = out.gmaxes(late,:);
g_late_mean = mean(g_late,1);

subplot(numplots,1,3);
plot(g_early_mean,'k','linewidth',1.6);
hold on;
plot(g_altearly_mean,'k--','linewidth',1.6);
ylabel('Gearly/altearly');
box off;
A = axis;
axis([A(1) A(2) 0 A(4)]);
if numplots==3, xlabel('Training iteration'); end;

if numplots==4,
	subplot(numplots,1,4);
	plot(out.ctx_inhib,'b-','linewidth',1.3);
	box off;
	ylabel('G_inhib');
	xlabel('Training iteration');
end;


