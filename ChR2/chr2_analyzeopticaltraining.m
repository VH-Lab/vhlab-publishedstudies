function chr2_analyzeopticaltraining(prefix)
% CHR2_ANALYZEOPTICALTRAINING - analyze direction responses following optical training
%
%  OUTPUT=CHR2_ANALYZEOPTICALTRAINING
%
%  

prefixtemp = prefix;

need_to_load = 1;

if evalin('caller',['exist(''chr2_analysis'',''var'')']),
	myvars = evalin('caller','chr2_analysis');
	struct2var(myvars);
	prefix=prefixtemp;
	clear prefixtemp;
	need_to_load = 0;
end;

	% look at 2012-12-18*, 2013-02-12*
expernames = {'2012-09-27', '2012-11-26', '2014-06-30', '2014-07-22', '2014-07-27', '2014-07-28', '2014-07-29','2012-12-14','2012-12-18','2014-08-17','2014-08-20','2014-08-25',...
'2014-09-25','2014-10-02','2014-10-09', ... % , '2012-11-26','2012-11-29'
	'2014-11-05','2014-11-25','2014-11-26'};

  % p38 animal: 2012-11-29
  % p30 animals: 2014-09-24, 2014-10-01, 2014-10-15, 2014-10-16

figdir = 'overall_figs';

if ~exist([prefix filesep figdir]), mkdir([prefix filesep figdir]); end;

if need_to_load,

	[cells,cellnames,experids]=readcellsfromexperimentlist(prefix,expernames,1,4);

	[cells,cellnames,included]=filter_by_index(cells,cellnames,105,500);
	experids = experids(included);

	output = extract_oridir_all(cells,cellnames,'SP F0',{'Dir1Hz','Dir2Hz','Dir4Hz'});

	need_to_load = 0;
	assignin('caller','chr2_analysis',workspace2struct);

	
end;

  % calc local changes in dr, di

if ~exist('vars','var'),
	vars = chr2_calcchangeDRDI(output,cells,cellnames,experids);
end;

chr2_changeXvstime(vars,'di_unsigned','Change in Raw DI',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeDI.pdf']);
chr2_changeXvstime(vars,'di_signed','Change in Signed DI',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changesignedDI.pdf']);
chr2_changeXvstime(vars,'maxresp_norm','Change in Max Resp',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeMaxRespNorm.pdf']);
chr2_changeXvstime(vars,'maxresp_abs','Absolute Max Resp',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_AbsoluteMaxResp.pdf']);
chr2_changeXvstime(vars,'di_esigned','Empirical Signed DI',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_EmpericalSignedDI.pdf']);
chr2_changeXvstime(vars,'dcv_unsigned','Change in Raw 1-DCV',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeDCV.pdf']);

chr2_changeXvstime(vars,'di_raw','Raw DI',output,cells,cellnames,experids,1,0);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_rawDI.pdf']);
chr2_changeXvstime(vars,'dcv_raw','Raw 1-DCV',output,cells,cellnames,experids,1,0);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_rawDCV.pdf']);
chr2_changeXvstimeSPLIT(vars,'di_raw','Raw DI',output,cells,cellnames,experids,1,0,1);
chr2_changeXvstimeSPLIT(vars,'di_raw','Raw DI',output,cells,cellnames,experids,1,0,0);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_di_signed_overall','DI signed','change in signed DI');
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltasignedDIoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_di_esigned_overall','DI Emperical signed',...
		'change in Empircal Signed DI');
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltaEmpiricalSignedDIoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_di_unsigned_overall','DI unsigned','change in DI');
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltaunsignedDIoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_dr_overall','DR','change in DR'); 
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltaDRoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'percent_change_resp','MaxResp','change in response'); 
saveas(gcf,[prefix filesep figdir filesep 'Experiments_dMaxRespoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'fraction_change_baseline_norm','Baseline','change in response'); 
saveas(gcf,[prefix filesep figdir filesep 'Experiments_dBaselineRespoverall.pdf']);

figure;
plot(vars.ori_initial,vars.ori_change,'ro');
ylabel('Change in orientation preference');
xlabel('Orientation preference - training angle orientation');
matchaxes(gca,-90,90,-90,90); 
hold on;
plot([-90 90],[0 0],'k--');
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationPrefChanges_vs_TrainingAngle.pdf']);

figure;
plot(vars.ori_initial,vars.delta_di_signed_overall,'ro');
ylabel('Change in signed DI');
xlabel('Orientation preference - training angle orientation');
matchaxes(gca,-90,90,-2,2); 
hold on;
plot([-90 90],[0 0],'k--');
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationsignedDIAndTrainingAngle.pdf']);
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationsignedDIAndTrainingAngle.fig']);
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationsignedDIAndTrainingAngle.eps']);

figure;
plot(vars.ori_initial,vars.delta_di_unsigned_overall,'ro');
ylabel('Change in overall DI');
xlabel('Orientation preference - training angle orientation');
hold on;
plot([-90 90],[0 0],'k--');
matchaxes(gca,-90,90,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationunsignedDIAndTrainingAngle.pdf']);

figure;
plot(vars.percent_change_resp,vars.delta_di_signed_overall,'ks');
ylabel('Change in overall signed DI');
xlabel('Fraction change in responsiveness');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_Responsiveness_vs_signedDI.pdf']);

figure;
plot(vars.fraction_change_baseline_norm,vars.delta_di_signed_overall,'ks');
ylabel('Change in overall signed DI');
xlabel('Fraction change in baseline');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_BaselineResponse_vs_signedDI.pdf']);

figure;
plot(vars.percent_change_resp,vars.delta_di_unsigned_overall,'ks');
ylabel('Change in overall unsigned DI');
xlabel('Fraction change in responsiveness');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_Responsiveness_vs_unsignedDI.pdf']);

cellindexes = [];
for i=1:length(output),
	myindex = find(vars.indexlookup==i,1,'first');
	if isempty(myindex),
		cellindexes(i) = NaN; % actually this will cause an error if there are really none
	else,
		cellindexes(i) = myindex;
	end;
end;

% histogram of change in signed di

 % identify lookup inds with significant points in the 4-7 hour range
myinds = find(~isnan(vars.delta_di_signed_overall));
mynewinds = [];

delta_t = [];

for zzz=1:length(myinds),
	thecellindexes = find(vars.indexlookup==myinds(zzz) & vars.t>0);
	if any(~isnan(vars.di_raw(thecellindexes))),
		mynewinds(end+1) = myinds(zzz);
	end;
end;

figure;
plot(abs(vars.ori_initial(mynewinds)),vars.delta_di_unsigned_overall(mynewinds),'ro');
[slope,offset,conf_interval]=quickregression(abs(vars.ori_initial(mynewinds))', vars.delta_di_unsigned_overall(mynewinds)', 0.05);
p=quickregressionpvalue(abs(vars.ori_initial(mynewinds))',vars.delta_di_unsigned_overall(mynewinds)'),
ylabel('Change in overall DI');
xlabel('Orientation preference - training angle orientation');
title(['N=' int2str(length(mynewinds)) ]);
hold on;
plot([0 90],[0 0],'k--');
plot([0 90],[0 90]*slope+offset,'k--','linewidth',2);
matchaxes(gca,0,90,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_AbsOrientationunsignedDIAndTrainingAngle.pdf']);


figure;
bins = -2:0.2:2;
N = histc(vars.delta_di_signed_overall(mynewinds),bins);
N = N/sum(N);
bar(bins+0.1,N);
xlabel('Delta DI signed');
ylabel('Fraction of cells');
title(['N = ' int2str(length(mynewinds)) ', signtest ', mat2str(signtest(vars.delta_di_signed_overall))]);
box off;
saveas(gcf,[prefix filesep figdir filesep 'Histogram_deltasignedDI.pdf']);

% before, after
figure;
%goodcells = intersect(find(~isnan(vars.delta_di_signed_overall)), mynewinds);
goodcells = find(~isnan(vars.delta_di_signed_overall));
%plot(vars.di_signed_init(cellindexes(goodcells)), vars.di_signed_init(cellindexes(goodcells))+vars.delta_di_signed_overall(goodcells),'o');
plot([-1 -1],[1 1],'k--'); % unity line
box off;
xlabel('DI signed before')
ylabel('DI signed after')
hold on;
exper_ids = unique(vars.experids(goodcells));
mns = [];

newcolors = ['rgymbkc'];

delta_ts = [];

for zzz=1:length(exper_ids),
	mygoodcells = find(~isnan(vars.delta_di_signed_overall) & vars.experids'==exper_ids(zzz));
	plot(vars.di_signed_init(cellindexes(mygoodcells)), vars.di_signed_init(cellindexes(mygoodcells))+vars.delta_di_signed_overall(mygoodcells),...
		[newcolors(zzz) 'o'],'markerfacecolor',newcolors(zzz));
	mns = [ mns; mean(vars.di_signed_init(cellindexes(mygoodcells))) mean(vars.di_signed_init(cellindexes(mygoodcells))+vars.delta_di_signed_overall(mygoodcells))];
	for jjj=1:length(mygoodcells),
		kk=find(vars.indexlookup==mygoodcells(jjj));
		otherindex = find(isnan(vars.di_raw(kk)),1,'first');
		if isempty(otherindex),
			delta_ts(end+1) = vars.t(kk(end));
		elseif otherindex > 2,
			delta_ts(end+1) = vars.t(kk(otherindex-1));
		end;
	end;
	plot(mns(zzz,1),mns(zzz,2),[newcolors(zzz) 'x'],'markersize',12,'markerfacecolor',newcolors(zzz),'linewidth',2.9);
end;
%plot(mns(:,1),mns(:,2),'rx','markersize',12);
plot([-1 1],[0 0],'k--');
plot([0 0 ],[-1 1],'k--');
plot([-1 1],[-1 1],'k--'); % unity line
box off;

disp(['the mean is ' num2str(mean(delta_ts)) '.']);

saveas(gcf,[prefix filesep figdir filesep 'Scatter_deltasignedDI_initialfinal.pdf']);
saveas(gcf,[prefix filesep figdir filesep 'Scatter_deltasignedDI_initialfinal.fig']);
saveas(gcf,[prefix filesep figdir filesep 'Scatter_deltasignedDI_initialfinal.eps']);

need_to_load = 0;
assignin('caller','chr2_analysis',workspace2struct);

