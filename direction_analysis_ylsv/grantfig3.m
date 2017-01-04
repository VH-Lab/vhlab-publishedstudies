function grantfig3(prefix,expnames)

myfig = figure;

try, mkdir(prefix,'direction_analysis'); end;
output_path = fixpath([fixpath(prefix) 'direction_analysis']);


dirthresh = 0.3;

cellviews = [1 5 6];  stacknames = {'test','Site1'};
labels={'EO 1 day', 'EO 7 days','EO 16 days'};

for i=1:0*2,
	% load cells
	tpf = [prefix expnames{cellviews(i)}];
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

	subplot(3,2,i); pos = get(gca,'position'); delete(gca);
	plototdirstack(ds,stacknames{i},'otdirgreenblue',1,'otgray',0,'ot_assoc','OT Fit Pref 2 Peak','dir_assoc','OT Direction index 2 peak','dirthresh',dirthresh,'rotate',90);
	thefig = gcf;
	ch = get(thefig,'children');
    axis equal; set(gca,'box','off');
    title(labels{i});
	set(ch(1),'parent',myfig,'position',pos);
	%if i==2, set(ch(2),'parent',myfig,'position',[0.95 0.7 0.03 0.25]); end;
	close(thefig);
end;

for k=1:2,
        DI{k} = [];
        OT{k} = [];
        OTmDI{k} = [];
        AngOff{k} = [];
end;

agemin = Inf; agemax = 0;

usesaved = 1;

if ~usesaved,
for i=1:length(expnames),
        tpf = [prefix expnames{i}],
        ds = dirstruct(tpf);
        [cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
        age = findassociate(cells{1},'Eyes open','','');
        agemax = max(agemax,age.data); agemin=min(agemin,age.data);
        if age.data<2, k=1;
        elseif age.data<110, k=2;
        elseif age.data<100, k=3;
        end;
        k,
        for j=1:length(cells),
                di_a = findassociate(cells{j},'OT Direction index 2 peak sp','','');
                ot_a = findassociate(cells{j},'OT Orientation index 2 peak sp','','');
                carprefs = findassociate(cells{j},'OT Carandini 2-peak Fit Params','','');
                carfit = findassociate(cells{j},'OT Carandini 2-peak Fit','','');
                pvalasoc = findassociate(cells{j},'OT visual response p','','');

                if ~isempty(pvalasoc),
                        if pvalasoc.data<0.05,
                                Rsp_ = carprefs.data(1); Rp_ = carprefs.data(2); Rn_ = carprefs.data(5);
                                Ot_ = carprefs.data(3); sigm_ = carprefs.data(4); OnOff_ = carprefs.data(6);
                                fitcurve_ = carfit.data;
                                OtPi_ = findclosest(0:359,Ot_); OtNi_ = findclosest(0:359,mod(Ot_+OnOff_,360));
                                OtO1i_ = findclosest(0:359,mod(Ot_+OnOff_/2,360)); OtO2i_ = findclosest(0:359,mod(Ot_-(360-OnOff_)/2,360));
                                otindfit_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_));
                                otindfitsp_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_)-Rsp_-Rsp_);

                                DI{k}(end+1)=di_a.data;
                                OT{k}(end+1)=ot_a.data;
                                OTmDI{k}(end+1) = ot_a.data-di_a.data;
                                if di_a.data<0.5, AngOff{k}(end+1) = carprefs.data(6); end;
                        end;
                end;
        end;
end;
save([output_path 'grantfig3data.mat'],'-mat');
else,
load([output_path 'grantfig3data.mat'],'-mat');
end;

cellplots = [ 1 1 1]; labels={'EO < 2 days','EO 2-16 days','EO 8-15 days'};

binsx = [-0.1:0.10:1.1];
binsy = [-0.1:0.10:1.1];

for i=1:2,
    if 0,
        subplot(3,2,2+i);
        hold off;
        myinds = find(DI{i}>=dirthresh);
        plot(OT{i}(myinds),DI{i}(myinds),'k.');
        hold on;
        myinds = find(DI{i}<dirthresh);    
        plot(OT{i}(myinds),DI{i}(myinds),'k.');
        if i==1, ylabel('direction index'); end;
        xlabel('orientation index');
        title(labels{i});
        set(gca,'box','off');
        if 0,
            hold on;
            plot([-100 100],[0.3 0.3],'k--');
        end;
        axis([0 2 0 2]);
    else,
        subplot(3,2,2+i);
        mat=[OT{i}' DI{i}'];
        vXCoord = 0.5*(binsx(1:end-1)+binsx(2:end));
        vYCoord = 0.5*(binsy(1:end-1)+binsy(2:end));
        if ~isempty(mat),
            mHist = hist2d(mat,binsx,binsy);
            num=sum(sum(mHist));
            pcolor(vXCoord,vYCoord,100*mHist'/num);colorbar;
        else, axis([min(vXCoord) max(vXCoord) min(vYCoord) max(vYCoord)]); colorbar;
        end;
        if i==1, ylabel('direction index'); end;
        xlabel('orientation index');
        title(labels{i});
        set(gca,'box','off');
    end;
end;

disp(['Kruskal-wallis test on DI: ' num2str(kruskal_wallis_test(DI{1},DI{2})) '.']);
disp(['Kruskal-wallis test on OI: ' num2str(kruskal_wallis_test(OT{1},OT{2})) '.']);
