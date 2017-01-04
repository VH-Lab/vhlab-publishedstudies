function output = sTestDoubleGaussOS(varargin)
% sTestCircularVarianceDS  Compare theoretical DSI, tuning pref, and tuning width
%
%   sTestDoubleGaussOS
%  
%   Produces a simulation of direction-selective responses for underlying direction selectivity values
%   ranging from 0.05 to 1.
%
%   In the first figure, the raw underlying direction selectivity curves are plotted.
%
%   In the second figure, cumulative distribution of the empirically measured DSI values for
%   100 example simulations at each underlying DSI value are plotted.
%
%   In the third figure, cumulative distribution of the empirically measured 1-DirCirVar values for
%   100 example simulations at each underlying DSI value are plotted.
%
%   In the fourth figure, the simulation results are presented in reverse: we show the cumulative
%   distribution of the underlying DSI values for empirical DSI values.
% 
%   In the fifth figure, the simulation results are again presented in reverse: we show the cumulative
%   distribution of the underling DSI values for empirical 1-DirCirVar values.
%
%   The number of simulations run can be adjusted from 100 by giving an input argument:
% 
%   sTestCircularVarianceDS(NUMSIMS)
%
%   Some parameters can be adjusted by providing name/value pairs.
%   PARAMETER:
%   num_repeats_per_stim                 :  Number of repeats for each stimulus (default 100)
%   noise_level                          :  Standard deviation of gaussian noise added to each trial 
%                                        :     (default 5, which is 50%)
%   numTrials                            :  Number of trials for each simulated recording (default 7)
%   anglestep                            :  Size of the step in direction angle for each stim (default 22.5)
%   doplots                              |  0/1 Should we plot the figures? (default 1)
%
%   Example:
%   sTestDoubleGaussOS('num_repeats_per_sim',100,'noise_level',2)


num_repeats_per_sim = 100;
numTrials = 7;
noise_level = 5;
anglestep = 22.5;
doplots = 1;


assign(varargin{:});

di_theory = [];
oi_theory = [];
Opref_theory = [];
sigma_theory = [];
di_empirical = [];
oi_empirical = [];
Opref_empirical = [];
sigma_empirical = [];


if doplots,
	theory_curve_figure = figure; % the noiseless curve figure
end;

 % Step 1 - simulate curves with 21 steps of direction selectivity values, plotting noiseless curves as we go
 
for i=1:21,
        for j=1:num_repeats_per_sim,  
		disp(['i is ' int2str(i) ', j is ' int2str(j) '.']);
		Opref_theory(i,j) = 360 * rand;
		sigma_theory(i,j) = (generate_random_data(1,'gamma',3,6)+10)/1.18;
		[dummy,real_fit] = otfit_carandini_err([10-(i-1)/2 (i-1)/2 Opref_theory(i,j) sigma_theory(i,j) (i-1)/4],0:359);
		di_theory(i,j) = compute_directionindex(0:359,real_fit);
		oi_theory(i,j) = compute_orientationindex(0:359,real_fit);
		output = OriDirCurveDemo('Rp',(i-1)/2,'Rn',(i-1)/4,'Rsp',10-(i-1)/2,'Opref',Opref_theory(i,j),...
			'sigma',sigma_theory(i,j),...
			'doplotting',0,'dofitting',1,'anglestep',anglestep,'noise_level',noise_level,'numTrials',numTrials,'sigmahints',[20 40 60]);
		di_empirical(i,j) = compute_directionindex(output.measured_angles,output.dirmean);
		oi_empirical(i,j) = compute_orientationindex(output.measured_angles,output.dirmean);
		Opref_empirical(i,j) = output.Op_;
		sigma_empirical(i,j) = output.sigm_;
	end;
end;

output = workspace2struct;
