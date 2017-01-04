function [mapstrength,mapstrengtht,mapstrengthMC,mapstrengthtMC,BSmapstrength,BSmapstrengtht,BSmapstrengthMC,BSmapstrengthtMC]...
    = ComputeMapStrengthNEWwoBS2(prefix,expnames,traindir,recalculate)

%prefix = 'E:\2photon\ferretdirection\Dark rearing\'; 
%expnames = {'2008-09-17'};
%traindir = [0];

% for unidirection
  prefix = 'E:\2photon\ferretdirection\Single direction\'; 
  expnames = {'2007-11-30','Copy of 2008-01-25','2008-02-20','2008-03-06','2008-03-11','2008-03-13','2008-03-26','2008-06-09','2008-09-02','Copy of 2008-01-25'};
  traindir = [350 320 45 60 180 45 135 135 180 320];
  trainhour = [3 3.5 4 3 1 4 3 3 6 3.5];
  trainway = {'un','un','un','un','un','un','un','un','un','un'};
% expnames = {'2007-11-30','2008-02-20'};
% traindir = [350 45]; trainhour = [3 4]; trainway = {'un','un'};
    
%recalculate = 0, plotit = 1; 
% for darkrearing
% prefix = 'E:\2photon\ferretdirection\Dark rearing\'; 
% expnames ={'2008-06-18','2008-06-19','2008-06-24','2008-06-25','2008-09-15','2008-09-17','2009-03-04','2009-03-18',...
%     '2008-06-17','2008-07-22','2008-09-16','2009-02-02','2009-02-03','2009-03-02','2008-08-05','2008-08-07','2009-02-11','2009-02-12','2009-03-17','2009-03-03'};
% traindir = [135 45 0 0 22.5 0 45 0 160 0 0 0 0 0 0 0 90 60 0 120];
% trainhour = [3 3 0 3 4.5 4 4 0 1 0 0 0 0 0 0 0 4 2 0 5];
% trainway = {'bi','bi','no','bi','un','un','bi','no','bi','no','no','no','no','no','no','no','un','un','no','un'};

% for bidirection
% prefix = 'E:\2photon\ferretdirection\newminis\';
% expnames ={'2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07'};
% traindir = [0 0 0 45 45]; % need clarify

% for normal eyeopen>7days
% prefix = 'E:\2photon\ferretdirection\';
%expnames
%={'2006-11-29','2007-05-01','2007-06-05','2006-08-17','2007-11-30'};
% some of the exps are in newmins folder

% if recalculate,
    
for I=9, %1:length(expnames),
    tpf = [prefix expnames{I}],
    ds = dirstruct(tpf);
    [cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    stacknames = findallstacks(ds), if length(stacknames)>1, error('more than 1 stack'); end;
    eyesopen = findassociate(cells{1},'Eyes open','',''); eyesopen = eyesopen.data,
    darkrearing = findassociate(cells{1},'Dark reared','','');
    if ~isempty(darkrearing),darkrearing = darkrearing.data,else darkrearing = 0,end;
    
    trainangle = traindir(I), traintime = trainhour(I),traintype = trainway{I},

    for J=1:length(stacknames),
        mycells = selectstackcells(ds,stacknames{J});
        disp(['Total cells:' num2str(length(mycells))]);
        mycellnumber = []; di = []; ot = []; dp = []; dib = []; dia = []; dpb = []; dpa = []; xyloc = [];
        ratio2b = []; ratio2a = [];ratiorb = []; ratiora = []; dibsign = []; diasign = [];
        respb1 = []; respa1 = []; respave1 = []; respb2 = []; respa2 = []; respave2 = [];
        respmaxb = []; respmaxa = [];
        incl = []; 
        
        trained = []; dit = []; ott = []; dpt = []; otb = []; ota = []; mpb = []; mpa = [];
        fracgood = []; fracgoodt = []; fracgoodb = []; fracgooda = [];
        BSfits = []; BSfitst = []; BSfitsb = []; BSfitsa = [];
        mapstrength = {}; mapstrengtht = {}; mapstrengthMC = {}; mapstrengthtMC = {}; 
        BSmapstrength = {}; BSmapstrengtht = {}; BSmapstrengthMC = {}; BSmapstrengthtMC = {};
        TMb = []; TMa = []; mpb = []; mpa = []; 
        afteronly = []; beforeonly = []; beforeafter = [];

        
        for z=1:length(mycells),
            pvalasoc = findassociate(mycells{z},'TP Ach OT vec varies p','','');
            pvalasoct = findassociate(mycells{z},'TP ME Ach OT vec varies p','','');
%             pvalasoc.data,
%             pvalasoct.data,
            if (~isempty(pvalasoc)&& pvalasoc.data<0.05)||(~isempty(pvalasoct)&& pvalasoct.data<0.05),
                incl(end+1)=z;
                length(incl),
                mycellnumber = [mycellnumber cellnames(z)];           
                diassoc = findassociate(mycells{z},'TP Ach OT Carandini Fit Params','','');
                diassoct = findassociate(mycells{z},'TP ME Ach OT Carandini Fit Params','','');
                dirassoc = findassociate(mycells{z},'TP Ach OT Fit Direction index blr','','');
                dirassoct = findassociate(mycells{z},'TP ME Ach OT Fit Direction index blr','','');
                otassoc = findassociate(mycells{z},'TP Ach OT Orientation index','','');
                otassoct = findassociate(mycells{z},'TP ME Ach OT Orientation index','','');
                pixassoc = findassociate(mycells{z},'pixellocs','','');
                BSf = findassociate(mycells{z},'TP Ach OT Bootstrap Carandini Fit Params','','');
                BSft = findassociate(mycells{z},'TP ME Ach OT Bootstrap Carandini Fit Params','','');
                BS = findassociate(mycells{z},'TP Ach OT Bootstrap Individual Responses','','');
                BSme = findassociate(mycells{z},'TP ME Ach OT Bootstrap Individual Responses','','');
                
                xyloc{end+1}=[mean(pixassoc.data.x) mean(pixassoc.data.y)];
                
                %only after
                if isempty(pvalasoc)||isnan(pvalasoc.data)|| (~isempty(pvalasoc)&& pvalasoc.data>=0.05),
                    afteronly = [afteronly cellnames(z)];
                    %before
                    di(end+1) = NaN; dp(end+1) = NaN; BSfits(:,end+1) = NaN(100,1);
                    ratio2b(end+1) = NaN;ratiorb(end+1) = NaN; dibsign(end+1) = NaN;  
                    respb1(end+1) = NaN; respb2(end+1) = NaN; respave1(end+1) = NaN; respave2(end+1) = NaN; 
                    respmaxb(end+1) = NaN;  
                    TMb(end+1) = NaN;
                    mpb(end+1) = NaN;
                    %after
                    dit(end+1) = dirassoct.data; dpt(end+1) = diassoct.data(3); BSfitst(:,end+1) = BSft.data(:,3);
%                     ratio2a(end+1) = diratio1woBS(diassoct.data(2),diassoct.data(5),diassoct.data(3),traindir(I),0,1,0);
                    if angdiffwrap(diassoct.data(3)-traindir(I),360)<90,
                        diasign(end+1) = dirassoct.data; ratio2a(end+1) =1/(2-dirassoct.data);
                    else,diasign(end+1) = -dirassoct.data; ratio2a(end+1) =(1-dirassoct.data)/(2-dirassoct.data);
                    end;
                    [Rp,Rt1,Rt2] = newferretdi4(mycells{z}, 0, 1, traindir(I),BSme.data); %have problem!!! in the mac laptop 
                    respa1(end+1) = Rt1; respa2(end+1) = Rt2;
                    respmaxa(end+1) = Rp; 
                    TMa(end+1) = dirassoct.data.*cosd(diassoct.data(3)-traindir(I));
                    mpa(end+1) = matchingprob(BSft.data(:,3), traindir(I));
                end;
                %only before
                if isempty(pvalasoct)||isnan(pvalasoct.data)||(~isempty(pvalasoct)&& pvalasoct.data>=0.05), 
                    beforeonly = [beforeonly cellnames(z)];
                    %after
                    dit(end+1) = NaN; dpt(end+1) = NaN; DISt = NaN; BSfitst(:,end+1) = NaN(100,1);
                    ratio2a(end+1) = NaN;ratiora(end+1) = NaN;diasign(end+1) = NaN;
                    respa1(end+1) = NaN; respa2(end+1) = NaN; respave1(end+1) = NaN; respave2(end+1) = NaN; 
                    respmaxa(end+1) = NaN;  
                    TMa(end+1) = NaN;
                    mpa(end+1) = NaN;
                    %before
                    di(end+1) = dirassoc.data;dp(end+1) = diassoc.data(3); BSfits(:,end+1) = BSf.data(:,3);
                    %ratio2b(end+1) = diratio1woBS(diassoc.data(2),diassoc.data(5),diassoc.data(3),traindir(I),0,1,0);
                    if angdiffwrap(diassoc.data(3)-traindir(I),360)<90,
                        dibsign(end+1) = dirassoc.data;ratio2b(end+1) =1/(2-dirassoc.data);
                    else,dibsign(end+1) = -dirassoc.data;ratio2b(end+1) =(1-dirassoc.data)/(2-dirassoc.data);
                    end;
                    [Rp,Rt1,Rt2] = newferretdi4(mycells{z}, 1, 1, traindir(I),BS.data);
                    respb1(end+1) = Rt1; respb2(end+1) = Rt2;
                    respmaxb(end+1) = Rp; 
                    TMb(end+1) = dirassoc.data.*cosd(diassoc.data(3)-traindir(I));
                    mpb(end+1) = matchingprob(BSf.data(:,3), traindir(I));
                 end;
                %before and after
                if ~isempty(pvalasoc)&&~isempty(pvalasoct)&& pvalasoc.data<0.05 && pvalasoct.data<0.05 
                    beforeafter = [beforeafter cellnames(z)];
                    di(end+1) = dirassoc.data;dp(end+1) = diassoc.data(3);
                    dit(end+1) = dirassoct.data; dpt(end+1) = diassoct.data(3);
                    BSfits(:,end+1) = BSf.data(:,3); BSfitst(:,end+1) = BSft.data(:,3);
                    %ratio2b(end+1) = diratio1woBS(diassoc.data(2),diassoc.data(5),diassoc.data(3),traindir(I),0,1,0);
                    %ratio2a(end+1) = diratio1woBS(diassoct.data(2),diassoct.data(5),diassoct.data(3),traindir(I),0,1,0);
                    if angdiffwrap(diassoc.data(3)-traindir(I),360)<90,
                        dibsign(end+1) = dirassoc.data;ratio2b(end+1) =1/(2-dirassoc.data);
                    else,dibsign(end+1) = -dirassoc.data;ratio2b(end+1) =(1-dirassoc.data)/(2-dirassoc.data);
                    end;
                    if angdiffwrap(diassoct.data(3)-traindir(I),360)<90,
                        diasign(end+1) = dirassoct.data; ratio2a(end+1) =1/(2-dirassoct.data);
                    else,diasign(end+1) = -dirassoct.data; ratio2a(end+1) =(1-dirassoct.data)/(2-dirassoct.data);
                    end;
                    [Rp,Rt1,Rt2] = newferretdi4(mycells{z}, 1, 1, traindir(I),BS.data);
                    respb1(end+1) = Rt1; respb2(end+1) = Rt2;
                    respmaxb(end+1) = Rp; 
                    [Rp,Rt1,Rt2] = newferretdi4(mycells{z}, 0, 1, traindir(I),BSme.data);
                    respa1(end+1) = Rt1; respa2(end+1) = Rt2;
                    respmaxa(end+1) = Rp; 
                    respave1(end+1) = (respb1(end)+respa1(end))/2; respave2(end+1) = (respb2(end)+respa2(end))/2;
                    TMb(end+1) = dirassoc.data.*cosd(diassoc.data(3)-traindir(I));
                    TMa(end+1) = dirassoct.data.*cosd(diassoct.data(3)-traindir(I));
                    mpb(end+1) = matchingprob(BSf.data(:,3), traindir(I));
                    mpa(end+1) = matchingprob(BSft.data(:,3), traindir(I));
                    %respb1: response amplitude to train direction (closetest peak within 45 degree) before training
                    %respb2: response amplitude to train direction (actual fitting point) before training
                    %respmaxb: response amplitude to prefered diection (maximal response) before training
                    
                end; 
                %keyboard;
            end; % if some data
        end; % loop over cells
%keyboard;
       %mapstrength = [];
        for z=1:length(mycellnumber),
            
            myinds = 1:1:length(mycellnumber);
            inds = setdiff(myinds,z);
            myxy = cell2mat(xyloc(z)');
            xyothers = cell2mat(xyloc(inds)');
            dpothers = dp(inds); dpotherst = dpt(inds);
            dists = [0:10:250] * 512/242;
            if z==1, save(['E:\svanhooser\woBS5\yevars' expnames{I} '.mat'],'myinds','inds','myxy','xyothers','dpothers','dpotherst','dp','z','dists','dpt','trainangle','BSfits'); end;
            %keyboard;
            mapstrength{end+1} = localdirbiasNEW(dp(z),myxy,dpothers,xyothers, dists,1,1);   
            mapstrengtht{end+1} = localdirbiasNEW(dpt(z),myxy,dpotherst,xyothers, dists,1,1);
            mapstrengthMC{end+1} = localdirbiasNEW(trainangle,myxy,dpothers,xyothers, dists,1,1);   
            mapstrengthtMC{end+1} = localdirbiasNEW(trainangle,myxy,dpotherst,xyothers, dists,1,1);
            for i = 1:length(BSfits(:,1))
                BSmapstrength{i,z} = localdirbiasNEW(BSfits(i,z),myxy,BSfits(i,inds),xyothers, dists,1,1);
                BSmapstrengtht{i,z} = localdirbiasNEW(BSfitst(i,z),myxy,BSfitst(i,inds),xyothers, dists,1,1);
                BSmapstrengthMC{i,z} = localdirbiasNEW(trainangle,myxy,BSfits(i,inds),xyothers, dists,1,1);
                BSmapstrengthtMC{i,z} = localdirbiasNEW(trainangle,myxy,BSfitst(i,inds),xyothers, dists,1,1);
            end;
        end;      % loop over cells

    end; % loop over stacks

    save(['E:\svanhooser\woBS5\BSmapstrength' filesep expnames{I} '.mat'],...
         'mapstrength','mapstrengtht','mapstrengthMC','mapstrengthtMC','BSmapstrength','BSmapstrengtht','BSmapstrengthMC','BSmapstrengthtMC',...
         'dists');
     
    for i = 1:2,
         lbnew = [];
         if i==1, BSmapstrengthv = BSmapstrength; BSmapstrengthtv = BSmapstrengtht;
         elseif i==2, BSmapstrengthv = BSmapstrengthMC; BSmapstrengthtv = BSmapstrengthtMC; end;
         figure;
         %before
         subplot(2,2,1);
         lbnew = [];
         for m=1:size(BSmapstrengthv,2)
             mylbnew = [];
             mylbnew = [mylbnew BSmapstrengthv{:,m}];
             mylbnew = reshape(mylbnew,26,100)';
             lbnew(m,:) = nanmean(cell2mat(mylbnew));
             plot(dists/(512/242),nanmean(cell2mat(mylbnew)),'kp');hold on;
         end;
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         
         lbnewmean = []; lbnewse = [];
         
         %for n=1:length(dists)
         lbnewmean = nanmean(lbnew);
         lbnewse = nanstd(lbnew);
         %end;
         subplot(2,2,2);errorbar(dists/(512/242), lbnewmean,lbnewse,'ko');title('before');
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         if i==1, BSlbib = lbnew';BSlbib100 = nanmean(BSlbib((1:10),:));
         else BSlmib = lbnew';BSlmib100 = nanmean(BSlmib((1:10),:));end;
         
         %aftet
         subplot(2,2,3);
         lbnewt = [];
         for m=1:size(BSmapstrengthtv,2)
             mylbnew = [];
             mylbnew = [mylbnew BSmapstrengthtv{:,m}];mylbnew = reshape(mylbnew,26,100)';
             lbnewt(m,:) = nanmean(cell2mat(mylbnew));
             plot(dists/(512/242),nanmean(cell2mat(mylbnew)),'kp');hold on;
         end;
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         lbnewtmean = []; lbnewtse = [];
         %for n=1:length(dists)
         lbnewtmean = nanmean(lbnewt);
         lbnewtse = nanstd(lbnewt);
         %end;
         %keyboard;
         subplot(2,2,4);errorbar(dists/(512/242), lbnewtmean,lbnewtse,'ko');title('after');
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         if i==1, BSlbia = lbnew';BSlbia100 = nanmean(BSlbia((1:10),:));
         else BSlmia = lbnew';BSlmia100 = nanmean(BSlmia((1:10),:));end;
     end;
     
     for i = 1:2,
         lbnew = [];
         if i==1, mapstrengthv = mapstrength; mapstrengthtv = mapstrengtht; 
         elseif i==2, mapstrengthv = mapstrengthMC; mapstrengthtv = mapstrengthtMC; end;
         figure;
         %before
         subplot(2,2,1);
         lbnew = [];
         for m=1:size(mapstrengthv,2)
             %         base = 180; mydiff = mod(angdiff(dp(m)-traindir),base);
             lbnew = [lbnew cell2mat(mapstrengthv{1,m})'];
             plot(dists/(512/242),cell2mat(mapstrengthv{1,m}),'kp');hold on;
         end;
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         lbnewmean = []; lbnewse = [];lbnew = lbnew';
         
         %for n=1:length(dists)
         lbnewmean = nanmean(lbnew);
         lbnewse = nanstd(lbnew);
         %end;
         
         subplot(2,2,2);errorbar(dists/(512/242), lbnewmean,lbnewse,'ko');title('before');
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         %aftet
         subplot(2,2,3);
         lbnewt = [];
         for m=1:size(mapstrengthtv,2)
             %        base = 180; mydiff = mod(angdiff(dp(m)-traindir),base);
             lbnewt = [lbnewt cell2mat(mapstrengthtv{1,m})'];
             plot(dists/(512/242),cell2mat(mapstrengthtv{1,m}),'kp');hold on;
         end;
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
         lbnewtmean = []; lbnewtse = [];lbnewt = lbnewt';
         %keyboard;
         %for n=1:length(dists)
         lbnewtmean = nanmean(lbnewt);
         lbnewtse = nanstd(lbnewt);
         %end;
         %keyboard;
         subplot(2,2,4);errorbar(dists/(512/242), lbnewtmean,lbnewtse,'ko');title('after');
         hold on; plot([0 260],[0 0],'k--');axis([0 260 -1 1]);
     end;


save(['E:\svanhooser\woBS5' filesep expnames{I} '_mapstrengthNEW2.mat'],'mycellnumber','eyesopen','darkrearing',...
        'di','dp','dit','dpt','mpb','mpa','ratio2b','ratio2a','dibsign','diasign','xyloc',...
        'respb1', 'respa1', 'respave1', 'respb2', 'respa2', 'respave2', 'respmaxb', 'respmaxa',...
        'mapstrength','mapstrengtht','mapstrengthMC','mapstrengthtMC',...
        'BSlbib','BSlbia','BSlmib','BSlmia','BSlbib100','BSlbib100','BSlbia100','BSlmib100','BSlmia100',...
        'TMb','TMa','mpb','mpa','expnames','stacknames','trainangle','traintime','traintype','dists','incl','cellnames','beforeonly','afteronly','beforeafter');
  
end;



