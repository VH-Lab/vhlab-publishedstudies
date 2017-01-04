close all;

if 0,
	output1=plotalltptfs('/Volumes/Data1/treeshrew/ZabWoodySteve/',{'2013-06-03','2013-06-06','2013-10-21','2014-10-03','2014-10-08'},3,3);
	output2=plotalltptfs('/Volumes/Data1/treeshrew/ZabWoodySteve/',{'2007-09-19','2014-10-07'},3,3);
end;

figure;
h1=myerrorbar(output2.all_x,nanmean(output2.all_raw),nanstderr(output2.all_raw),'-');
set(h1,'color',[0 0 0],'linewidth',2);
hold on;
h2=myerrorbar(output1.all_x,nanmean(output1.all_raw),nanstderr(output1.all_raw),'-');
set(h2,'color',[0.5 0.5 0.5],'linewidth',2);
box off;
ylabel('Normalized response');
set(gca,'ytick',[0 0.5 1]);
xlabel('Temporal frequency (Hz)');
title(['Control (gray) vs. Red-reared (black), grand average responses']);

figure;
h1=myerrorbar(output2.all_x,nanmean(output2.all_reallyraw),nanstderr(output2.all_reallyraw),'-');
set(h1,'color',[0 0 0],'linewidth',2);
hold on;
h2=myerrorbar(output1.all_x,nanmean(output1.all_reallyraw),nanstderr(output1.all_reallyraw),'-');
set(h2,'color',[0.5 0.5 0.5],'linewidth',2);
box off;
ylabel('Normalized response');
set(gca,'ytick',[0 0.5 1]);
xlabel('Temporal frequency (Hz)');
title(['Control (gray) vs. Red-reared (black), grand average non normalized responses']);


bins = [0 0.5 1 2 4 8 20 35 Inf]+0.01;
binlabels = 1:length(bins)-1;
N1 = histc(output1.pref1,bins);
N2 = histc(output2.pref1,bins);
figure;
subplot(2,1,1);
h3=bar(binlabels-0*0.25,100*N2(1:end-1)/sum(N2(1:end-1)));
set(h3,'facecolor',[0 0 0]);
ylabel('Control');
box off;
set(gca,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' ', '', '', '', ''});
A = axis;
title(['Histogram of temporal frequency preferences']);
subplot(2,1,2);
hold on;
h4=bar(binlabels+0*0.25,100*N1(1:end-1)/sum(N1(1:end-1)));
set(h4,'facecolor',0.5+[0 0 0]);
ylabel('Red-reared')
set(gca,'xtick',binlabels,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' ',' ', ' ', ' '});
box off;
axis(A);

[h,p] = kstest2(output1.pref1,output2.pref2);

disp(['Stats: KS-test of prefs: ' num2str(p) '.']);

bins = [0 0.5 1 2 4 8 20 35 Inf]+0.01;
binlabels = 1:length(bins)-1;
N1 = histc(cat(1,output1.pref1(:),TFS1(:)),bins);
N2 = histc(cat(1,output2.pref1(:),TFS2(:)),bins);
figure;
subplot(2,1,1);
h3=bar(binlabels-0*0.25,100*N2(1:end-1)/sum(N2(1:end-1)));
set(h3,'facecolor',[0 0 0]);
ylabel('Control');
box off;
set(gca,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' ', '', '', '', ''});
A = axis;
title(['Histogram of temporal frequency preferences, primary and secondary peaks']);
subplot(2,1,2);
hold on;
h4=bar(binlabels+0*0.25,100*N1(1:end-1)/sum(N1(1:end-1)));
set(h4,'facecolor',0.5+[0 0 0]);
ylabel('Red-reared')
set(gca,'xtick',binlabels,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' ',' ', ' ', ' '});
box off;
axis(A);

[h,p] = kstest2(cat(1,output1.pref1(:),TFS1(:)),cat(1,output2.pref2(:),TFS2(:)));
disp(['Stats: KS-test of primary, secondary prefs: ' num2str(p) '.']);

bins = [-0.02 0 0.5 1 2 4 8 20 35 50 Inf]+0.01;
binlabels = 1:length(bins)-1;
output1.high(find(isnan(output1.high))) = 40;
output2.high(find(isnan(output2.high))) = 40;
N1a = histc(output1.high,bins);
N2a = histc(output2.high,bins);
figure;
subplot(2,1,1);
h3=bar(binlabels-0*0.25,100*N2a(1:end-1)/sum(N2a(1:end-1)));
set(h3,'facecolor',[0 0 0]);
ylabel('Control');
box off;
set(gca,'xticklabel',{'0.5','1','2','4','8','16-20','30-32','Inf'});
A = axis;
title(['Histogram of high frequency cut-offs (crap for multipeaked cells)']);
subplot(2,1,2);
hold on;
h4=bar(binlabels+0*0.25,100*N1a(1:end-1)/sum(N1a(1:end-1)));
set(h4,'facecolor',0.5+[0 0 0]);
ylabel('Red-reared')
set(gca,'xtick',binlabels,'xticklabel',{'0.5','1','2','4','8','16-20','30-32','Inf'});
box off;
axis(A);

bins = [-0.02 0 0.5 1 2 4 8 20 35 50 Inf]+0.01;
binlabels = 1:length(bins)-1;
output1.low(find(isnan(output1.low))) = 0;
output2.low(find(isnan(output2.low))) = 0;
N1b = histc(output1.low,bins);
N2b = histc(output2.low,bins);
figure;
subplot(2,1,1);
h3=bar(binlabels-0*0.25,100*N2b(1:end-1)/sum(N2b(1:end-1)));
set(h3,'facecolor',[0 0 0]);
ylabel('Control');
box off;
set(gca,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' '});
A = axis;
title('Low Frequency cut offs');
subplot(2,1,2);
hold on;
h4=bar(binlabels+0*0.25,100*N1b(1:end-1)/sum(N1b(1:end-1)));
set(h4,'facecolor',0.5+[0 0 0]);
ylabel('Red-reared')
set(gca,'xtick',binlabels,'xticklabel',{'0.5','1','2','4','8','16-20','30-32',' '});
box off;
axis(A);

figure;
subplot(2,1,1);
h5=bar(binlabels-0.25/2,100*N2b(1:end-1)/sum(N2b(1:end-1)),0.25);
set(h5,'facecolor',[0 0 0]);
hold on;
h6=bar(binlabels+0.25/2,100*N2a(1:end-1)/sum(N2a(1:end-1)),0.25);
set(h6,'facecolor',[1 1 1],'edgecolor',[0 0 0]);
box off;
set(gca,'xtick',binlabels,'xticklabel',{'0','0.5','1','2','4','8','16-20','30-32',' '});

subplot(2,1,2);
h5=bar(binlabels-0.25/2,100*N1b(1:end-1)/sum(N1b(1:end-1)),0.25);
set(h5,'facecolor',0.5+[0 0 0]);
hold on;
h6=bar(binlabels+0.25/2,100*N1a(1:end-1)/sum(N1a(1:end-1)),0.25);
set(h6,'facecolor',[1 1 1],'edgecolor',[0.5 0.5 0.5]);
box off;
set(gca,'xtick',binlabels,'xticklabel',{'0','0.5','1','2','4','8','16-20','30-32',' '});


figure;
avg_1 = nanmean(output1.all_raw);
stde1 = nanstderr(output1.all_raw);
avg_2 = nanmean(output2.all_raw);
stde2 = nanstderr(output2.all_raw);
fitx = min(output1.all_x):1:max(output1.all_x);
if fitx(end)~=max(output1.all_x), fitx(end) = max(output1.all_x); end;
avg_1_spline = interp1(output1.all_x,avg_1,fitx,'spline');
avg_2_spline = interp1(output2.all_x,avg_2,fitx,'spline');
subplot(2,1,1);
h_ = errorbar(output1.all_x,avg_1,stde1,stde1,'o');
set(h_,'color',[0.5 0.5 0.5],'linewidth',1);
hold on;
plot(fitx,avg_1_spline,'-','color',[0.5 0.5 0.5]);
plot([0 35],[0.5 0.5],'k--','linewidth',0.5);
box off;
axis([0 35 0 1]);
subplot(2,1,2);
h_ = errorbar(output2.all_x,avg_2,stde2,stde2,'o');
set(h_,'color',[0.5 0.5 0.5]*0,'linewidth',1);
hold on;
plot(fitx,avg_2_spline,'-','color',[0.5 0.5 0.5]*0);
plot([0 35],[0.5 0.5],'k--','linewidth',0.5);
box off;
axis([0 35 0 1]);

X = [];  G = [];
for i=1:size(output1.all_raw,1),  % red-reared
	if ~any(isnan(output1.all_raw(i,:))),
		for j=[1:6 8],
			X(end+1) = output1.all_raw(i,j);
			G(end+1,:) = [j 1];
			if j==8, G(end,1) = 7; end;
		end;
	end;
end;
for i=1:size(output2.all_raw,1),
	if ~any(isnan(output2.all_raw(i,:))),
		for j=1:size(output2.all_raw,2),
			X(end+1) = output2.all_raw(i,j);
			G(end+1,:) = [j 2];
		end;
	end;
end;

[panova,anovatab,anova_stats] = anovan(X', G,'varnames',{'TF','Exp'});
[cs]=multcompare(anova_stats,'dimension',[1 2]);



