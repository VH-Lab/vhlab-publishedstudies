function plotNewDI_vs_OldDI(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

hist_bins = [ -Inf -49:50:501 Inf]; hist_xaxis = [0 (0:50:500-50)+50/2];

DInew = {};
DIold = {};

OInew = {};
OIold = {};

flip = {};



for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
    [cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');
	if i==1,
	DInew{i} = []; DIold{i} = [];
	OInew{i} = []; OIold{i} = [];
	flip{i} = [];
	end;
	i = 1;
    for j=1:length(cells),
		p=findassociate(cells{j},'OT vec varies p','','');
		pr = findassociate(cells{j},'Recovery OT vec varies p','','');
		if ~isempty(p)&~isempty(pr),
			if p.data<0.05&pr.data<0.05,
				DInew{i}(end+1) = newferretdi(cells{j},0);
				fitp = findassociate(cells{j},'OT Carandini Fit Params','','');
				DIold{i}(end+1) = (fitp.data(2) - fitp.data(5) ) / fitp.data(2);
				OInew{i}(end+1) = newferretoi(cells{j},0);
				oio = findassociate(cells{j},'OT Fit Orientation index','','');
				OIold{i}(end+1) = oio.data;
				dp1 = findassociate(cells{j},'OT Fit Pref','','');
				dp2 = findassociate(cells{j},'Recovery OT Fit Pref','','');
				if angdiffwrap(dp1.data-dp2.data,360) >= 90,
					flip{i}(end+1) = 1;
				else, flip{i}(end+1) = 0;
				end;
			end;
		end;
    end;
end;

if 1,
bins = [ 0 0.1 0.3 0.5 Inf ];

mns = [];
stes = [];

for i=1:length(DInew),
	for k=1:length(bins)-1,
		mns(i,k) = mean(flip{i}(find(DInew{i}>bins(k)&DInew{i}<=bins(k+1))));
		stes(i,k) = stderr(flip{i}(find(DInew{i}>bins(k)&DInew{i}<=bins(k+1)))');
	end;
end;

h=myerrorbar([0.05 0.2 0.4 0.75],mns,stes);
set(h,'linewidth',2,'color',[0 0 0]);
axis([0 0.8 0 0.55]);
hold on; plot([0 1],[0.5 0.5],'k--');
end;

keyboard;


