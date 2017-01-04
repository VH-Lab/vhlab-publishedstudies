function chr2_analyzeopticaltraining(prefix)
% CHR2_ANALYZEVISUALTRAINING - analyze direction responses following optical training
%
%  OUTPUT=CHR2_ANALYZEVISUALTRAINING
%
%  

prefixtemp = prefix;

need_to_load = 1;

if evalin('caller',['exist(''chr2_visanalysis'',''var'')']),
	myvars = evalin('caller','chr2_visanalysis');
	struct2var(myvars);
	prefix=prefixtemp;
	clear prefixtemp;
	need_to_load = 0;
end;

expernames = {'2014-05-06','2014-05-19','2014-04-01','2014-04-04','2014-12-16','2014-12-02','2014-09-23','2014-10-07'};

figdir = 'overall_figs';

if ~exist([prefix filesep figdir]), mkdir([prefix filesep figdir]); end;

	% look at 2012-11-29*, 2012-12-14*, 2013-02-12*
	% * indicates multichannel recording

if need_to_load,

	[cells,cellnames,experids]=readcellsfromexperimentlist(prefix,expernames,1,4);

	[cells,cellnames,included]=filter_by_index(cells,cellnames,48,98);
	experids = experids(included);

	% filter quality

	incl = [];
	for i=1:length(cells),
		A=findassociate(cells{i},'vhlv_clusterinfo','','');
		if strcmp(lower(A.data.qualitylabel),'good') | strcmp(lower(A.data.qualitylabel),'excellent') | strcmp(lower(A.data.qualitylabel(1:4)),'mult'),
			incl(end+1) = i;
		end;
		clear A;
	end;

	cells = cells(incl);
	cellnames = cellnames(incl);
	experids = experids(incl);

	output = extract_oridir_all(cells,cellnames,'SP F0',{'Dir2Hz','Dir4Hz'});
	%output = extract_oridir_all(cells,cellnames,'SP F0',{'Dir4Hz'});
	 % save work to workspace

	need_to_load = 0;
	assignin('caller','chr2_visanalysis',workspace2struct);
end;


vars = chr2_calcchangeDRDI(output,cells,cellnames,experids);

chr2_changeXvstime(vars,'di_unsigned','Change in Raw DI',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeUnsignedDI.pdf']);
chr2_changeXvstime(vars,'di_esigned','Change in Empirical Signed DI',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeEmpericalsignedDI.pdf']);
chr2_changeXvstime(vars,'maxresp_norm','Change in Max Resp',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_changeMaxResp.pdf']);
chr2_changeXvstime(vars,'maxresp_abs','Absolute Max Resp',output,cells,cellnames,experids);
saveas(gcf,[prefix filesep figdir filesep 'Time_vs_AbsoluteMaxResp.pdf']);

if 0,
chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_di_esigned_overall','DI Emperical signed',...
		'change in Emperical Signed DI');
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltaEmpericalsignedDIoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'delta_di_unsigned_overall','DI unsigned','change in DI');
saveas(gcf,[prefix filesep figdir filesep 'Experiments_deltaunsignedDIoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'percent_change_resp','MaxResp','change in response'); 
saveas(gcf,[prefix filesep figdir filesep 'Experiments_dMaxRespoverall.pdf']);

chr2_plotoverallchange(vars,output,cells,cellnames,experids,expernames,'fraction_change_baseline_norm','Baseline','change in response'); 
saveas(gcf,[prefix filesep figdir filesep 'Experiments_dBaselineRespoverall.pdf']);
end;


 % identify lookup inds with significant points in the 4-7 hour range
myinds = find(~isnan(vars.delta_di_esigned_overall));
mynewinds = [];
delta_ts = [];

for zzz=1:length(myinds),
        thecellindexes = find(vars.indexlookup==myinds(zzz) & vars.t>0);
        if any(~isnan(vars.di_raw(thecellindexes))),
                mynewinds(end+1) = myinds(zzz);
        end;
        kk = find(vars.indexlookup==myinds(zzz));
	otherindex = find(isnan(vars.di_raw(kk)),1,'first');
	if isempty(otherindex),
		delta_ts(end+1) = vars.t(kk(end));
	elseif otherindex > 2,
		delta_ts(end+1) = vars.t(kk(otherindex-1));
	end;

end;

disp(['average duration ' num2str(mean(delta_ts)) '.']);


figure;
plot(vars.ori_initial,vars.ori_change,'ks');
ylabel('Change in orientation preference');
xlabel('Orientation preference - training angle orientation');
matchaxes(gca,-90,90,-90,90); 
hold on;
plot([-90 90],[0 0],'k--');
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationPrefChangesAndTrainingAngle.pdf']);

figure;
plot(vars.ori_initial,vars.delta_di_esigned_overall,'ks');
ylabel('Change in Emperical Signed DI');
xlabel('Orientation preference - training angle orientation');
matchaxes(gca,-90,90,-2,2); 
hold on;
plot([-90 90],[0 0],'k--');
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationEmpericalSignedDIAndTrainingAngle.pdf']);

figure;
plot(abs(vars.ori_initial(mynewinds)),vars.delta_di_unsigned_overall(mynewinds),'ko');
[slope,offset,conf_interval]=quickregression(abs(vars.ori_initial(mynewinds))',vars.delta_di_unsigned_overall(mynewinds)',0.05);
p=quickregressionpvalue(abs(vars.ori_initial(mynewinds))',vars.delta_di_unsigned_overall(mynewinds)'),
hold on;
plot([0 90],[0 90]*slope+offset,'k--','linewidth',2);
ylabel('Change in overall DI');
xlabel('Orientation preference - training angle orientation');
title(['n=' int2str(sum(~isnan((mynewinds)))) '.']);
hold on;
plot([-90 90],[0 0],'k--');
matchaxes(gca,0,90,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_AbsOrientationunsignedDIAndTrainingAngle.pdf']);

figure;
plot(vars.ori_initial(mynewinds),vars.delta_di_unsigned_overall(mynewinds),'ko');
ylabel('Change in overall DI');
xlabel('Orientation preference - training angle orientation');
hold on;
plot([-90 90],[0 0],'k--');
matchaxes(gca,-90,90,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_OrientationunsignedDIAndTrainingAngle.pdf']);


figure;
plot(vars.percent_change_resp,vars.delta_di_esigned_overall,'ks');
ylabel('Change in overall Emperical signed DI');
xlabel('Fraction change in responsiveness');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_Responsiveness_vs_EmpericalSignedDI.pdf']);

figure;
plot(vars.fraction_change_baseline_norm,vars.delta_di_esigned_overall,'ks');
ylabel('Change in overall Emperical signed DI');
xlabel('Fraction change in baseline');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_BaselineResponse_vs_EmpericalSignedDI.pdf']);

figure;
plot(vars.percent_change_resp,vars.delta_di_unsigned_overall,'ks');
ylabel('Change in overall unsigned DI');
xlabel('Fraction change in responsiveness');
hold on;
plot([0 7],[0 0],'k--');
matchaxes(gca,0,7,-2,2); 
box off;
saveas(gcf,[prefix filesep figdir filesep 'Scatter_Responsiveness_vs_unsignedDI.pdf']);

need_to_load = 0;
assignin('caller','chr2_visanalysis',workspace2struct);


keyboard;

myinds = find(~isnan(vars.delta_dcv_esigned_overall));
mynewinds = [];

delta_t = [];

for zzz=1:length(myinds),
        thecellindexes = find(vars.indexlookup==myinds(zzz) & vars.t>0);
        if any(~isnan(vars.di_raw(thecellindexes))),
                mynewinds(end+1) = myinds(zzz);
        end;
end;

% before, after
figure;
%goodcells = intersect(find(~isnan(vars.delta_di_signed_overall)), mynewinds);
goodcells = find(~isnan(vars.delta_di_esigned_overall));
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
        mygoodcells = find(~isnan(vars.delta_di_esigned_overall) & vars.experids'==exper_ids(zzz));
        %plot(vars.di_signed_init(cellindexes(mygoodcells)), vars.di_signed_init(cellindexes(mygoodcells))+vars.delta_di_signed_overall(mygoodcells),...
        %        [newcolors(zzz) 'o'],'markerfacecolor',newcolors(zzz));
        %mns = [ mns; mean(vars.di_signed_init(cellindexes(mygoodcells))) mean(vars.di_signed_init(cellindexes(mygoodcells))+vars.delta_di_signed_overall(mygoodcells))];
        for jjj=1:length(mygoodcells),
                kk=find(vars.indexlookup==mygoodcells(jjj));
                otherindex = find(isnan(vars.di_raw(kk)),1,'first');
                if isempty(otherindex),
                        delta_ts(end+1) = vars.t(kk(end));
                elseif otherindex > 2,
                        delta_ts(end+1) = vars.t(kk(otherindex-1));
                end;
        end;
        %plot(mns(zzz,1),mns(zzz,2),[newcolors(zzz) 'x'],'markersize',12,'markerfacecolor',newcolors(zzz),'linewidth',2.9);
end;
%plot(mns(:,1),mns(:,2),'rx','markersize',12);
plot([-1 1],[0 0],'k--');
plot([0 0 ],[-1 1],'k--');
plot([-1 1],[-1 1],'k--'); % unity line
box off;

disp(['the mean is ' num2str(mean(delta_ts)) '.']);
