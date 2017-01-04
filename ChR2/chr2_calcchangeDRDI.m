function vars=chr2_calcchangeDRDI(output,cells,cellnames,experids)
% CHR2_CALCCHANGEDRDI - calculate numerous index values from cell data for chr2 study
%
%  VARS = CHR2_CALCCHANGEDRDI(OUTPUT,CELLS,CELLNAMES,EXPERIDS)
%
%  Computes or extracts several observations and indexes from VH lab ChR2 optical training 
%  experiments.  VARS is a structure with the following fields (see multiple sections):
%
%  
%  Fields group 1:  these values contain observations for each cell over time. The values are
%  all concatenated together into single arrays. Use 'indexlookup(i)' field to determine the cell
%  to which the ith measurements correspond, use 't(i)' to determine the time of the ith measurement, etc.
%  --------------------------------------------------------------------------------
%  indexlookup      : The cell index number (in the list of cells called OUTPUT) for each observation
%  passfail         : Did the measurement at this timepoint pass the inclusion criteria?
%  trainingstimid   : 1 = unidirectional, 2 = constant, 3 = none
%  testnumberlookup : The observation number for each cell (is this the first observation, the second observation, etc)
%  t                : The time of the observation
%  maxresp_norm     : The maximum response to the best (on average) stimulus of this observation,
%                   :    normalized to the first measurement for each cell
%  percent_change_resp  : Same as 'maxresp_norm', except measurement is AFTER / BEFORE
%  maxresp_abs      : The un-normalized maximum response of the maximum response measurement
%  baseline_norm    : The baseline response (response orthogonal to the preferred) of this observation, normalized to the
%                   :    first measurement of each cell
%  fraction_change_baseline_norm :  same as 'baseline_norm', except it is a single measure of AFTER / BEFORE
%  dr               : The 'direction ratio' from Van Hooser et al. 2012. Resp(traindir) - Resp(opposite) / (Resp(traindir)+Resp(opposite))
%  ori_change       : The change in orientation preference (based on fit), relative to training direction (0==training direction)
%  cv_raw           : 1-circular variance index value (1 is super oriented, 0 is unoriented)
%  di_raw           : Raw direction index value: (Rp-Rn)/Rp (where Rp is response to empirically measured preferred direction, Rn is empircal null)
%  di_unsigned      : Same as above, except each measure is the change in the unsigned di from the first measurement
%  di_esigned       : Same as di_unsigned, but now is multiplied by the empirical sign; if the currently measured
%                   :   direction matches the initial measurement (within 90), then the sign is +1; else, -1
%  di_signed        : Same as di_unsigned, but now is multiplied by the stimulus sign; if the currently measured
%                   :   direction matches the training angle (within 90), then the sign is +1; else, -1
%  signed_DI_raw    : Same as di_signed, except it is the raw value at each time point (not the change from the beginning)
%  dcv_raw          : Raw 1-direction circular variance (see Mazurek et al. 2014)
%  dcv_unsigned     : Same as above, except each measure is the change in the unsigned dcv from the first measurement
%  dcv_esigned      : Same as dcv_unsigned, but now is multiplied by the empirical sign; if the currently measured
%                   :   direction matches the initial measurement (within 90), then the sign is +1; else, -1
%  dcv_signed       : Same as dcv_unsigned, but now is multiplied by the stimulus sign; if the currently measured
%                   :   direction matches the training angle (within 90), then the sign is +1; else, -1
%  dcv_signed_raw   : Same as dcv_signed, except it is the raw value at each time point (not the change from the beginning)

%  NEW NAMES/STYLE:
%  di_initialAngle  : Same as DI, except angle calculation is with respect to initial angle preference that was observed
%  di_initialAngle_signed : Same as above, except signed (if later angles differ from initial by more than 90, then negative sign)
%  di_trainingAngle : Same as DI, except angle calculation is with respect to training angle preference that was used
%  di_trainingAngle_signed : Same as above, except signed (if later angles differ from initial by more than 90, then negative sign)
% 
%
%
%  Fields group 2:  these values contain observations for each cell at its initial point, and are repeated
%  they have the same size as the fields in group 1 (that is, the initial value is repeated N times, where N is
%  the number of observations for each cell)
%  --------------------------------------------------------------------------------
%  maxresp_init     : Initial maximum response value
%  ori_init         : Initial orientation preference, relative to training angle
%   
%
%  Fields group 3: these values contain overall change in index values for individual cell
%  over the course of the experiment, from the first measurement to the last.
%  --------------------------------------------------------------------------------
%  delta_dr_overall           : Overall change in direction ratio
%  delta_di_signed_overall    : Overall change in signed di
%  delta_di_esigned_overall   : Overall change in empircally signed di
%  delta_di_unsigned_overall  : Overall change in unsigned di
%  delta_dcv_unsigned_overall : Overall change in (1-direction circular variance)
%  delta_dcv_esigned_overall  : Overall change in empircally signed (1-direction circular variance)
%  delta_dcv_signed_overall   : Overall change in signed (1-direction circular variance)
%
% Fields group 4: these values contain index values in cell arrays sorted by cell number.
% For example, tl{i}(j) is the time of the jth observation of cell i. This contains the
% same information as many of the fields above, but organized in a different way.
%  tl               | Time of the observation
%  drl              | Direction ratio (see above) for each observation
%
%  INCLUSION CRITERIA:  Right now, an observation is included if it passes the following tests:
%    1) the tuning curve exhibits some variation across the stimulus or across the stimulus and blank
%    2) the maximum response is greater than 0.5Hz
%   


 % fields group 1:
indexlookup = [];
passfail = [];
trainingstimid = [];
testnumberlookup = [];
t = [];
maxresp_norm = [];
percent_change_resp = [];
maxresp_abs = [];
baseline_norm = [];  % baseline compared to earlier
fraction_change_baseline_norm = [];
dr = [];
ori_change = [];
cv_raw = [];
oi_raw = [];

di_raw = [];
di_raw_signed = []; % copy of di_signed;
di_unsigned = [];
signed_DI_raw = [];
di_signed = [];
di_esigned = [];

di_initialAngle = [];
di_initialAngle_signed = [];
di_trainingAngle = [];
di_trainingAngle_signed = [];

dcv_raw = [];
dcv_signed_raw = [];
dcv_unsigned = [];
dcv_signed = [];
dcv_esigned = [];

% fields group 2
maxresp_init = [];
ori_initial = [];
di_match_initial = [];
di_esigned_init = [];
di_signed_init = [];

% fields group 3

delta_dr_overall = [];
delta_di_signed_overall = [];
delta_di_esigned_overall = [];
delta_di_unsigned_overall = [];
delta_dcv_esigned_overall = [];
delta_dcv_unsigned_overall = [];
delta_dcv_signed_overall = [];

cell_trainingstimid = [];

% fields group 4
tl = {};
drl = {};

myvar = workspace2struct;
fn = fieldnames(myvar);

 % response compared to initial


obs_counter = 0;
cell_counter = 0;

for i=1:length(output),
	cell_counter = cell_counter + 1;
	disp(['Processing cell ' int2str(cell_counter) ' of ' int2str(length(output)) '.']);
        tl{i} = [];
        drl{i} = [];

	all_nans = 0;

	tt=findassociate(cells{i},'Training Type','','');
	train_type_here = 0;
	if ~isempty(tt),
		switch(lower(tt.data)),
			case {'uni','unidirectional'},
				train_type_here = 1;
			case {'constant','const'},
				train_type_here = 2;
			case {'none'},
				train_type_here = 3;
			otherwise,
				train_type_here = 4;
		end;
	end;

	cell_trainingstimid(i) = train_type_here;

	length_of_j = 0;
	for j=1:length(output(i).indexes),
		if ~isnan(output(i).indexes(j).f1f0),
			length_of_j = length_of_j + 1;
		end;
		if isempty(output(i).testname), output(i).testname = 'Dir2Hz'; end;
	end;
	output(i).indexes = output(i).indexes(1:length_of_j);
		length_of_j,


        for j=1:length(output(i).indexes),
		obs_counter = obs_counter + 1;
                t_ = (output(i).indexes(j).time - output(i).indexes(1).time)/(60*60) + 0.05*rand;
                dr_ = output(i).indexes(j).dr - output(i).indexes(1).dr;

		[issimple] = issimplecell(cells{i},[output(1).testname int2str(j)]);
		di_initialAngle_here = raw_dr_ratio(cells{i},[output(i).testname int2str(j)],...
			'AssociateTestPrefix',conditional(issimple,'SP F1 ','SP F0 '),'TheTrainingAngle',output(i).indexes(1).dirpref,'useDIForm',1);
		di_trainingAngle_here = NaN;

		% signed di
		if strcmp(lower(output(i).indexes(1).trainingtype),'unidirectional'), % if uni, use training angle to define sign
			di_trainingAngle_here = raw_dr_ratio(cells{i},[output(i).testname int2str(j)],...
				'AssociateTestPrefix',conditional(issimple,'SP F1 ','SP F0 '),'useDIForm',1);
			di_sign_0=2*((angdiff(output(i).indexes(j).trainingangle-output(i).indexes(1).dirpref)<=90)-0.5);
			di_signed_initial = output(i).indexes(1).di * di_sign_0;
			di_signed_init(end+1) = di_signed_initial;
			di_sign_1=2*((angdiff(output(i).indexes(j).trainingangle-output(i).indexes(j).dirpref)<=90)-0.5);
			di_here = output(i).indexes(j).di * di_sign_1; % signed
			change_di = di_here - di_signed_initial; % signed

			dcv_here = (1-output(i).indexes(j).dcv) * di_sign_1; % signed
			dcv_signed_initial = (1-output(i).indexes(1).dcv) * di_sign_0;
			change_dcv = dcv_here - dcv_signed_initial; % signed
		else, % undefined
			di_sign_0=NaN;
			di_signed_initial = NaN;
			di_signed_init(end+1) = NaN;
			di_sign_1 = NaN;
			di_here = NaN;
			change_di = NaN;

			dcv_here = NaN;
			dcv_signed_initial = NaN;
			change_dcv = NaN;
		end;

		% emperical sign - based on initial tuning	
		di_esign_0 = 1; 
		di_esigned_initial = output(i).indexes(1).di * di_esign_0;
		di_esigned_init(end+1) = di_esigned_initial;
		di_esign_1=2*((angdiff(output(i).indexes(j).dirpref-output(i).indexes(1).dirpref)<=90)-0.5);
		di_ehere = output(i).indexes(j).di * di_esign_1; % signed
		change_edi = di_ehere - di_esigned_initial; % signed

		dcv_esigned_initial = (1-output(i).indexes(1).dcv) * di_esign_0;
		dcv_ehere = (1-output(i).indexes(j).dcv) * di_esign_1; % signed
		change_edcv = dcv_ehere - dcv_esigned_initial; % signed

		change_di_unsigned = output(i).indexes(j).di - output(i).indexes(1).di;
		change_dcv_unsigned = (1-output(i).indexes(j).dcv) - (1-output(i).indexes(1).dcv);

		maxrespinitial = output(i).indexes(1).max_rate;
		maxresphere = output(i).indexes(j).max_rate / output(i).indexes(1).max_rate;
		maxrespabshere = output(i).indexes(j).max_rate;

		bn = output(i).indexes(j).orth / output(i).indexes(1).orth; % baseline_norm

		goodhere = 1;
		pf  = 1;
                if all_nans==1 | isnan(output(i).indexes(j).sig_vis) | ...
			((output(i).indexes(j).sig_vis > 0.05) & (output(i).indexes(j).sig_ori > 0.05) )    | ...
			output(i).indexes(j).max_rate<1,
			pf = 0;
                        dr_ = NaN;
			change_di = NaN;
			change_edi = NaN;
			change_di_unsigned = NaN;
			change_dcv = NaN;
			change_edcv = NaN;
			change_dcv_unsigned = NaN;
			maxresphere = NaN;
			maxrespabshere = NaN;
			bn = NaN;
			all_nans = 1; % all subsequent entries should be nan
			all_nans = 0; % all subsequent entries should not be nan
			goodhere = 0;
		end;
		%elseif all_nans==0,
		if goodhere & j>1,
			delta_di_esigned_overall(i) = change_edi;
			delta_dr_overall(i) = dr_;
			delta_di_signed_overall(i) = change_di;
			delta_dcv_signed_overall(i) = change_dcv;
			delta_dcv_unsigned_overall(i) = change_dcv_unsigned;
			delta_dcv_esigned_overall(i) = change_edcv;
			delta_di_unsigned_overall(i) = output(i).indexes(j).di - output(i).indexes(1).di;
			di_match_initial(i) = di_sign_0;
			ori_initial(i) = angdiffwrapsign(mod(output(i).indexes(1).dirpref,180) - mod(output(i).indexes(1).trainingangle,180),180);
			ori_change(i) = angdiffwrapsign(mod(output(i).indexes(j).dirpref,180) - mod(output(i).indexes(1).dirpref,180),180);
			percent_change_resp(i) = maxresphere;
			fraction_change_baseline_norm(i) = bn;
		elseif ~goodhere & j<=2 | length(output(i).indexes)<2, % we need to have 2 measurements to assess a change
			delta_di_esigned_overall(i) = NaN;
			delta_dr_overall(i) = NaN;
			delta_di_signed_overall(i) = NaN;
			delta_di_unsigned_overall(i) = NaN;
			delta_dcv_signed_overall(i) = NaN;
			delta_dcv_unsigned_overall(i) = NaN;
			delta_dcv_esigned_overall(i) = NaN;
			di_match_initial(i) = NaN;
			ori_initial(i) = NaN;
			ori_change(i) = NaN;
			percent_change_resp(i) = NaN;
			fraction_change_baseline_norm(i) = NaN;
		end;

		trainingstimid(end+1) = train_type_here;
		passfail(end+1) = pf;
                tl{i}(end+1) = t_;
                drl{i}(end+1) = dr_;
                t(end+1) = t_;
                dr(end+1) = dr_;
		di_signed(end+1) = change_di;
		di_esigned(end+1) = change_edi;
		di_unsigned(end+1) = change_di_unsigned;
		dcv_signed(end+1) = change_dcv;
		dcv_unsigned(end+1) = change_dcv_unsigned;
		dcv_esigned(end+1) = change_edcv;
		di_initialAngle(end+1) = di_initialAngle_here;
		di_initialAngle_signed(end+1) = di_initialAngle_here * di_esign_1;
		di_trainingAngle(end+1) = di_trainingAngle_here;
		di_trainingAngle_signed(end+1) = di_trainingAngle_here * di_sign_1;
		indexlookup(end+1) = i;
		testnumberlookup(end+1) = j;
		maxresp_norm(end+1) = maxresphere;
		maxresp_abs(end+1) = maxrespabshere;
		baseline_norm(end+1) = bn;
		if goodhere,
			di_raw(end+1) = output(i).indexes(j).di;
			signed_DI_raw(end+1) = di_here;
			cv_raw(end+1) = 1-output(i).indexes(j).cv;
            oi_raw(end+1) = output(i).indexes(j).oiind;
			dcv_raw(end+1) = 1-output(i).indexes(j).dcv;
			dcv_signed_raw(end+1) = dcv_here;
		else,
			di_raw(end+1) = NaN;
			signed_DI_raw(end+1) = NaN;
			cv_raw(end+1) = NaN;
            oi_raw(end+1) = NaN;
			dcv_raw(end+1) = NaN;
			dcv_signed_raw(end+1) = NaN;
		end;
		

		if length(di_signed)~=obs_counter, keyboard; end;
        end;
	if length(delta_di_signed_overall)~=cell_counter, keyboard; end;
end;

di_raw_signed = signed_DI_raw;

 % now save the output, while avoiding local unimportant variables that weren't initialized at the beginning

vars = [];
for i=1:length(fn),
	vars = setfield(vars,fn{i},eval(fn{i}));
end;

