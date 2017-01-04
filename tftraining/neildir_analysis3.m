function TFstruct = neildir_analysis3(cells,cellnames, experids, varargin)
% NEILDIR_ANALYSIS3 - Fill structure with useful information from TF training experiments
% 
%   TFSTRUCT = NEILDIR_ANALYSIS3(CELLS,CELLNAMES, EXPERIDS, ...)
%
%   Given a list of CELLS and CELLNAMES, fills a structure with the following fields:
%
%   Fieldname:                 | Desciption:
%   --------------------------------------------------------------------------
%   TF_trainingangle           |  Direction (orientation) used for training
%   TF_trainingtf              |  TF used for training   
%   TF_responses_raw{1..N}     |  Raw responses to range of TFs
%   TF_responses_blank{1..N}   |  Blank responses during same responses
%   TF_vis_significance{1..N}  |  Is each response larger than expected by chance?
%   TF_responses_mean{1..4}    |  Mean responses; first row is TFs, 2nd row is mean responses (blank is subtracted)
%                              |     3rd row is standard error of mean, 4th row is standard deviation
%   TF_responses_norm{1..4}    |  Normalized responses: (Raw-Blank)/max(Raw-Blank) (first row is TFs)
%                              |     3rd row is standard error of mean, 4th row is standard deviation
%   TF_DS_dos{1..4}            |  Direction index (difference over sum 'dos') for each recording
%   TF_DS_pop{1..4}            |  Direction index (difference over pref 'pop') for each recording
%   TF_responses_BS_raw{1..4}  |  Mean Bootstrap responses for each simulation (one row per simulation)
%   TF_responses_BS_blank{1..4}|
%   TF_responses_BS_norm{1..4} |
%   TF_DS_dos_BS_raw{1..4}     |  Distribution of DS_dos measurements for each simulation
%   TF_DS_pop_BS_raw{1..4}     |  Distribution of DS_pop measurements for each simulation
%   TF_DS_TFlist{1..4}         |  List of TFs over which DS_dos/DS_pop is calculated
%   TF_DS_dos_BS_median{1..4}  |  Median response of DS_dos measurements for each recording
%   TF_DS_pop_BS_median{1..4}  |  Median response of DS_pop measurements for each recording
%
%   In these field descriptions, N is the number of total measurements (typically 4) for a cell
%
%   This function also accepts additional arguments in name/value pairs that control its behavior:
%   Parameter (default)        | Description
%   --------------------------------------------------------------------------
%   Dir_AnchorTFs ([1 2 4])    | The temporal frequencies that are used to determine the positive direction
%   Do_BS (1)                  | 0/1 Should we actually perform the bootstrap or leave them as NaNs?
%   Num_BS_sims (200)         | Number of bootstrap simulations
%   

Dir_AnchorTFs = [1 2 4];
Do_BS = 1;
Num_BS_sims = 200;

assign(varargin{:});

structvarlist = {'TF_experid','TF_cellname','TF_trainingangle','TF_trainingtf','TF_responses_raw','TF_responses_blank',...
	'TF_vis_significance',...
	'TF_responses_mean','TF_responses_norm','TF_DS_dos','TF_DS_pop','TF_responses_BS_raw','TF_responses_BS_blank',...
	'TF_responses_BS_raw','TF_responses_BS_blank','TF_responses_BS_norm','TF_DS_dos_BS_raw','TF_DS_pop_BS_raw','TF_DS_TFlist',...
	'TF_DS_dos_BS_median','TF_DS_pop_BS_median'};

 % make an empty struct with the above fields so we'll get an error message if we don't conform to the style
for i=1:length(structvarlist),
	eval(['TFstruct.' structvarlist{i} '=[];']);
end;
TFstruct = TFstruct([]); 

for i=1:length(cells),
	
	TF_experid = experids(i);
	TF_cellname = cellnames{i};

	disp(['Now working on cell ' int2str(i) ' of ' int2str(length(cells)) ', ' cellnames{i} '.']);
	
	TF_a = findassociate(cells{i},'Training Angle','','');
	if ~isempty(TF_a),
		TF_trainingangle = TF_a.data; 
		if ischar(TF_trainingangle), TF_trainingangle = eval([TF_trainingangle ';']); end; % in case it's a string
	else,
		TF_trainingangle = NaN;
	end;

	TF_tf = findassociate(cells{i},'Training TF','','');
	if ~isempty(TF_tf),
		TF_trainingtf = TF_tf.data; 
		if ischar(TF_trainingtf), TF_trainingtf = eval([TF_trainingtf ';']); end; % in case it's a string
	else,
		TF_trainingtf = NaN;
	end;
	
	TF_responses_raw = {};
	TF_responses_blank = {};
	TF_vis_significance = {};
	TF_responses_mean = {};
	TF_responses_norm = {};
	for j=1:4,
		TF_rr = findassociate(cells{i},['TF' int2str(j) ' resp'],'','');
		if isempty(TF_rr),
			% responses
			TF_responses_raw{j} = NaN;
			TF_responses_blank{j} = NaN;
			TF_vis_significance{j} = NaN;
			TF_responses_mean{j} = NaN;
			TF_responses_norm{j} = NaN;
			% direction index measurements
			TF_DS_dos{j} = NaN;
			TF_DS_pop{j} = NaN;
			TF_responses_BS_raw{j} =NaN;
			TF_responses_BS_blank{j} = NaN;
			TF_responses_BS_norm{j} = NaN;
			TF_DS_dos_BS_raw{j}=NaN;
			TF_DS_dos_BS_median{j}=NaN;
			TF_DS_pop_BS_raw{j}=NaN;
			TF_DS_pop_BS_median{j}=NaN;
			TF_DS_TFlist{j} = NaN;
		else,
			% responses 

			TF_responses_raw{j} = TF_rr.data.f0vals{1};
			TF_responses_blank{j} = TF_rr.data.blank.f0vals{1};
			TF_responses_mean{j} = [TF_rr.data.f0curve{1}(1,:); ...
							TF_rr.data.f0curve{1}(2,:)-mean(TF_responses_blank{j});...
							TF_rr.data.f0curve{1}(3:4,:)];
			TF_responses_mean{j}(1,1:end/2) = TF_responses_mean{j}(1,1:end/2) * -1; % sign these TFs in opposite dir
			[norm_values,factor] = neiltf_norm(TF_responses_mean{j}(2,:),0);
			TF_responses_norm{j} = [ TF_responses_mean{j}(1,:); % first row is just TFs
						norm_values;  TF_responses_mean{j}(3:4,:)/factor ];

			% now figure out positive direction of these TFs

			TF_sign = neiltf_dirsign(TF_responses_norm{j}(1,:), TF_responses_norm{j}(2,:), Dir_AnchorTFs);
			TF_responses_mean{j}(1,:) = TF_responses_mean{j}(1,:) * TF_sign;
			TF_responses_norm{j}(1,:) = TF_responses_norm{j}(1,:) * TF_sign;

			[dummy,TF_vis_significance{j}] = neuralresponsesig_grating(TF_rr.data,0);

			TF_DS_dos{j} = DS_dos_tf(TF_responses_norm{j}(1,:),TF_responses_norm{j}(2,:));
			TF_DS_pop{j} = DS_pop_tf(TF_responses_norm{j}(1,:),TF_responses_norm{j}(2,:));

			if Do_BS,
				[TF_responses_BS_raw{j},TF_responses_BS_blank{j}] = neiltf_bootstrap(TF_responses_raw{j},...
						TF_responses_blank{j},Num_BS_sims);
				for n=1:Num_BS_sims,
					TF_responses_BS_norm{j}(n,:) = neiltf_norm(TF_responses_BS_raw{j}(n,:),...
								TF_responses_BS_blank{j}(n));
					TF_sign = neiltf_dirsign(TF_responses_mean{j}(1,:),TF_responses_BS_norm{j}(n,:),...
						Dir_AnchorTFs);
					DS_dos_BS = DS_dos_tf(TF_sign*TF_responses_mean{j}(1,:),...
								TF_responses_BS_norm{j}(n,:));
					DS_pop_BS = DS_pop_tf(TF_sign*TF_responses_mean{j}(1,:),...
								TF_responses_BS_norm{j}(n,:));
					if n==1,
						TF_DS_TFlist{j}= DS_dos_BS(1,:);
					end;
					TF_DS_dos_BS_raw{j}(n,:)=DS_dos_BS(2,:);
					TF_DS_pop_BS_raw{j}(n,:)=DS_pop_BS(2,:);
				end;
				TF_DS_dos_BS_median{j}=median(TF_DS_dos_BS_raw{j});
				TF_DS_pop_BS_median{j}=median(TF_DS_pop_BS_raw{j});
			else,
				TF_responses_BS_raw{j} =NaN;
				TF_responses_BS_blank{j} = NaN;
				TF_responses_BS_norm{j} = NaN;
				TF_DS_dos_BS_raw{j}=NaN;
				TF_DS_pop_BS_raw{j}=NaN;
				TF_DS_dos_BS_median{j}=NaN;
				TF_DS_pop_BS_median{j}=NaN;
			end;
		end;

	end;

	TFstructentry = var2struct(structvarlist{:});
	TFstruct(i) = TFstructentry;
	for j=1:length(structvarlist), eval(['clear ' structvarlist{j} ';']); end; % make sure we assign a new value each iteration
end;
