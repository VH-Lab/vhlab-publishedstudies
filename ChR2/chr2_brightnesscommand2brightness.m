
% assume current axes has brightness data

for i=1:4, Yd(i,:) = get(ch(i),'ydata'); end;
Xd = get(ch(1),'xdata');

peaks = max(Yd')';

Yd_n = Yd./(repmat(peaks,1,size(Yd,2)));

colors = ['ckck'];
linecode = {'-','-','--','--'};

figure;
hold on;
for i=1:4,
	plot(Xd,Yd_n(i,:),[colors(i) linecode{i}]);
end;
box off;
xlabel('Brightness command');
ylabel('Observed normalized brightness');

system_brightness = mean(Yd_n(3:4,:));

command_brightness = 0:0.01:1;

actual_brightness = interp1(Xd,system_brightness,command_brightness,'linear');

commands_issued = 0:0.1:1;
brightness_received = [];

indexes = [];
for i=1:length(commands_issued),
	indexes(i) = findclosest(command_brightness,commands_issued(i));
	brightness_received(i) = actual_brightness(indexes(i));
end;

[commands_issued; brightness_received]

 % find where 0 and 1 are on the Illustrator plots
plot_orig_x = [ 41.842 146.373];  % left graph
plot_orig_x = [ 166.694 292.134]; % right graph
plot_orig_x = [ 316.801 421.321]; % far right control graph

gain = diff(plot_orig_x);

graph_pos = plot_orig_x(1) + gain * brightness_received

