function chr2_changeXvstime(vars,quantity,yaxislabel,output,cells,cellnames,experids, slidepast0, withagainstgraindifferent, low)

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

if low,
	inds_withgrain = find(vars.di_signed_init>=0 & vars.di_signed_init<=0.5);
	inds_againstgrain = find(vars.di_signed_init<0 & vars.di_signed_init>=-0.5);
	inds_hasgrain = find(~isnan(vars.di_signed_init) & abs(vars.di_signed_init)<=0.5);

	inds_nostim = find(vars.trainingstimid==3 & abs(vars.di_esigned_init)<=0.5);
	inds_conststim = find(vars.trainingstimid==2 & abs(vars.di_esigned_init)<=0.5);
else,
	inds_withgrain = find(vars.di_signed_init>=0 & vars.di_signed_init>0.5);
	inds_againstgrain = find(vars.di_signed_init<0 & vars.di_signed_init<-0.5);
	inds_hasgrain = find(~isnan(vars.di_signed_init) & abs(vars.di_signed_init)>0.5);

	inds_nostim = find(vars.trainingstimid==3 & abs(vars.di_esigned_init)>0.5);
	inds_conststim = find(vars.trainingstimid==2 & abs(vars.di_esigned_init)>0.5);
end;

if isempty(inds_withgrain) & isempty(inds_againstgrain),
	inds_withgrain = 1:length(vars.di_signed_init);
end;

if withagainstgraindifferent,
	againstgrainsymbol = 'v';
else,
	againstgrainsymbol = 'o';
end;


 % now plot

cellindexes = unique(vars.indexlookup(inds_hasgrain));
for i=1:length(cellindexes),
	myinds = find(vars.indexlookup(inds_hasgrain)==cellindexes(i));
	mynonnans = find(~isnan(X(inds_hasgrain(myinds))));
	if length(mynonnans)>1,
		plot(t(inds_hasgrain(myinds(mynonnans))),X(inds_hasgrain(myinds(mynonnans))),...
			'r-o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',12,'linewidth',2);
	end;
	hold on;
end;

cellindexes = unique(vars.indexlookup(inds_conststim));
for i=1:length(cellindexes),
	myinds = find(vars.indexlookup(inds_conststim)==cellindexes(i));
	mynonnans = find(~isnan(X(inds_conststim(myinds))));
	if length(mynonnans)>1,
		plot(t(inds_conststim(myinds(mynonnans))),X(inds_conststim(myinds(mynonnans))),...
			'g-d','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',12,'linewidth',1);
	end;
end;

set(gca,'linewidth',1);

xlabel('Time since first record');
ylabel(yaxislabel);

if slidepast0,
	start = -1;
else,
	start = 0;
end;

box off;

ud.output = output;
ud.cells = cells;
ud.cellnames=cellnames;
ud.experids = experids;
ud.t = t;
ud.X = X;
ud.indexlookup = vars.indexlookup;
ud.testnumberlookup = vars.testnumberlookup;

set(gcf,'userdata',ud);
set(gca,'buttondownfcn','chr2_changeXvstime');


