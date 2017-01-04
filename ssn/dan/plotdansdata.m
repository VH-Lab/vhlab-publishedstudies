function plotdansdata(DataStructure)

% minimal help -- DataStructure has fields F0_Results, F0_ResultsSE, etc

fig=figure;

for i=1:length(DataStructure.F0_Results),
	supersubplot(fig,4,3,i);
	h=errorbar(1:length(DataStructure.F0_Results{i}),...
		DataStructure.F0_Results{i},...
		DataStructure.F0_ResultsSE{i},DataStructure.F0_ResultsSE{i},...
		'b-o');
	set(h,'markersize',3);
	hold on;
	h2=errorbar(1:length(DataStructure.F0_Results{i}),...
		DataStructure.F1_Results{i},...
		DataStructure.F1_ResultsSE{i},DataStructure.F1_ResultsSE{i},...
		'r-o');
	set(h2,'markersize',3);
	A = axis;
	axis([0 1+length(DataStructure.F0_Results{i}) A(3) A(4)]);

	if mod(i,3)==1,
		ylabel('Hz');
	end;
	if any(mod(i,4*3)==[9 10 11 0]),
		xlabel('Position');
	end;
	box off;
end;

windows = get(0,'children');

for w=1:length(windows),
	set(windows(w),'PaperPosition',[0.25 1.5 8 9]);
	saveas(windows(w),['fig' int2str(w) '.fig']);
	print(windows(w),'-depsc', ['fig' int2str(w) '.eps']);
	print(windows(w),'-dpdf',  ['fig' int2str(w) '.pdf']);
end;
