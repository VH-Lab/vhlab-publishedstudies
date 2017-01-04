function N = robustoridir_poweranalysis(measure, base, change, confidence, varargin)
% ROBUSTORIDIR_POWERANALYSIS - Power analysis for population measurements of osi or dsi
%
%   N = ROBUSTORIDIR_POWERANALYSIS(MEASURE, BASE, CHANGE, CONFIDENCE,...)
%
%   Reports the number of neurons that must be recorded to have a CONFIDENCE
%   chance of detecting a change in the MEASURE from a BASE to BASE+CHANGE.
%   This is done through simulations with increasing larger sample populations.
%   The smallest population size that produces a significant difference with confidence
%   CONFIDENCE in several respeats of the simulations will be reported.
%
%   MEASURE - 'DSI', 'OSI', '1-DirCirVar', or '1-CirVar'
%   BASE - the base value of the underlying OSI or DSI to evaluate
%   CHANGE - the change in value of the underlying OSI or DSI to detect
%   CONFIDENCE - The confidence, such as 0.95, 0.99, 0.999
%
%   These parameters can be matrixes.  In that case, MEASURE must be a cell list of the same
%   size. N is also a matrix of the same size.
%
%   Additional name/value pairs can be provided to modify the features of the orientation and
%   direction simulations (see help ORIDIRCURVEDEMO).
%
%   Example: N = ROBUSTORIDIR_POWERANALYSIS(MEASURE, BASE, CHANGE, CONFIDENCE,'noise_level',5)
%
%   The following parameters, if specified as name/value pairs, will also modify the operation of
%   this routine.
%   PARAMETER:                         | DESCRIPTION:
%     population_size (default 5)      |  Initial size of the sample population on which to start searching
%     population_increment (default 5) |  The size to increase the population at each step.
%     num_sims (default 100)           |  Number of simulations to make at each population size
%     reps (default 10)                |  Number of times to repeat these simulations; these repeats will be
%                                      |     used to determine the average likelihood of successful detections
%                                      |     with confidence CONFIDENCE; when this average likelihood itself
%                                      |     exceeds CONFIDENCE, the simulation is stopped.
%
%   See also: ORIDIRCURVEDEMO

N = [];

population_size = 5;
population_increment = 1;
num_sims = 100;
reps = 10;

assign(varargin{:});

if numel(population_size)==1,
        population_size = population_size * ones(size(base));
end;
if numel(population_increment)==1,
        population_increment = population_increment * ones(size(base));
end;
if numel(num_sims)==1,
        num_sims = num_sims * ones(size(base));
end;
if numel(reps)==1,
        reps = reps*ones(size(base));
end;

for i=1:size(measure,1),
        for j=1:size(measure,2),
                N(i,j) = robustoridir_poweranalysis_func(measure{i,j},base(i,j),change(i,j),confidence(i,j),...
                        population_size(i,j), population_increment(i,j), num_sims(i,j), reps(i,j), ...
                        varargin{:});
        end;
end;

function nn=robustoridir_poweranalysis_func(measure,base,change,confidence,population_size,population_increment,num_sims,reps,varargin)

measure,
population_increment,
population_size,

switch upper(measure),
	case 'OSI',
		end_condition_si = 1;
		useori = 1;
	case 'DSI',
		end_condition_si = 1;
		useori = 0;
	case '1-CIRVAR',
		end_condition_si = 0;
		useori = 1;
	case '1-DIRCIRVAR',
		end_condition_si = 0;
		useori = 0;
	otherwise,
		error(['Unknown value for MEASURE ' measure '; see help robustoridir_poweranalysis .']);
end;
		
while population_size < Inf,
	Rsi = [];
	Rcv = [];
	for r=1:reps,
		h_si = [];
		h_cv = [];
		for k=1:num_sims,
			si_ = [];
			si = [];
			cv_ = [];
			cv = [];
			for i=1:population_size, % generate correct number of cells
				sigma_ = (generate_random_data(1,'gamma',3,6)+10)/1.18;
				if useori,
					[rsp_,rp_,op_,sigma_,rn_] = osi2oriparams2(base,'sigma',sigma_);
				else,
					[rsp_,rp_,op_,sigma_,rn_] = dsi2dirparams2(base,'sigma',sigma_);
				end;
				sigma = (generate_random_data(1,'gamma',3,6)+10)/1.18;
				if useori,
					[rsp,rp,op,sigma,rn] = osi2oriparams2(base+change,'sigma',sigma);
				else,
					[rsp,rp,op,sigma,rn] = dsi2dirparams2(base+change,'sigma',sigma);
				end;
				op_ = rand * 360;
				op  = rand * 360;
				output_ = OriDirCurveDemo('Rsp',rsp_,'Rp',rp_,'Rn',rn_,'sigma',sigma_,...
					'Opref',op_,'dofitting',0,'doplotting',0,varargin{:});
				output = OriDirCurveDemo('Rsp',rsp,'Rp',rp,'Rn',rn,'sigma',sigma,...
						'Opref',op,'dofitting',0,'doplotting',0,varargin{:});
				if useori,
					si_(end+1) = compute_orientationindex(output_.measured_angles,output_.dirmean);
					cv_(end+1) = compute_circularvariance(output_.measured_angles,output_.dirmean);
					si(end+1) = compute_orientationindex(output.measured_angles,output.dirmean);
					cv(end+1) = compute_circularvariance(output.measured_angles,output.dirmean);
				else,
					si_(end+1) = compute_directionindex(output_.measured_angles,output_.dirmean);
					cv_(end+1) = compute_dircircularvariance(output_.measured_angles,output_.dirmean);
					si(end+1) = compute_directionindex(output.measured_angles,output.dirmean);
					cv(end+1) = compute_dircircularvariance(output.measured_angles,output.dirmean);
				end;
			end;
			h_si(end+1) = ttest2(si_,si,1-confidence);
			h_cv(end+1) = ttest2(cv_,cv,1-confidence);
		end;
		Rsi(end+1) = mean(h_si);
		Rcv(end+1) = mean(h_cv);
	end; % reps
	nn = population_size;
	disp(['Mean(Rsi): ' num2str(mean(Rsi)) ]);
	disp(['Mean(Rcv): ' num2str(mean(Rcv)) ]);
	if mean(Rsi)>confidence & end_condition_si,
		population_size = Inf;
	elseif mean(Rcv)>confidence&(~end_condition_si),
		population_size = Inf;
	else,
		population_size = population_size + population_increment;
	end;
end; % while


