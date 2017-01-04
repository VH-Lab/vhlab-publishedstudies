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
ncells = 40;

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
  responses{i_rep} = response_mtx;  % save the input
  
  [prefdir(i_rep) p_rep(i_rep) p_rev_rep(i_rep) p_ori_rep(i_rep) p_vecmags_rep(i_rep) vectors vectormags vectormags_scaled] = ...
    calc_direction_stats_vectormethod_V2(angles,response_mtx,spontaneous,nrep);

  
  % Perform the bootstrap
   predictor = angles;
   trialdata = response_mtx;
   niter = 100;
   simdataflag = 0;
 
   da = median(diff(angles));
   meanresp = mean(response_mtx);
   [maxresp,if0]=max(meanresp);
   minresp = min(meanresp);
   otpref = angles(if0);
   extraparams = {[da/2 da 40 60 90], predictor, 0, maxresp, otpref, 'widthseeddummywillbereplaced', 'widthint' ,[da/2 180],...
     'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[minresp maxresp]};
   verbose = 1;
   [parammtx,datamtx, extraout] = resampparams_MC('otfit_carandini',predictor,trialdata,niter,simdataflag,extraparams,verbose);

   bootstrap_params{i_rep} = {parammtx, datamtx, extraout};

end;

save(['bootstrap' datestr(now) '.mat'],'responses','bootstrap_params');
