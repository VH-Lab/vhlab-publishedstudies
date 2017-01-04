function estimateContribs

load('e:\svanhooser\newferretmtg\mcMapSimCompute.mat');

  % for each cell, calculate
  %    change uncertainty
  %    flipping prob
  %    total change in uncertainty of neighbors
  %    total flipping prob of neighbors

dLCIest = [];  
dLCIest2 = [];
dLCIest4 = [];
dLCIact = [];  

for i=1:length(mapnaive),
    myinds = strmatch({mapnaive(i).expername},{mapnaive.expername},'exact');
    inds = setdiff(myinds,i);
    xyothers = cell2mat({mapnaive(inds).pos}');
    dists = sqrt((xyothers(:,1)-mapnaive(i).pos(1)).^2 + (xyothers(:,2)-mapnaive(i).pos(2)).^2);
    myinds = find(dists<=(100*512/240)&~isnan(squeeze(mcsimf(2,inds,1))'));

    if ~isnan(mcsimf(2,i,1)),
        dLCIest(i) = 0;
        dLCIest2(i) = 0;
        dLCIest3(i) = 0;
        dLCIest4(i) = 0;
        [unbi,dummy,dumy,medangbi] = dpuncertainty(squeeze(mcsim(2,i,:)));
        [unai,dummy,dumy,medangai] = dpuncertainty(squeeze(mcsimf(2,i,:)));
        [psamebi,pdiffbi,pdifforibi] = dpuncertaintytot(squeeze(mcsim(2,i,:)));
        [psameai,pdiffai,pdifforiai] = dpuncertaintytot(squeeze(mcsimf(2,i,:)), medangbi);
        [psameai_,pdiffai_,pdifforiai_] = dpuncertaintytot(squeeze(mcsimt(2,i,:)));        
        numGoodNeighbors = 0;
        %if i==102, keyboard; end;
        for j=1:length(myinds),
            numGoodNeighbors = numGoodNeighbors + 1;
            [unbj,dummy,dumy,medangbj] = dpuncertainty(squeeze(mcsim(2,inds(myinds(j)),:)));
            [unaj,dummy,dumy,medangaj] = dpuncertainty(squeeze(mcsimf(2,inds(myinds(j)),:)));
            [psamebj,pdiffbj,pdifforibj] = dpuncertaintytot(squeeze(mcsim(2,inds(myinds(j)),:)), medangbi);
            [psameaj,pdiffaj,pdifforiaj] = dpuncertaintytot(squeeze(mcsimf(2,inds(myinds(j)),:)), medangbi);
            [psameaj_,pdiffaj_,pdifforiaj_] = dpuncertaintytot(squeeze(mcsimt(2,inds(myinds(j)),:)), medangai);
            fpi = fpf(i); fpj = fpf(inds(myinds(j)));
            % old way
            A = (1-unbi)*((angdiff(medangbi-medangbj)<=45)*(1-unbj)+(angdiff(medangbi-medangbj)>135)*(unbj));
            B = (1-unbi)*((angdiff(medangbi-medangbj)>135)*(1-unbj)+(angdiff(medangbi-medangbj)<=45)*(unbj));
            C = (unbi)*  ((angdiff(medangbi-medangbj)>135)*(1-unbj)+(angdiff(medangbi-medangbj)<=45)*(unbj));
            D = (unbi)*  ((angdiff(medangbi-medangbj)<=45)*(1-unbj)+(angdiff(medangbi-medangbj)>135)*(unbj));
            E_1 = (1-unai)*(angdiff(medangbi-medangai)<=45)+(angdiff(medangbi-medangai)>135)*(unai);
            E_2 = (1-unaj)*(angdiff(medangbi-medangaj)<=45)+(angdiff(medangbi-medangaj)>135)*(unaj);
            E = E_1*E_2;
            F_1 = (unai)*(angdiff(medangbi-medangai)<=45)+(angdiff(medangbi-medangai)>135)*(1-unai);
            F_2 = (unaj)*(angdiff(medangbi-medangaj)<=45)+(angdiff(medangbi-medangaj)>135)*(1-unaj);
            F = F_1*F_2;
            G = E_1*F_2;
            H = F_1*E_2;
            % new way
            A = psamebi*psamebj;
            B = psamebi*pdiffbj;
            C = pdiffbi*pdiffbj;
            D = pdiffbi*psamebj;
            E = psameai*psameaj;
            F = pdiffai*pdiffaj;
            G = psameai*pdiffaj;
            H = pdiffai*psameaj;
            AEfp = A*[F+G+H]+E*[B+C+D];
            BGfp = B*[E+F+H]+G*[A+C+D];
            CFfp = C*[E+G+H]+F*[A+B+D];
            DHfp = D*[E+F+G]+H*[A+B+C];
            Sw = A*[F+G+H]+B*[E+F+H]+C*[E+G+H]+D*[E+F+G];
            Unc = A*E + B*G + C*F + D*H;
            
            Poneflips = fpi*(1-fpj)+fpj*(1-fpi);
            Ptwoornoflips = (1-fpi)*(1-fpj)+(fpj*fpi);
            Pdir1eqdir2b = (angdiff(medangbi-medangbj)>135)*(unbi)*(unbj)+(angdiff(medangbi-medangbj)<45)*(1-unbi)*(1-unbj);
            Pdir1neqdir2b = (angdiff(medangbi-medangbj)<45)*(unbi)*(unbj)+(angdiff(medangbi-medangbj)>135)*(1-unbi)*(1-unbj);
            Pdir1eqdir2a = (angdiff(medangai-medangaj)>135)*(unai)*(unaj)+(angdiff(medangai-medangaj)<45)*(1-unai)*(1-unaj);
            Pdir1neqdir2a = (angdiff(medangai-medangaj)<45)*(unai)*(unaj)+(angdiff(medangai-medangaj)>135)*(1-unai)*(1-unaj);
            dLCIest(i) = dLCIest(i) + (E+F-G-H)-((A+C)-(B+D)) + 0*((angdiff(medangbi-medangbj)>135)-(angdiff(medangbi-medangbj)<45))*Poneflips;
            dLCIest2(i) = dLCIest2(i) + Unc*(E-A+F-C-G+B-H+D); % terms without flipping
            dLCIest3(i) = dLCIest3(i) + Sw*(E-A+F-C-G+B-H+D);  % terms with flipping
            dLCIest4(i) = dLCIest4(i) +psameaj_-pdiffaj_-(psamebj-pdiffbj);
                
        end;
        dLCIest(i) = dLCIest(i)/numGoodNeighbors;
        dLCIest2(i) = dLCIest2(i)/numGoodNeighbors;
        dLCIest3(i) = dLCIest3(i)/numGoodNeighbors;
        dLCIest4(i) = dLCIest4(i)/numGoodNeighbors;
    else, dLCIest(i)=NaN; dLCIest2(i) = NaN; dLCIest3(i) = NaN; dLCIest4(i) = NaN;
    end;
    dLCIact(i) = lbadf(i,2,2) - lbbd(i,2,2);
end;

figure;
plot([-100 100],[-100 100],'k-'); hold on;
plot([-100 100],[0 0],'k-');
plot([0 0],[-100 100],'k-');
plot(100*dLCIact,100*dLCIest,'k.');

xlabel('Actual \deltaLCI'); ylabel('Predicted \deltaLCI');
%%[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(dLCIact,dLCIest,0.05);


figure;
plot([-100 100]/sqrt(2),[-100 100]/sqrt(2),'k-'); hold on;
plot([-100 100],[0 0],'k-');
plot([0 0],[-100 100],'k-');
plot([50 50],[-5 5]*0.5,'k-');
plot([100 100],[-5 5]*0.5,'k-');
plot([-50 -50],[-5 5]*0.5,'k-');
plot([-100 -100],[-5 5]*0.5,'k-');
plot([-5 5]*0.5,[50 50],'k-');
plot([-5 5]*0.5,[100 100],'k-');
plot([-5 5]*0.5,[-50 -50],'k-');
plot([-5 5]*0.5,[-100 -100],'k-');
off = [0 2.5]*[cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];
plot([50 50]/sqrt(2)+[off(1) -off(1)],[50 50]/sqrt(2)+[-off(2) off(2)],'k-');
plot([100 100]/sqrt(2)+[off(1) -off(1)],[100 100]/sqrt(2)+[-off(2) off(2)],'k-');
plot(-[100 100]/sqrt(2)+[off(1) -off(1)],-[100 100]/sqrt(2)+[-off(2) off(2)],'k-');
plot(-[50 50]/sqrt(2)+[off(1) -off(1)],-[50 50]/sqrt(2)+[-off(2) off(2)],'k-');


plot(100*dLCIest2,100*dLCIest3,'k.'); hold on;
xlabel('\DeltaLCI due to \Deltauncertainty (%)'); ylabel('\DeltaLCI due to switching (%)');
box off; axis off; axis equal;

G = find(~isnan(dLCIest4));
D=dLCIest4(G)-dLCIest2(G)-dLCIest3(G); DM = dLCIest4(G);
sum(D.^2)/sum(DM.^2)
D1=dLCIact(G)-dLCIest2(G);
D2=dLCIact(G)-dLCIest3(G);
100*(nanmean(dLCIest4)-nanmean(dLCIest2)-nanmean(dLCIest3))/nanmean(dLCIest4)
100*(nanmean(dLCIest2))/nanmean(dLCIest4)
100*(nanmean(dLCIest3))/nanmean(dLCIest4)

keyboard;