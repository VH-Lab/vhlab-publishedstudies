function intracell_strf_makebinmethods(binfig, filterfig, T, thresh, stimT, Tfine)

Tfine = [ 170 171];
T = [ 163 175];

stimT = [166.854    171.86335  ];
stimY = [0.025 0.025];
spike_bottom = 0;
spike_top = 0.01;

binwidth = 0.030;

ax = get(filterfig,'children');
ch = get(ax,'children');

fullvm_t = get(ch(2),'XData');
fullvm =   get(ch(2),'Ydata');

filtervm_t = get(ch(1),'XData');
filtervm =   get(ch(1),'Ydata');

spikeindex = threshold_crossings(fullvm,thresh);
spiketimes = fullvm_t(spikeindex);
spikevalues = 0*fullvm;
spikevalues(spikeindex) = 1;

ax = get(binfig,'children');

ch = get(ax,'children');

shifted_t = get(ch(1),'XData');
shifted = get(ch(1),'Ydata');

binned_t = T(1)-0.5*binwidth:binwidth:T(end)+0.5*binwidth;
[VYn,VTn] = slidingwindowfunc(shifted_t,shifted, binned_t(1), binwidth, binned_t(end), binwidth, 'mean' , 1);
[Cn,STn] = slidingwindowfunc(fullvm_t, spikevalues, binned_t(1), binwidth, binned_t(end), binwidth, 'sum', 1);

binned_steps = stepfunc( [binned_t(1:end-1)']', VYn(:)', shifted_t(:)', 0);
binned_fr = stepfunc( [binned_t(1:end-1)']', Cn(:)', shifted_t(:)', 0);

fig = figure;

subplot(2,3,1);

plot(fullvm_t,fullvm,'b');
hold on;
plot(stimT,stimY,'k-','linewidth',2);
axis([T(1) T(2) -0.09 0.03]);
box off;
title(['Raw data']);

t_range = find(fullvm_t<T(1) & fullvm_t>(T(1)-5));
ax_shift = prctile(fullvm(t_range),20);

subplot(2,3,2);

plot(shifted_t,shifted,'b');
hold on;
plot([spiketimes(:) spiketimes(:)],[spike_bottom spike_top]-ax_shift,'k-');
plot(stimT,stimY-ax_shift,'k-','linewidth',2);
title(['Filtered']);

axis([T(1) T(2) -ax_shift+[-0.09 0.03]]);
box off; 

subplot(2,3,3);

plot(shifted_t,binned_steps);
hold on;
plot(stimT,stimY-ax_shift,'k-','linewidth',2);
plot(shifted_t,binned_fr/200+spike_bottom-ax_shift,'k-');

axis([T(1) T(2) -ax_shift+[-0.09 0.03]]);
box off; 
title(['Binned']);

subplot(2,3,5);

plot(shifted_t,shifted,'b');
hold on;
plot([spiketimes(:) spiketimes(:)],[spike_bottom spike_top]-ax_shift,'k-');
plot(stimT,stimY-ax_shift,'k-','linewidth',2);

axis([Tfine(1) Tfine(2) -ax_shift+[-0.09 0.03]]);
box off; 
title(['Filtered, fine']);


subplot(2,3,6);

plot(shifted_t,binned_steps);
hold on;
plot(stimT,stimY-ax_shift,'k-','linewidth',2);
plot(shifted_t,binned_fr/200+spike_bottom-ax_shift,'k-');

axis([Tfine(1) Tfine(2) -ax_shift+[-0.09 0.03]]);
box off; 
title(['Binned, fine']);

set(fig,'tag','Vm_vs_Fr methods figure');


