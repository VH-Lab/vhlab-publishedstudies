function intracell_strf_summary_plotspikephase(spikeshape_struct)


Y = find([spikeshape_struct.young]);
O = find(~[spikeshape_struct.young]);

f = figure;
wvf = figure;

col = [1 0 1];

t_master = vlt.data.colvec(-0.003:0.0001:0.003);

spikeshapes{1} = []; % young
spikeshapes{2} = []; %old

for i=1:1:numel(O),
	figure(f);
	t = spikeshape_struct(O(i)).spike_summary.sample_times(11:end-10);
	dt = diff(spikeshape_struct(O(i)).spike_summary.sample_times(1:2));
	v = vlt.data.colvec(spikeshape_struct(O(i)).spike_summary.mean_spikewave(11:end-10));
	if max(v)<0.04, continue; end;
	if spikeshape_struct(O(i)).spike_summary.number_of_spikes<=15, continue; end;
	v_dot = gradient(v',dt);
	spikeshapes{2}(:,end+1) = interp1(t, v, t_master,'linear');
	plot(v,v_dot,'color',col,'linewidth',1.033);
	hold on;
	ylabel('Volts/sec (V/s)');
	xlabel('Volts (V)');
	box off;
	figure(wvf);
	plot(t,v,'color',col);
	hold on;
	box off;
end


col = [0 1 0];

for i=1:1:numel(Y),
	figure(f);
	t = spikeshape_struct(Y(i)).spike_summary.sample_times(11:end-10);
	dt = diff(spikeshape_struct(Y(i)).spike_summary.sample_times(1:2));
	v = vlt.data.colvec(spikeshape_struct(Y(i)).spike_summary.mean_spikewave(11:end-10));
	if max(v)<0.04, continue; end;
	if spikeshape_struct(Y(i)).spike_summary.number_of_spikes<=15, continue; end;
	v_dot = gradient(v',dt);
	spikeshapes{1}(:,end+1) = interp1(t, v, t_master,'linear');
	plot(v,v_dot,'color',col,'linewidth',1.033);
	hold on;
	ylabel('Volts/sec (V/s)');
	xlabel('Volts (V)');
	box off;
	figure(wvf);
	plot(t,v,'color',col);
	hold on;
	box off;
end

figure;
plot(t_master,mean(spikeshapes{1},2),'color',[0 1 0],'linewidth',2.001);
hold on;
plot(t_master,mean(spikeshapes{2},2),'color',1-[0 1 0],'linewidth',2.001);
