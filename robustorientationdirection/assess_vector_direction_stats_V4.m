%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 1: Demonstrate how the tool works
% 2/24/13: In this version (V4) I'm going to focus on my new statistic, which I call 'p_vecmags'. It's a method where I look at the
% 'direction magnitude' on each trial, where one trial = one measurement at each angle. The statistic asks: What is the probability that the
% direction magnitudes overlap zero?

% Things to try here:
% (1) Make 'expected_response' flat (no change in response) --> see what fraction show significance. In theory, the answer should equal
% alpha (which is set to 0.05 -- you can change this below if you like).
expected_response = [2 2 2 2 2 2 2 2];

% (2) Give 'expected_response' a direction-selective response --> see what you get for preferred direction and p values
%expected_response = [2 5 2 2 2 2 2 2];

% (3) Also: Observe what happens when you change ntrials. A nice feature of the direction magnitude statistic is that it seems to be
% insensitive to increases or decreases in number of trials.

angles = [0 45 90 135 180 225 270 315];


%%%%% Simulate data from multiple cells
ncells = 5000;

ntrials = 10;
% Number of stimulus reps per cell
nrep = [];

spontaneous = min(expected_response);

noise = 'scaled';
% noise = eps;
% Enter 'scaled' if you want variance to be equal to the expected resposne
% Otherwise, the number you enter will be used as the standard dev of the response

prefdir = nan*ones(ncells,1);
p_rep = nan*ones(ncells,1);
p_ori_rep = nan*ones(ncells,1);
p_rev_rep = nan*ones(ncells,1);
p_vecmags_rep = nan*ones(ncells,1);
for i_rep = 1:ncells
  %%%%
  % Simulate responses
  if(isstr(noise))
    if(strmatch(noise,'scaled'))
      noise = sqrt(expected_response);
    end
  end
  
  response_mtx = nan*ones(ntrials,length(angles));
  for i_trial = 1:ntrials
    response_mtx(i_trial,:) = normrnd(expected_response,noise);
  end
  
  [prefdir(i_rep) p_rep(i_rep) p_rev_rep(i_rep) p_ori_rep(i_rep) p_vecmags_rep(i_rep) vectors vectormags vectormags_scaled] = ...
    calc_direction_stats_vectormethod_V2(angles,response_mtx,spontaneous,nrep);
  % Steve: "p_vecmags_rep" is the statistic of choice, I think. See below.
  
% Perform the bootstrap
%   predictor = angles;
%   trialdata = response_mtx;
%   niter = 100;
%   simdataflag = 0;
% 
%   da = median(diff(angles));
%   meanresp = mean(response_mtx);
%   [maxresp,if0]=max(meanresp);
%   minresp = min(meanresp);
%   otpref = angles(if0);
%   extraparams = {[da/2 da 40 60 90], predictor, 0, maxresp, otpref, 'widthseeddummywillbereplaced', 'widthint' ,[da/2 180],...
%     'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[minresp maxresp]};
%   verbose = 0;
%   [parammtx,datamtx, extraout] = resampparams_MC('otfit_carandini',predictor,trialdata,niter,simdataflag,extraparams,verbose);

%   figure,clf,hold on
%   plot(vectors(:,1),vectors(:,2),'o')
%   plot(get(gca,'XLim'),[0 0],'k-')
%   plot([0 0],get(gca,'YLim'))
%   
%   figure,hist(vectormags_scaled)
end

alpha = 0.05;
fprintf(sprintf('\nFraction of cells showing orientation selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_ori_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing direction selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_rev_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing direction selectivity by vector magnitude test = %.2f\n',mean(p_vecmags_rep<alpha)),1)

prev_orisel = p_rev_rep(p_ori_rep<alpha);
fprintf(sprintf('\nFraction of ORI-SELECTIVE cells showing direction selectivity by direction reversal test = %.2f\n',mean(prev_orisel<alpha)),1)

figure
hist(p_vecmags_rep)

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 2: Apply tool to data

load data4mark_1
load data4mark_2
cellnames = cat(2,cellnames_1,cellnames_2);
structlist = cat(2,structlist_1,structlist_2);

click = [];
ncells = length(structlist);

nrep = [];

% For each cell, I'll extract the p value obtained from the bootstrap procedure for the probability that the cell's direction preference is
% opposite that obtained from the Carandini fit; save it as 'p_reverse_bs'
p_reverse_bs = nan*ones(ncells,1);

% Next I'll use the new vector tool to calculate three things:
% (1) The preferred direction for that cell as determined by the average vector obtained in individual trials. Save as 'prefdir_vect'.
% (2) A p value for direction selectivity, obtained from Hotelling's T^2 test performed . Save as 'p_selective_vect'.
% (3) A p value for the probability of direction reversal. Save as 'p_reverse_vect'.
prefdir_vect = nan*ones(ncells,1);
p_dirselective_vect = nan*ones(ncells,1);
p_reverse_vect = nan*ones(ncells,1);
p_oriselective_vect = nan*ones(ncells,1);
p_vectormag_vect = nan*ones(ncells,1);
cellnum = nan*ones(ncells,1);

all_response_curves = {};

for i_cell = 1:ncells
  cell2analyze = i_cell;
  cellnum(i_cell) = i_cell;

  cell = structlist{cell2analyze};
  if(length(cell)==0)
    continue;
  end
  
  beforeResponse = find(strcmp({structlist{cell2analyze}.type},'TP Ach OT Response struct'));
  if (length(beforeResponse)==0)
    continue;
  end;
 
  q = cell(beforeResponse);
  angles = q.data.curve(1,:);  
  
  response_mtx = cell2mat(q.data.ind);
  spont = q.data.spont(1);
  nanind = any(isnan(response_mtx'))';
  response_mtx(nanind,:) = [];

  if(size(response_mtx,1)<3)
    continue;
  end
  
  [prefdir_vect(i_cell) p_dirselective_vect(i_cell) p_reverse_vect(i_cell) p_oriselective_vect(i_cell) p_vectormag_vect(i_cell)] = ...
    calc_direction_stats_vectormethod_V2(angles,response_mtx,spont,nrep);
  
  all_response_curves{i_cell} = q.data.curve;

  % calculate the 'direction uncertainty', or the chance the direction is opposite the best fit
  beforeBS = find(strcmp({structlist{cell2analyze}.type},'TP Ach OT Bootstrap Carandini Fit Params'));
  if ~isempty(beforeBS)
     beforeBSangles = structlist{cell2analyze}(beforeBS).data(:,3);
     p_reverse_bs(i_cell) = dpuncertainty(beforeBSangles);
  else
     p_reverse_bs(i_cell) = NaN;
  end;
  

  % calculate the chance that the cell reversed as a consequence of training
  afterBS = find(strcmp({structlist{cell2analyze}.type},'TP ME Ach OT Bootstrap Carandini Fit Params'));
  if ~isempty(beforeBS) & ~isempty(afterBS),
     afterBSangles = structlist{cell2analyze}(afterBS).data(:,3);
     p_trainingreverse_bs(i_cell) = flippingprob(beforeBSangles,afterBSangles);
  else
     p_trainingreverse_bs(i_cell) = NaN;
  end;
    
end

figure;
plot(p_vectormag_vect,p_reverse_bs,'ko');
ylabel('DP uncertainty BS');
xlabel('P value of vector magnitude T test');
title('All cells');
box off;

ori_selective = find(p_oriselective_vect<alpha); % find subset of orientation-selective cells
figure;
plot(p_vectormag_vect(ori_selective),p_reverse_bs(ori_selective),'bo');
ylabel('DP uncertainty BS');
xlabel('P value of vector magnitude T test');
title('Cells that pass Hotelling''s T^2 test in orientation space');
set(gca,'ButtonDownFcn','[click,clickpt]=findclosestpointclick([p_dirselective_vect(ori_selective) p_reverse_bs(ori_selective)]); plotcurve=all_response_curves{ori_selective(click)}; figure; EB=errorbar(plotcurve(1,:),plotcurve(2,:),plotcurve(4,:),plotcurve(4,:));box off;title([''Cell number '' int2str(ori_selective(click)) ''; Hotelling '' num2str(clickpt(1)) '', BS '' num2str(clickpt(2))]);');
box off;


fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing orientation selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_oriselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_dirselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by vector magnitude test = %.2f\n',mean(p_vectormag_vect<alpha)),1)
pvecmag_orisel = p_vectormag_vect(p_oriselective_vect<alpha);
fprintf(sprintf('\nVECTOR METHOD: Fraction of ORI-SELECTIVE cells showing direction selectivity by vector magnitude test = %.2f\n',mean(pvecmag_orisel<alpha)),1)

fprintf(sprintf('\nBOOTSTRAP: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_bs<alpha)),1)

return
cell2inspect = 775
cell = structlist{cell2inspect};
beforeResponse = find(strcmp({structlist{cell2inspect}.type},'TP Ach OT Response struct'));
q = cell(beforeResponse);
if(~isempty(q))
  angles = q.data.curve(1,:);
  response_mtx = cell2mat(q.data.ind);
  spont = q.data.spont(1);
  nanind = any(isnan(response_mtx'))';
  response_mtx(nanind,:) = [];
  
  all_response_curves = q.data.curve;
  plotcurve = all_response_curves;

  figure(100),hold on;
  plot(angles,response_mtx,'k.-')
  EB=errorbar(plotcurve(1,:),plotcurve(2,:),plotcurve(4,:),plotcurve(4,:));
  box off
  
  [q q q q vectors vectormags] = calc_direction_stats_vectormethod(angles,response_mtx,spont);
  figure(101),hold on
  plot(vectors(:,1),vectors(:,2),'o')
  plot(get(gca,'XLim'),[0 0],'k-')
  plot([0 0],get(gca,'YLim'),'k-')
  title('Trial vectors')
  set(gca,'ButtonDownFcn','[click,clickpt]=findclosestpointclick([vectors(:,1) vectors(:,2)]);figure(102),clf;plot(angles,response_mtx(click,:));title(''Responses from the selected trial'');')
end

