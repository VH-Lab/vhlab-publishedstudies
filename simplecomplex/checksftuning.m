function checksftuning


X = -30:0.1:30;

for J = 0.0788

Ye = 0.6105*exp(-X.^2/0.5869);
Yi =  -J*exp(-X.^2/2.6776);
sum(Ye+Yi),
phases = 0:pi/6:2*pi-pi/6;
SF = [0.025 0.05 0.1 0.2 0.4 0.8 ];

for i=1:length(SF),
	ONe(i) = 0; OFFe(i) = 0;
	ONi(i) = 0; OFFi(i) = 0;
	for p=1:length(phases),
		ONe(i) = ONe(i)+sum(((Ye.*40.*rectify(cos(phases(p)+2*pi*SF(i)*X)))));
		ONi(i) = ONi(i)+sum(((Yi.*40.*rectify(cos(phases(p)+2*pi*SF(i)*X)))));
		OFFi(i) = OFFi(i)+sum((Yi.*40.*rectify(cos(pi+phases(p)+2*pi*SF(i)*X))));
		OFFe(i) = OFFe(i)+sum((Ye.*40.*rectify(cos(pi+phases(p)+2*pi*SF(i)*X))));
	end;
end;

hold on;
%plot(SF,ONe,'r');
%plot(SF,ONi,'r');
plot(SF,ONe+ONi+OFFe+OFFi,'g');
hold on;

end;
%hold on
%plot(SF,ON,'r');
%plot(SF,OFF,'g');

