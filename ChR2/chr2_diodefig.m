
 % need to make jason's diode figure the current axes before running this

ch = get(gca,'children');

trial_lines =      -[ 0.433  0.434  ; 0.434 0.435;  0.435 0.436; 0.436 0.437; 0.437 0.438; 0.438 0.439];
vertical_refresh = -[ 0.4433 0.4436 ; 0.444 0.445 ; 0.445 0.446; 0.446 0.447; 0.447 0.448; 0.448 0.449];

for j=1:6,
	vrt{j} = [];
	stimtrigs{j} = [];
	diode_data = [];
	diode_t = [];

	for i=1:length(ch),
		yd=get(ch(i),'ydata');
		xd=get(ch(i),'xdata');

		if yd(1)<vertical_refresh(j,1) & yd(1)>= vertical_refresh(j,2),
			vrt{j}(end+1) = xd(1);
		elseif yd(1)<trial_lines(j,1) & yd(1)>=trial_lines(j,2),
			stimtrigs{j}(end+1) = xd(1);
		elseif length(yd)>100,
			diode_data(end+1,:) = yd;
			diode_t = xd;
		end;
	end;
	vrt{j} = sort(vrt{j});
	stimtrigs{j} = sort(stimtrigs{j});
end;


for i=1:6,
	diode_data(i,:) = diode_data(i,:)-mean(diode_data(i,:));
end;

diode_data_med = median(diode_data);
diode_data_mean = mean(diode_data);
dT = mean(diff(diode_t));

t_length = 1500;

diode_averages = [];

for j=1:6,
	for i=1:length(stimtrigs{j}),
		k = find(vrt{j}>stimtrigs{j}(i),1);
		[it0] = find(diode_t>vrt{j}(k),1);
		diode_averages(end+1,1:t_length) = diode_data(j,it0:it0+t_length-1);
	end;
end;

diode_avg_t = diode_t(1:t_length);

diode_med = median(diode_averages);

diode_med = -(diode_med-diode_med(1));
[b,a]=cheby1(4,0.2,40/(0.5*sr),'low');
diode_med_f = filtfilt(b,a,diode_med);

figure;
plot(diode_avg_t,diode_med);
xlabel('Time(s)');
ylabel('Signal');

box off;

