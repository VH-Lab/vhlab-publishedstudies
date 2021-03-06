function plot_sl_simulated(r_up,r_down);

fig = figure;

cols = [''];
		r_up2 = r_up;
		r_down2 = r_down;
		z = find(r_up<r_down);
		r_up(z) = r_down2(z);
		r_down(z) = r_up2(z);
		di = (r_up-r_down)./(r_up);
		dsi = (r_up-r_down)./(r_up+r_down);
		figure(fig);
		subplot(2,2,1);
		plot(r_down,r_up,'mo');
		hold on;
		box off;
		ylabel('R_{up} (Spikes)');
		xlabel('R_{down} (Spikes)');
		axis([0 100 0 100]);
		subplot(2,2,2);
		plot(r_down,di,'mo');
		hold on;
		box off;
		ylabel('DI');
		xlabel('R_{down} (Spikes)');
		axis([0 100 0 1]);
		subplot(2,2,3);
		plot(r_down,dsi,'mo');
		hold on;
		box off;
		axis([0 100 0 1]);
		ylabel('DSI');
		xlabel('R_{down} (Spikes)');
		subplot(2,2,4);
		plot(r_down,dsi,'mo');
		hold on;
		box off;
		ylabel('DSI');
		xlabel('R_{down} (Spikes)');
		axis([0 20 0 1]);

