function [assoc] = sizeanalysis_compute(respstruct)
% SIZEANALYSIS_COMPUTE Analyze size or length tuning curves
%
%   [ASSOC] = SIZEANALYSIS_COMPUTE(REPSTRUCT)
%
%  Analyses size tuning curves
%
%  REPSTRUCT is a structure of response properties with fields
%  curve         |   4xnumber of sizes (or lengths) tested
%                |     curve(1,:) is sizes tested (in degrees)
%                |     curve(2,:) is mean response
%                |     curve(3,:) is standard deviation
%                |     curve(4,:) is standard error
%  ind           |   cell list of individual trials responses for
%                |     each size
%  spont         |   Spontaneous responses [mean stddev stderr]
%  spontind      |   individual spontaneous responses
%  Optionally:   
%  blank         |   response to a blank trial: [mean stddev stderr]
%  blankind      |   individual responses to blank trials
%
%  Returns a list of associates (see HELP ASSOCIATE):
%
%  Measures derived from raw responses:
%  'SZ varies'                 |   0/1 Was response significant across sizes?
%  'SZ varies p'               |   P value of ANOVA across stims
%  'SZ response'               |   0/1 Was response significant across sizes and blank?
%  'SZ response p'             |   P value of ANOVA including stims and blank
%  'SZ Pref'                   |   Size with maximum response (empirical)
%  'SZ Response curve'         |   Curve of responses [SZs;mean;stddev;stderr]
%
%  DoG fit:
%  'SZ DOG Fit'                |   2 rows; first row is sizes, 2nd is fit
%  'SZ DOG Fit Params'         |   [DOG Fit params]
%  'SZ DOG Fit SSE'            |   Sum of squared error
%
%  SSM fit:
%  'SZ SSM Fit'                |   2 rows; first row is sizes, 2nd is fit
%  'SZ SSM Fit Params'         |   [SSM Fit params]
%  'SZ SSM Fit SSE'            |   Sum of squared error
%
%  Fourier Transform:
%  'SZ FFT'                    |   2 rows; first row is frequencies (cycles/deg);
%                              |     2nd is Fourier Coefficients
%
% 
%  If the function is called with 0 inputs, it will return only a list of the 
%  associate names that it produces.
% 
%  See also: OTANALYSIS_COMPUTE 

assoc_list = { 'SZ varies', 'SZ varies p', 'SZ response', 'SZ response p',...
	'SZ Pref', 'SZ Response curve',...
	'SZ DOG Fit','SZ DOG Fit Params','SZ DOG Fit SSE',...
	'SZ SSM Fit','SZ SSM Fit Params','SZ DOG Fit SSE',...
	'SZ FFT'};

if nargin==0,
	assoc = assoc_list;
	return;
end;

%%% PART 1:  Measures derived from raw responses

[sz_varies_p,sz_response_p] = neural_response_significance(respstruct);

assoc = struct('type','SZ varies','owner','sizeanalysis_compute',...
	'data',sz_varies_p<0.05, 'desc', '0/1 Was response significant across sizes?');
assoc(end+1) = struct('type','SZ varies p','owner','sizeanalysis_compute',...
	'data',sz_varies_p, 'desc', 'P value of ANOVA across stims');
assoc(end+1) = struct('type','SZ response','owner','sizeanalysis_compute',...
	'data',sz_response_p<0.05,...
	'desc', '0/1 Was response significant across sizes and blank?');
assoc(end+1) = struct('type','SZ response p','owner','sizeanalysis_compute',...
	'data',sz_response_p, 'desc', 'P value of ANOVA including stims and blank');

resp = respstruct.curve;
SZs = resp(1,:);  % sizes run in degrees
[maxresp,pref_ind]=max(resp(2,:));

SZ_Pref = SZs(pref_ind);

assoc(end+1) = struct('type','SZ Pref','owner','sizeanalysis_compute',...
	'data',sz_response_p, 'desc', 'Size with maximum response (empirical)');
assoc(end+1) = struct('type','SZ Response curve','owner','sizeanalysis_compute',...
	'data',resp, 'desc', 'Curve of responses [SZs;mean;stddev;stderr]');


%%%  PART 2:  DOG Fit
[dog_params, dog_sse, fit_values_dog] = dogfit(resp(1,:),resp(2,:));
  % maybe pick different X axis range for fit output

assoc(end+1) = struct('type','SZ DOG Fit','owner','sizeanalysis_compute',...
	'data',[resp(1,:) ; fit_values_dog(:)'], 'desc', '2 rows; first row is sizes, 2nd is fit');
assoc(end+1) = struct('type','SZ DOG Fit Params','owner','sizeanalysis_compute',...
	'data',dog_params, 'desc', '[DOG Fit params]');
assoc(end+1) = struct('type','SZ DOG Fit SSE ','owner','sizeanalysis_compute',...
	'data',dog_sse, 'desc', 'DOG Fit Sum of Squared Error');

 %%% PART 3:  SSM Fit
[ssm_params, ssm_sse, fit_values_ssm] = ssm_fit(resp(1,:),resp(2,:));
  % maybe pick different X axis range for fit output

assoc(end+1) = struct('type','SZ SSM Fit','owner','sizeanalysis_compute',...
	'data',[resp(1,:) ; fit_values_ssm], 'desc', '2 rows; first row is sizes, 2nd is fit');
assoc(end+1) = struct('type','SZ SSM Fit Params','owner','sizeanalysis_compute',...
	'data',ssm_params, 'desc', '[SSM Fit params]');
assoc(end+1) = struct('type','SZ SSM Fit SSE ','owner','sizeanalysis_compute',...
	'data',ssm_sse, 'desc', 'SSM Fit Sum of Squared Error');

%%%  PART 4:  Fourier transform
 % check for even spacing; function 'fouriercoeffs' only works with even spacing

steps = SZs;
avg_step = mean(diff(SZs));
if ~any(  (diff(SZs)-avg_step)>1e-8 ),  % if spacing is approximately even, proceed
	[fc, freqs] = fouriercoeffs(resp(2,:),avg_step);

	assoc(end+1) = struct('type','SZ FFT','owner','sizeanalysis_compute',...
		'data',[fc(:)' ; freqs(:)'],...
		'desc', 'Fourier coefficients [1st row spatial frequencies,2nd is coefs]');
end;
 
