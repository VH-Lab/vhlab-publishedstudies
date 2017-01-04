function makedihistograms(prefix,expnames)

%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

try, mkdir(prefix,'direction_analysis'); end;
output_path = fixpath([fixpath(prefix) 'direction_analysis']);


for k=1:2,
        DI{k} = [];
        OT{k} = [];
	OTmDI{k} = [];
	AngOff{k} = [];
end;

agemin = Inf; agemax = 0;

for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
				age = findassociate(cells{1},'Eyes open','','');
				agemax = max(agemax,age.data); agemin=min(agemin,age.data);
				if age.data<2, k=1;
				elseif age.data<100, k=2;
				elseif age.data<1020, k=3;
				end;    
    k,
    
	for j=1:length(cells),

		di_a = findassociate(cells{j},'OT Direction index 2 peak sp','','');
	        ot_a = findassociate(cells{j},'OT Orientation index 2 peak sp','','');
		carprefs = findassociate(cells{j},'OT Carandini 2-peak Fit Params','','');
		pvalasoc = findassociate(cells{j},'OT visual response p','','');

		if ~isempty(pvalasoc),
			if pvalasoc.data<0.05,

				DI{k}(end+1)=di_a.data;
				OT{k}(end+1)=ot_a.data;
				OTmDI{k}(end+1) = ot_a.data-di_a.data;
				if di_a.data<0.5, AngOff{k}(end+1) = carprefs.data(6); end;
			end;
		end;
	end;
end;

bins = { [-Inf 0:0.05:1 Inf],[-Inf 0:0.05:1 Inf],[-Inf 0:0.05:1 Inf],[-Inf 130:5:230 Inf] };
X = { [ 0:0.05:1-0.05 ]+0.05/2, [ 0:0.05:1-0.05 ]+0.05/2, [ 0:0.05:1-0.05 ]+0.05/2, [130:5:225]+2.5};
yvar = { DI OT OTmDI AngOff};
yvarscale = { 1 1 1 };
xlabels={'DI','OI','OI-DI','Angle offset (\circ)'};
ylabels={'Count','Count','Count','Count'};
filenames={'DI_age_hist.ps','OT_age_hist.ps','OI_DI_age_hist.ps','AngOffset_age_hist.ps'};

length(find(yvar{1}{1}>0.5))/length(yvar{1}{1})
length(find(yvar{1}{2}>0.5))/length(yvar{1}{2})

for k=1:length(yvar),

        figure;
        subplot(3,1,1);
	if isempty(yvar{k}{1}), N{1} = zeros(length(X{k})+3,1);
	else, N{1} = histc(yvar{k}{1},bins{k}); N{1}=100*cumsum(N{1})/sum(sum(N{1}));
	end;
	plot(X{k},N{1}(2:end-2));
        xlabel(xlabels{k}); ylabel(ylabels{k});
	A = axis; axis([X{k}(1) X{k}(end) A(3) A(4)]);
        title(['Ages ' int2str(agemin) ' - 34 PND.']);

        subplot(3,1,2);
	if isempty(yvar{k}{2}), N{2} = zeros(length(X{k})+3,1);
	else, N{2} = histc(yvar{k}{2},bins{k});N{2}=100*cumsum(N{2})/sum(sum(N{2}));
	end;
	plot(X{k},N{2}(2:end-2));
        xlabel(xlabels{k}); ylabel(ylabels{k});
	A = axis; axis([X{k}(1) X{k}(end) A(3) A(4)]);
        title(['Ages 35-38 PND.']);
if 0,
        subplot(3,1,3);
	if isempty(yvar{k}{3}), N{3} = zeros(length(X{k})+3,1);
	else, N{3} = histc(yvar{k}{3},bins{k});N{3}=100*cumsum(N{3})/sum(sum(N{3}));
	end;
	plot(X{k},N{3}(2:end-2));
        xlabel(xlabels{k}); ylabel(ylabels{k});
	A = axis; axis([X{k}(1) X{k}(end) A(3) A(4)]);
        title(['Ages 39 - ' int2str(agemax) '.']);
        eval(['print -dpsc ' output_path filenames{k}]);
end;
end;

