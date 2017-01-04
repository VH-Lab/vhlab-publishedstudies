function plot_sl_random_sims(dirname);

d = dir([dirname filesep '*.mat']);

fig = figure;

cols = [''];

for i=1:length(d),
	g = load([dirname filesep d(i).name]);
	if isfield(g,'out'),
		out = g.out;
		z = find(out.r_up<out.r_down);
		r_up = out.r_up;
		r_down = out.r_down;
		r_up(z) = out.r_down(z);
		r_down(z) = out.r_up(z);
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
	end;
end;

