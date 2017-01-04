% Hey Steve, here's a script that walks you through three aspects of evaluating the vector approach for assessing directionality. You may
% want to break these into separate scripts so you can test each section with different values.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 1: Convince you that vector magnitudes show a Gaussian distribution

%%%%% Simulate data from one cell
angles = [0 45 90 135 180 225 270 315];
ntrials = 10000;

expected_response = [2 10 2 2 2 2 2 2];
spontaneous = 2;
noise = 'scaled';

if(isstr(noise))
  if(strmatch(noise,'scaled'))
    noise = sqrt(expected_response);
  end
end

response_mtx = nan*ones(ntrials,length(angles));
for i_trial = 1:ntrials
  response_mtx(i_trial,:) = normrnd(expected_response,noise);
end

%%%%% Run the data through the analysis tool
[q q q q q vectormags vectormags_scaled] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous);

% First, observe that the vector magnitudes are *nearly* Gaussian, but not quite...why not? Because vector magnitudes are constrained to
% fall in the range [-1 1]
figure
hist(vectormags,20)

% Now observe that we obtain a truly Gaussian distribution when we rescale the magnitudes
figure
hist(vectormags_scaled,20)
% This is the distribution that is used to calculate the probability that the direction is reverse of what we measured.
% By the way, how are magnitudes rescaled?? See 'calc_direction_stats_vectormethod' for details. Quick version: (1) Rescale values to [0 1];
% (2) Perform logit transformation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 2: Demonstrate how the tool works
% In this section, you'll get a histogram of preferred direction from each cell and a text stating the fraction of cells showing
% significance under each of the two tests performed by the vector analysis tool (i.e., Hotelling's test and the direction reversal test)

% Things to try here:
% (1) Make 'expected_response' flat (no change in response) --> see what fraction show significance. In theory, the answer should equal
% alpha (which is set to 0.05 -- you can change this below if you like).
 expected_response = [2 2 2 2 2 2 2 2];

% (2) Give 'expected_response' a direction-selective response --> see what you get for preferred direction and p values
%expected_response = [2 5 2 2 2 2 2 2];


angles = [0 45 90 135 180 225 270 315];


%%%%% Simulate data from multiple cells
ncells = 5000;

ntrials = 100;
% Number of stimulus reps per cell

spontaneous = min(expected_response);

noise = 'scaled';
% noise = eps;
% Enter 'scaled' if you want variance to be equal to the expected resposne
% Otherwise, the number you enter will be used as the standard dev of the response

prefdir = nan*ones(ncells,1);
p_rep = nan*ones(ncells,1);
p_ori_rep = nan*ones(ncells,1);
prev_rep = nan*ones(ncells,1);
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
  
  [prefdir(i_rep) p_rep(i_rep) prev_rep(i_rep) p_ori_rep(i_rep)] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous);
end

figure
hist(prefdir)

alpha = 0.05;
fprintf(sprintf('\nFraction of cells showing orientation selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_ori_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing direction selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(prev_rep<alpha)),1)

prev_orisel = prev_rep(p_ori_rep<alpha);
fprintf(sprintf('\nFraction of ORI-SELECTIVE cells showing direction selectivity by direction reversal test = %.2f\n',mean(prev_orisel<alpha)),1)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 3: Apply tool to data

load data4mark_1
load data4mark_2
cellnames = cat(2,cellnames_1,cellnames_2);
structlist = cat(2,structlist_1,structlist_2);

ncells = length(structlist);

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

all_response_curves = {};

for i_cell = 1:ncells
  cell2analyze = i_cell;

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
  
  [prefdir_vect(i_cell) p_dirselective_vect(i_cell) p_reverse_vect(i_cell) p_oriselective_vect(i_cell)] = calc_direction_stats_vectormethod(angles,response_mtx,spont);
  
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

Lnan = isnan(p_dirselective_vect);
p_dirselective_vect(Lnan) = [];
p_reverse_bs(Lnan) = [];
p_reverse_vect(Lnan) = [];
p_oriselective_vect(Lnan) = [];


figure;
plot(p_dirselective_vect,p_reverse_bs,'ko');
ylabel('DP uncertainty BS');
xlabel('P value of Hotelling''s T^2 test');
title('All cells');
box off;

ori_selective = find(p_oriselective_vect<alpha); % find subset of orientation-selective cells
figure;
plot(p_dirselective_vect(ori_selective),p_reverse_bs(ori_selective),'bo');
ylabel('DP uncertainty BS');
xlabel('P value of Hotelling''s T^2 test');
title('Cells that pass Hotelling''s T^2 test in orientation space');
set(gca,'ButtonDownFcn','[click,clickpt]=findclosestpointclick([p_dirselective_vect(ori_selective) p_reverse_bs(ori_selective)]); plotcurve=all_response_curves{ori_selective(click)}; figure; EB=errorbar(plotcurve(1,:),plotcurve(2,:),plotcurve(4,:),plotcurve(4,:));box off;title([''Cell number '' int2str(ori_selective(click)) ''; Hotelling '' num2str(clickpt(1)) '', BS '' num2str(clickpt(2))]);');
box off;


alpha = 0.05;

fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing orientation selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_oriselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by Hotelling''s T^2 test = %.2f\n',mean(p_dirselective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_vect<alpha)),1)
prev_orisel = p_reverse_vect(p_oriselective_vect<alpha);
fprintf(sprintf('\nVECTOR METHOD: Fraction of ORI-SELECTIVE cells showing direction selectivity by direction reversal test = %.2f\n',mean(prev_orisel<alpha)),1)

fprintf(sprintf('\nBOOTSTRAP: Fraction of cells showing direction selectivity by direction reversal test = %.2f\n',mean(p_reverse_bs<alpha)),1)


