function output=makeclusteranalysis(prefix,expnames)


%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

try, mkdir(prefix,'direction_analysis'); end;
output_path = fixpath([fixpath(prefix) 'direction_analysis']);

for k=1:3,
	CI_DI{k} = [];
	CI_OI{k} = [];
	CI_OT{k} = [];
	CI_Dir{k} = [];
		% for number of cells:
	CI_DIn{k} = [];
	CI_OIn{k} = [];
	CI_OTn{k} = [];
	CI_Dirn{k} = [];
end;

agemin = Inf; agemax = 0;

for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	stacknames = findallstacks(ds);
	for j=1:length(stacknames),
		mycells = selectstackcells(ds,stacknames{j});
		otp = []; dirp = []; di = []; ot = []; cellpos = [];
	        incl = [];
		for z=1:length(mycells),
			pvalasoc = findassociate(mycells{z},'OT visual response p','','');
			if ~isempty(pvalasoc),
				if pvalasoc.data<0.05,
					incl(end+1)=z;
					otfitpref = findassociate(mycells{z},'OT Fit Pref 2 Peak','','');
					dirp(end+1) = otfitpref.data;
					otp(end+1) = mod(otfitpref.data,180);
					diassoc = findassociate(mycells{z},'OT Direction index 2 peak','','');
					di(end+1) = diassoc.data;
					otassoc = findassociate(mycells{z},'OT Orientation index 2 peak','','');
					ot(end+1) = otassoc.data;
					celllocs= findassociate(mycells{z},'pixellocs','','');
					cellpos(end+1,:) = [ mean(celllocs.data.x) mean(celllocs.data.y) ];
				end;
			end;
		end;
		if length(incl)>20,
			[mCI_dir,mCI_dir_ncells] = calc_cluster_index(cellpos,[],1/(250/512),[],100,20,1,1,dirp,...
				'min(abs([x1-x2;x1-x2-360;x1-x2+360]))','rand*360');
			[mCI_otp,mCI_otp_ncells] = calc_cluster_index(cellpos,[],1/(250/512),[],100,20,1,1,otp,...
				'min(abs([x1-x2;x1-x2-180;x1-x2+180]))','rand*180');
			[mCI_oi,mCI_oi_ncells] = calc_cluster_index(cellpos,[],1/(250/512),[],100,20,1,1,ot,...
				'abs(x1-x2)','rand');
			[mCI_di,mCI_di_ncells] = calc_cluster_index(cellpos,[],1/(250/512),[],100,20,1,1,di,...
				'abs(x1-x2)','rand');
			age = findassociate(cells{1},'Age','','');
			agemax = max(agemax,age.data); agemin = min(agemin,age.data);
			if age.data<35, k=1;
			elseif age.data<39, k=2;
			elseif age.data<100, k=3;
			end;
			CI_Dir{k} = cat(2,CI_Dir{k},mCI_dir); CI_Dirn{k} = cat(2,CI_Dirn{k},mCI_dir_ncells);
			CI_DI{k} = cat(2,CI_DI{k},mCI_di); CI_DIn{k} = cat(2,CI_DIn{k},mCI_di_ncells);
			CI_OI{k} = cat(2,CI_OI{k},mCI_oi); CI_OIn{k} = cat(2,CI_OIn{k},mCI_oi_ncells);
			CI_OT{k} = cat(2,CI_OT{k},mCI_otp); CI_OTn{k} = cat(2,CI_OTn{k},mCI_otp_ncells);
		end;
	end;
end;

output.CI_Dir = CI_Dir;
output.CI_DI = CI_DI;
output.CI_OI = CI_OI;
output.CI_OT = CI_OT;
output.CI_OTn = CI_OTn;
output.CI_Dirn= CI_Dirn;
output.CI_DIn = CI_DIn;
output.CI_OIn = CI_OIn;


bins = { [-Inf -3:0.1:3 Inf],[-Inf -3:0.1:3 Inf],[-Inf -3:0.1:3 Inf],[-Inf -3:0.1:3 Inf] };
X = { [ -3:0.1:3-0.1 ]+0.1/2, [ -3:0.1:3-0.1 ]+0.1/2, [ -3:0.1:3-0.1 ]+0.1/2, [ -3:0.1:3-0.1 ]+0.1/2};
yvar = { CI_Dir CI_OT CI_DI CI_OI };
xlabels={'Direction (^\circ)','Orientation (^\circ)','DI','OI'};
ylabels={'Fraction','Fraction','Fraction','Fraction'};
filenames={'CI_Dir_age_cum.ps','CI_OT_age_cum.ps','CI_DI_age_cum.ps','CI_OI_age_cum.ps'};

  % now make our plots

for k=1:length(yvar),
        figure;
	for jj=1:3,
        subplot(3,1,jj);
        if isempty(yvar{k}{jj}), N{jj} = zeros(length(X{k})+3,1);
        else, N{jj} = histc(yvar{k}{jj},bins{k});
        end;
        plot(X{k},cumsum(N{jj}(2:end-2))/sum(N{jj}(2:end-2)));
        xlabel(xlabels{k}); ylabel(ylabels{k});
        A = axis; axis([X{k}(1) X{k}(end) A(3) A(4)]);
	if jj==1, title(['Ages ' int2str(agemin) ' - 34 PND.']);
	elseif jj==2, title(['Ages 35-38 PND.']);
	elseif jj==3, title(['Ages 39 - ' int2str(agemax) '.']);
	end; %for jj
	end;

        eval(['print -dpsc ' output_path filenames{k}]);
end;


return;
for k=4:length(yvar),
	for jj=1:3,
		if ~isempty(yvar{k}{jj}.x),
			[P,S]=polyfit(yvarscale(k)*yvar{k}{jj}.y,yvar{k}{jj}.x,1);
			[B,Bint]=regress(yvar{k}{jj}.x'-P(2),yvarscale(k)*yvar{k}{jj}.y',0.05);
			if ~(Bint(1)<0&Bint(2)>0),
				disp(['Slope of ' xlabels{k} ' vs. ' ylabels{k} ' is significant.']);
				[jj B Bint P(1) P(2) ],
			end;
		end;

	end;
end;
