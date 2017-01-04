expernames_bd = {'2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07'};
trainingdirs_bd = [ 270 315 0 270 45];
prefix_bd = '/Users/vanhoosr/Desktop/bddir/';

compare_tdr(prefix_bd,expernames_bd,trainingdirs_bd);

expernames_ud = {'2008-01-25'    '2008-03-06'    '2008-03-13'    '2008-03-26'    '2008-06-09'    '2008-09-02'};
trainingdirs_ud = [320    60    45   135   135   180];
prefix_ud = '/Users/vanhoosr/Desktop/unidir/';

figuresavepath = ['/Users/vanhoosr/Desktop/unidiranalysis/'];

compare_tdr(prefix_ud,expernames_ud,trainingdirs_ud);

% unidirectional figure

ud = load('/Users/vanhoosr/Desktop/newferretmtg/unidirectional_variables.mat');
bd = load('/Users/vanhoosr/Desktop/newferretmtg/bidirectional_variables.mat');

 % DIRECTION RATIO BEFORE AND AFTER FOR UNIDIRECTIONAL
figure
plot(ud.tdi{12},ud.tdi{13},'ko');
hold on
plot([0 1],[0 1],'k--');
box off; axis square;
ylabel('DR (\theta_{train}) after')
xlabel('DR (\theta_{train}) before');
title('Unidirectional');
fname = 'DR_beforeafter_uni';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);

 % DIRECTION RATIO BEFORE AND AFTER FOR BIDIRECTIONAL
figure
plot(bd.tdi{12},bd.tdi{13},'ko');
hold on
plot([0 1],[0 1],'k--');
box off; axis square;
ylabel('DR (\theta_{Minority}) after')
xlabel('DR (\theta_{Minority}) before');
title('Bidirectional');
fname = 'DR_beforeafter_bd';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);


 % CHANGE IN DIRECTION RATIO OF MINORITY DIRECTION WITH UNIDIRECTION / BIDIRECTIONAL TRAINING

figure
dtdr_ud = ud.tdi{13}-ud.tdi{12};
dtdr_bd = bd.tdi{13}-bd.tdi{12};
[Xud,Yud] = cumhist(dtdr_ud,[-1 1],1);
[Xbd,Ybd] = cumhist(dtdr_bd,[-1 1],1);
plot(Xud,Yud,'color',[0.3 0.3 0.3]);
hold on
plot(Xbd,Ybd,'b');
plot([-1 1],[50 50],'k--');
plot([0 0],[0 100],'k--');
box off;
xlabel('\Delta DR (\theta_{minority})')
ylabel('Percent of cells');
fname = 'ChangeDR_beforeafter_bdud';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);

 % RAW DIRECTION RATIO OF MONITOR DIRECTION WITH UNIDIRECTION/BIDIRECTIONAL TRAINING

figure
subplot(2,1,1);
[Xbdb,Ybdb] = cumhist(bd.tdi{12},[0 1],1);
[Xbda,Ybda] = cumhist(bd.tdi{13},[0 1],1);
plot(Xbdb,Ybdb,'g');
hold on
plot(Xbda,Ybda,'b');
plot([0 1],[50 50],'k--');
box off;
xlabel('DR (\theta_{minority})')
ylabel('Percent of cells');
title('Bidirectional training');

subplot(2,1,2);
[Xudb,Yudb] = cumhist(ud.tdi{12},[0 1],1);
[Xuda,Yuda] = cumhist(ud.tdi{13},[0 1],1);
plot(Xudb,Yudb,'g');
hold on
plot(Xuda,Yuda,'color',[0.3 0.3 0.3]);
plot([0 1],[50 50],'k--');
box off;
xlabel('DR (\theta_{minority})')
ylabel('Percent of cells');
title('Unidirectional training');

fname = 'DR_beforeafter_bdud';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);

 % LOOK AT LOCAL MATCHING INDEX
sims_ud = load('/Users/vanhoosr/Desktop/mcMapSimCompute_2010single.mat');
simindex_ud = match_sims_to_cells(sims, ud);
goodinds_ud = find(~isnan(simindex_ud{12}));
mylocalmatching_ud = get_localmatching_from_sims(sims,simindex_ud{12}(goodinds_ud));


figure
plot(mylocalmatching_ud*100, ud.tdi{13}(goodinds_ud)-ud.tdi{12}(goodinds_ud),'ko');
hold on
plot([-100 100],[0 0],'k--');
box off;
axis square;
axis([-100 100 -0.5 0.5]);
ylabel('DR (\theta_{training}) before - DR (\theta_{training}) after');
xlabel('Local coherence wrt training angle (100\mum)');
[SLOPE,OFFSET,SLOPE_CONFINTERVAL,RESID, RESIDINT, STATS] = quickregression(mylocalmatching_ud'*100,[ud.tdi{13}(goodinds_ud)-ud.tdi{12}(goodinds_ud)]', 0.05);
plot([-100 100],OFFSET+SLOPE*[-100 100],'k-','linewidth',2);

fname = 'DR_localcoherence_ud';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);

sims_bd = load('/Users/vanhoosr/Desktop/mcMapSimCompute.mat');
simindex_bd = match_sims_to_cells(sims_bd, bd,expernames_bd);
goodinds_bd = find(~isnan(simindex_bd{12}));

mynewlcis = cat(1,bd.lci_before{:});
mynewlmis = cat(1,bd.lci_minority_before{:});

figure
plot(mynewlmis(:,3)*100, bd.tdi{13}(goodinds_bd)-bd.tdi{12}(goodinds_bd),'ko');
hold on
plot([-100 100],[0 0],'k--');
box off;
axis square;
axis([-100 100 -0.5 0.5]);
ylabel('DR (\theta_{minority}) before - DR (\theta_{minority}) after');
xlabel('Local coherence wrt minority angle (100\mum)');
[SLOPE,OFFSET,SLOPE_CONFINTERVAL,RESID, RESIDINT, STATS] = quickregression(mynewlmis(:,3)*100,[bd.tdi{13}(goodinds_bd)-bd.tdi{12}(goodinds_bd)]', 0.05);
plot([-100 100],OFFSET+SLOPE*[-100 100],'k-','linewidth',2);

fname = 'DR_localcoherence_bd';
saveas(gcf,[figuresavepath fname '.fig']);
saveas(gcf,[figuresavepath fname '.ai']);
saveas(gcf,[figuresavepath fname '.pdf']);



% ANOVA ANALYSIS OF LOCAL MATCHING VS. DR(TRAIN_ANGLE)
%

G = [ mylocalmatching(:) ud.experindex(goodinds(:))] ; % (duration) ]


