function chr2_changeXvstime(vars,quantity,yaxislabel,output,cells,cellnames,experids, slidepast0, withagainstgraindifferent)

if nargin==0, % it is a buttondownfcn,

	ud = get(gcf,'userdata');
	[i,v]=findclosestpointclick([ud.t(:) ud.X(:)]);

	cellindex = ud.indexlookup(i);
	ud.testnumberlookup(i),

	disp(['Closest point = ' mat2str([ud.t(i) ud.X(i)],2) ', found cell ' ud.cellnames{cellindex}]);

	chr2_plotdirectiongratingresponses(ud.cells{cellindex},ud.cellnames{cellindex});

	return;
end;

if nargin<8,
	slidepast0 = 0;
end;

if nargin<9,
	withagainstgraindifferent = 1; % use different symbols for with and against grain
end;

t = getfield(vars,'t');
X = getfield(vars,quantity);

figure;
inds_withgrain = find(vars.di_signed_init>=0);
inds_againstgrain = find(vars.di_signed_init<0);
inds_hasgrain = find(~isnan(vars.di_signed_init));
inds_nograin = find(isnan(vars.di_signed_init));

inds_nostim = find(vars.trainingstimid==3);
inds_conststim = find(vars.trainingstimid==2);

if isempty(inds_withgrain) & isempty(inds_againstgrain),
	inds_withgrain = 1:length(vars.di_signed_init);
end;

if withagainstgraindifferent,
	againstgrainsymbol = 'v';
else,
	againstgrainsymbol = 'o';
end;

plot(t(inds_withgrain),X(inds_withgrain),'ko');
hold on;
plot(t(inds_againstgrain),X(inds_againstgrain),['k' againstgrainsymbol]);
plot(t(inds_conststim),X(inds_conststim),'bd');
plot(t(inds_nostim),X(inds_nostim),'gs');
xlabel('Time since first record');
ylabel(yaxislabel);

if slidepast0,
	start = -1;
else,
	start = 0;
end;

[yn,xn] = slidingwindowfunc(t(inds_hasgrain),X(inds_hasgrain),start,0.5,max(t)+3,3,'nanmedian',0);
plot(xn,yn,'k-','linewidth',2);
[slope,offset,slope_conf_interval, resid, residint, stats]=quickregression(t(inds_hasgrain)', X(inds_hasgrain)',0.05/3); % 3 is bonferroni, 3 groups 
slope_p = quickregressionpvalue(t(inds_hasgrain)', X(inds_hasgrain)');
slope_n = length(unique(vars.indexlookup(inds_hasgrain)));
plot([0 10],slope*[0 10]+offset,'k-','linewidth',2.1);

[yn2,xn2] = slidingwindowfunc(t(inds_conststim),X(inds_conststim),start,0.5,max(t)+3,3,'nanmedian',0);
plot(xn2,yn2,'b-','linewidth',2);
[slope2,offset2,slope2_conf_interval, resid2, residint2, stats2]=quickregression(t(inds_conststim)', X(inds_conststim)',0.05/3); % 3 is bonferroni
slope_p2 = quickregressionpvalue(t(inds_conststim)', X(inds_conststim)');
slope_n2 = length(unique(vars.indexlookup(inds_conststim)));
plot([0 10],slope2*[0 10]+offset2,'b-','linewidth',2.1);

[yn3,xn3] = slidingwindowfunc(t(inds_nostim),X(inds_nostim),start,0.5,max(t)+3,3,'nanmedian',0);
plot(xn3,yn3,'g-','linewidth',2);
[slope3,offset3,slope3_conf_interval, resid3, residint3, stats3]=quickregression(t(inds_nostim)', X(inds_nostim)',0.05/3); % 3 is bonferroni
slope_p3 = quickregressionpvalue(t(inds_nostim)', X(inds_nostim)');
slope_n3 = length(unique(vars.indexlookup(inds_nostim)));
plot([0 10],slope3*[0 10]+offset2,'g-','linewidth',2.1);

box off;

ud.output = output;
ud.cells = cells;
ud.cellnames=cellnames;
ud.experids = experids;
ud.t = t;
ud.X = X;
ud.indexlookup = vars.indexlookup;
ud.testnumberlookup = vars.testnumberlookup;
ud.slope1 = var2struct('slope','offset','slope_conf_interval','stats','slope_p','slope_n');
ud.slope2 = var2struct('slope2','offset2','slope2_conf_interval','stats2','slope_p2','slope_n2');
ud.slope3 = var2struct('slope3','offset3','slope3_conf_interval','stats3','slope_p3','slope_n3');

set(gcf,'userdata',ud);
set(gca,'buttondownfcn','chr2_changeXvstime');
