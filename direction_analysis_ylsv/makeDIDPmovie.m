function M = makeDIDPmovie(DPb,DPa,DIb,DIa,steps,multicolor,tickangle)

colors = ['k' 'b' 'r' 'y' 'g' 'm'];

allpts = 1:length(DPb);

if multicolor,
	for i=1:length(colors),
		start = round((i-1)*length(DPb)/length(colors))+1;
		stop = round((i)*length(DPb)/length(colors));
		if i==length(colors), stop = length(allpts); end;
		grp{i} = allpts(start:stop);
	end;
	% checking
	mylist = [];
	for i=1:length(colors),
		mylist = [ mylist grp{i} ];
	end;
	if ~eqlen(mylist,allpts), keyboard; error(['List is not perfect.']); end;
else, grp{1} = allpts;
end;

[Xb,Yb] = pol2cart(DPb*pi/180,DIb);
[Xa,Ya] = pol2cart(DPa*pi/180,DIa);
myb = Xb + sqrt(-1)*Yb;
mya = Xa + sqrt(-1)*Ya;

figure; set(gcf,'color',[0 0 0]);
for i=0:steps,
	clf;
	%h=polar(0,1);set(gca,'fontsize',16,'fontweight','bold');
	%hold on;
	mypts = (1-i/steps)*myb+(i/steps)*mya;
	for j=1:length(grp),
		h=mmpolar(angle(mypts(grp{j})),abs(mypts(grp{j})),[colors(j), '.'], ...
			'backgroundcolor',[0 0 0],'TGridColor',[1 1 1],...
			'TBorderColor',[1 1 1],'RGridColor',[1 1 1],...
			'fontsize',16,'fontweight','bold','TTickDelta',30,...
			'RLimit',[0 1.1],'RTickValue',[0.2:0.2:1],'style','compass','RTickAngle',tickangle);
		set(h,'markersize',20);
		hold on;
		%polar(angle(mypts(grp{j})),abs(mypts(grp{j})),[colors(j) '.']);
	end;
	set(gcf,'color',[0 0 0]);
	%delete(h);
	if i==0, M = getframe(gca); else, M(end+1) = getframe(gca); end;
end;

close;
