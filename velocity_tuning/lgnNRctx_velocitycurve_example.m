function out=lgnNRctx_velocitycurve_example(varargin)
% LGNNRCTX_VELOCITYCURVE_EXAMPLE Example Velocity tuning curve
%
%   OUTPUT=LGNNRCTX_VELOCITYCURVE_EXAMPLE (...)
%
%   Computes example velocity curve responses for a single 
%   'cortical' cell that receives inputs from 'lgn' cells with
%   different positions and delays.
%
%   Each 'lgn' cell produces a postsynaptic response with
%   amplitude 'amp' and durration 'durr'.
%
%   The user may pass name/value pairs to modify the parameters
%   of the model:
%   Parameter name (default)   |  Description
%   ---------------------------------------------------------------------------
%   MODEL PARAMETERS:          |
%   N (10)                     |  Number of positions in 'lgn'
%   dx (1)                     |  Change in visual receptive field position
%                              |    from one position to the next (degrees visual angle)
%   R (5)                      |  Number of latencies at each position
%   dlatency (0.020)           |  Change in latency from one latency value to the next
%   amp (1)                    |  Amplitude of 1 'lgn' to 'cortex' synapse
%   durr (0.020)               |  Duration of synaptic event
%   W (diagonal)               |  Weight matrix of connections from the N x R 'lgn' array
%                              |    to the 'cortical' cell. Must be NxR in size
%   THRESH (2)                 |  Threshold for the 'cortical' cell to fire. The neuron fires
%                              |    at a rate that is rectified above 0.
%   T0 (-5)                    |  Time of start of model simulation
%   T1 (5)                     |  Time of end of model simulation
%   dT (0.001)                 |  Time integration step for model
%                              |
%   use_lgn_velocity_curve (0) |  Should we use a velocity-dependent tuning curve for
%                              |    the LGN input? 
%   lgn_velocity_curve_amp (1) |  Amplitude boost for velocity-dependent tuning curve
%   lgn_velocity_curve_peak(25)|  Peak (gaussian function) location of most boosted velocity
%   lgn_velocity_curve_w (25)  |  Width (gaussian function) around most boosted velocity
%                              |
%   STIMULUS PARAMETERS:       |
%   velocity ([-100 -80 -50... |  Velocities to examine (in degrees of visual angle
%            -40 -20 -10 -1... |    per second)
%        1 10 20 40 50 80 100])|
%   repeats (5)                |  Number of times stimulus should repeat
%
%   demo_velocity (50)         |  Velocity for which to plot firing rate
%   
% 


N = 10; % 10 input cells
dx = 1; % 1 visual degree per cell
R = 5;  % 5 latencies
dlatency = 1/50; % 20 millisecond differences
repeats = 5;

T0 = -50;
T1 = 50;
dT = 0.001;

 % step function response characteristics
amp = 1;  % amplitude of 1 unit
durr = 0.020; % 20 milliseconds

use_lgn_velocity_curve = 0;
lgn_velocity_curve_amp = 1;
lgn_velocity_curve_peak = 25;
lgn_velocity_curve_w = 20;

THRESH = 2;

velocity = [1 10 20 40 50 80 100]; % different velocities
velocity = sort([-velocity velocity]);  % do positive and negative
demo_velocity = 50;

assign(varargin{:});

% weights

if ~exist('W','var'), % user didn't provide weight matrix
	W = zeros(N,R);
	for i=1:N,
		W(i,i) = 1;
	end;
	W = W(1:N,1:R);
	clear i;
end;

lgn_velocity_curve = mvnpdf(abs(velocity(:)),lgn_velocity_curve_peak,(lgn_velocity_curve_w)^2);
lgn_velocity_curve = lgn_velocity_curve/max(lgn_velocity_curve);
lgn_velocity_curve = 1+use_lgn_velocity_curve * lgn_velocity_curve_amp * lgn_velocity_curve;

% cortical output

output = [];

for v=1:length(velocity),

	spiketimes=lgnNR_spiketimes(N,R,dx,dlatency,velocity(v),repeats);
	I = lgnNRctxinp_step(T0,T1,dT,spiketimes,amp*lgn_velocity_curve(v),durr);
	C = lgnNRctxinp_apply(W,I);

	if velocity(v)==demo_velocity,
		figure;
		T = T0:dT:T1;
		plot(T,C);
		box off;
		xlabel('Time');
		ylabel('Response');
		title(['Input to cortical cell at velocity ' num2str(velocity(v))]);
		hold on;
		plot([T(1) T(end)],THRESH*[1 1],'k--');
	end;

	% rectify the input
	output(v) = sum(dT*rectify(C-THRESH));
end;

figure;
plot(velocity,output,'bo');
xlabel('Velocity');
ylabel('Responses');
A = axis;
axis([A(1) A(2) 0 A(4)]);
box off;
clear A;

out = workspace2struct;

 % remove meaningless looping variables
try, out = rmfield(out,'v'); end;
try, out = rmfield(out,'varargin'); end;
try, out = rmfield(out,'spiketimes'); end;
try, out = rmfield(out,'I'); end;
try, out = rmfield(out,'C'); end;
try, out = rmfield(out,'T'); end;

