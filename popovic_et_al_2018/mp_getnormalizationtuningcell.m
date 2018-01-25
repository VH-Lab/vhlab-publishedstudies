function [out ] = mp_getnormalizationtuningcell(cell,cellname,varargin)
% MP_GETNORMALIZATIONTUNINGCELL- 
%
%  OUT = MP_GETNORMALIZATIONTUNINGCELL(CELL, CELLNAME, ...)
%
%  Given a cell CELL with name CELLNAME, returns the following entries
%  in the structure OUT. Fields are empty if the response is not present.
%  Fieldname:         | Description
%  -------------------------------------------------------------
%  vis_resp_p         | The likelihood that there was no significant variation
%                     |   across all of the stimuli and blank (ANOVA)
%  blank              | A 3 element vector with the mean response to blank, standard deviation of 
%                     |   the response to blank, and the standard error of the response to blank.
%  C_list             | List of contrasts that were run
%  normalization_curve| The tuning curve responses for each contrast (in a different cell list item)
%                     |    first row:   preferred orientation (1) orthogonal orientation (2) or
%                                          plaid (3)
%                     |    second row:  mean responses for these orientations
%                     |    third row:   standard deviation responses for these orientations
%                     |    fourth row:  standard error responses for these orientations
%              
%  This function can be modified by parameters given with name/value pairs:
%  Parameter (default value):         | Description
%  -----------------------------------------------------------------------------------
%  F0orF1 (0)                         | Use F0 (0), F1 (1), or whichever is greater (2)
%
%

F0orF1 = 0;

assign(varargin{:});  % assign any user-provided name/value pair arguments

B = findassociate(cell,'ContrastPlaid resp','','');

vis_resp_p = [];
normalization_curve = [];
blank = [];
C_list = [];

if ~isempty(B), 

	if length(B.data.f0curve{1}) ~= 12, % wrong number of stimuli
		error(['do not know how to handle normalization stims list different from size 12']);
	end;

	if F0orF1 == 2,
		max_resp_f0 = max(B.data.f0curve{1}(2,:));
		max_resp_f1 = max(B.data.f1curve{1}(2,:));
		if max_resp_f0 > max_resp_f1, 
			F0orF1 = 0;
		else,
			F0orF1 = 1;
		end;
	end;

	[length_resp_p,vis_resp_p] = neuralresponsesig_grating(B.data,F0orF1);

	C_list = [0.16 0.32 0.64 1];

	if F0orF1 == 0,
		for i=1:4,
			normalization_curve{i} = [ 1 2 3 ; B.data.f0curve{1}(2:end,3*(i-1)+(1:3)) ];
		end;
		blank = B.data.blank.f0curve{1}(3:end);
	else,
		for i=1:4,
			normalization_curve{i} = [ 1 2 3 ; B.data.f1curve{1}(2:end,3*(i-1)+(1:3)) ];
		end;
		blank = B.data.blank.f1curve{1}(3:end);
	end;
end;

out = var2struct('vis_resp_p', 'normalization_curve', 'C_list', 'blank');

