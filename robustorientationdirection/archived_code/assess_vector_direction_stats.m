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
[q q q q vectormags vectormags_scaled] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous);

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
% expected_response = [2 2 2 2 2 2 2 2];

% (2) Give 'expected_response' a direction-selective response --> see what you get for preferred direction and p values
expected_response = [2 10 2 2 2 2 2 2];


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
  
  [prefdir(i_rep) p_rep(i_rep) prev_rep(i_rep)] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous);
end

figure
hist(prefdir)

alpha = 0.05;
fprintf(sprintf('\nFraction of cells showing significance by Hotelling''s T^2 test = %.2f\n',mean(p_rep<alpha)),1)
fprintf(sprintf('\nFraction of cells showing significance by direction reversal test = %.2f\n',mean(prev_rep<alpha)),1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective 3: Apply tool to data

load data4mark

ncells = length(structlist);

% For each cell, I'll extract the p value obtained from the bootstrap procedure for the probability that the cell's direction preference is
% opposite that obtained from the Carandini fit; save it as 'p_reverse_bs'
p_reverse_bs = nan*ones(ncells,1);

% Next I'll use the new vector tool to calculate three things:
% (1) The preferred direction for that cell as determined by the average vector obtained in individual trials. Save as 'prefdir_vect'.
% (2) A p value for direction selectivity, obtained from Hotelling's T^2 test performed . Save as 'p_selective_vect'.
% (3) A p value for the probability of direction reversal. Save as 'p_reverse_vect'.
prefdir_vect = nan*ones(ncells,1);
p_selective_vect = nan*ones(ncells,1);
p_reverse_vect = nan*ones(ncells,1);

for i_cell = 1:ncells
  cell2analyze = i_cell;

  cell = structlist{cell2analyze};
  if(length(cell)==0)
    continue;
  end
  
  q = cell(3);
  angles = q.data.curve(1,:);  
  
  response_mtx = cell2mat(q.data.ind);
  spont = q.data.spont(1);
  nanind = any(isnan(response_mtx'))';
  response_mtx(nanind,:) = [];

  if(size(response_mtx,1)<3)
    continue;
  end
  
  [prefdir_vect(i_cell) p_selective_vect(i_cell) p_reverse_vect(i_cell)] = calc_direction_stats_vectormethod(angles,response_mtx,spont);
    
  p_reverse_bs(i_cell) = structlist{cell2analyze}(4).data;
    
end

Lnan = isnan(p_selective_vect);
p_selective_vect(Lnan) = [];
p_reverse_bs(Lnan) = [];
p_reverse_vect(Lnan) = [];

alpha = 0.05;

fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing significance by Hotelling''s T^2 test = %.2f',mean(p_selective_vect<alpha)),1)
fprintf(sprintf('\nVECTOR METHOD: Fraction of cells showing significance by direction reversal test = %.2f',mean(p_reverse_vect<alpha)),1)
fprintf(sprintf('\nBOOTSTRAP: Fraction of cells showing significance by direction reversal test = %.2f\n',mean(p_reverse_bs<alpha)),1)


