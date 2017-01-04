function chr2_overallchangeDI(vars, output,cells,cellnames,experids)

if nargin==0, % it is a buttondownfcn,

	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

	[i,v]=findclosest(sqrt(sum(((repmat(pt,size(ud.di_signed,2),1)-[ud.t(:) ud.di_signed(:)]).^2)')),0);

	cellindex = ud.indexlookup(i);
	ud.testnumberlookup(i),

	disp(['Closest point = ' mat2str([ud.t(i) ud.di_signed(i)],2) ', found cell ' ud.cellnames{cellindex}]);

	chr2_plotdirectiongratingresponses(ud.cells{cellindex},ud.cellnames{cellindex});

	return;
end;

struct2var(vars);

figure;
inds_withgrain = find(di_init>=0);
inds_againstgrain = find(di_init<0);

plot(t(inds_withgrain),di_unsigned(inds_withgrain),'ko');
hold on;
plot(t(inds_againstgrain),di_unsigned(inds_againstgrain),'kv');
xlabel('Time since first record');
ylabel('Change in raw DI');

[yn,xn] = slidingwindowfunc(t,di_unsigned,0,0.5,10,3,'nanmedian',0);
plot(xn,yn,'k-','linewidth',2);

if 0,
	goodinds = find(~isnan(di_unsigned)&t>0);
	[slope,offset,slope_conf]=quickregression(t(goodinds)',di_unsigned(goodinds)',0.05),
	hold on;
	plot([0 10],offset+slope*[0 10],'k--');
end;

box off;

ud.output = output;
ud.cells = cells;
ud.cellnames=cellnames;
ud.experids = experids;
ud.dr = dr;
ud.di_signed = di_signed;
ud.t = t;
ud.indexlookup = indexlookup;
ud.testnumberlookup = testnumberlookup;
ud.di_init = di_init;
ud.di_unsigned = di_unsigned;

set(gcf,'userdata',ud);
set(gca,'buttondownfcn','chr2_changesignedDIvstime');
