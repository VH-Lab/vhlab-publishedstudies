function [out ] = mp_getlengthtuningcell(cell,cellname,varargin)
% MP_GETLENGTHTUNINGCELL - 
%
%  OUT = MP_GETLENGTHTUNINGCELL(CELL, CELLNAME, ...)
%
%  Given a cell CELL with name CELLNAME, returns the following entries
%  in the structure OUT. Fields are empty if the response is not present.
%  Fieldname:         | Description
%  -------------------------------------------------------------
%  vis_resp_p         | The likelihood that there was no significant variation
%                     |   across all of the stimuli and blank (ANOVA)
%  length_resp_p      | The likelihood that there was no significant variation
%                     |   across all of the length tuning stimuli
%  blank              | A 3 element vector with the mean response to blank, standard deviation of 
%                     |   the response to blank, and the standard error of the response to blank.
%  contrast           | The contrast used (only available if 'ds' is provided below)
%  distance           | The monitor distance (only available if 'ds' is provided below)
%  length_curve       | The tuning curve response for length tuning. This has 4 rows
%                     |    first row:   lengths used (in degrees)
%                     |    second row:  mean responses for these lengths
%                     |    third row:   standard deviation responses for these lengths
%                     |    fourth row:  standard error responses for these lengths
%  length_curve_norm  | The normalized tuning curve response for length tuning. Tuning curves are
%                     |    normalized by subtracting the blank response and dividing by the maximum response.
%                     |    This has 4 rows
%                     |    first row:   lengths used (in degrees)
%                     |    second row:  mean responses for these lengths
%                     |    third row:   standard deviation responses for these lengths
%                     |    fourth row:  standard error responses for these lengths
%  aperture_curve     | The tuning curve responses for aperture tuning (a grating with a
%                     |    hole in the middle):
%                     |    first row:   lengths used (in degrees)
%                     |    second row:  mean responses for these lengths
%                     |    third row:   standard deviation responses for these lengths
%                     |    fourth row:  standard error responses for these lengths
%  aperture_curve_norm| The normalized tuning curve responses for aperture tuning
%                     |    first row:   lengths used (in degrees)
%                     |    second row:  mean responses for these lengths
%                     |    third row:   standard deviation responses for these lengths
%                     |    fourth row:  standard error responses for these lengths
%              
%
%  This function can be modified by parameters given with name/value pairs:
%  Parameter (default value):         | Description
%  -----------------------------------------------------------------------------------
%  F0orF1 (0)                         | Use F0 (0), F1 (1), or whichever is greater (2)
%  ds ([])                            | Optionally, include dirstruct for experimental data to retrieve
%                                     |   original stimulus parameters
%
%

F0orF1 = 0;
ds = [];

assign(varargin{:});  % assign any user-provided name/value pair arguments

B = findassociate(cell,'LengthWidthC resp','','');
BT = findassociate(cell,'LengthWidthC test','','');
C = findassociate(cell,'LengthWidthCA resp','','');
CT = findassociate(cell,'LengthWidthCA test','','');

vis_resp_p = [];
length_resp_p = [];
length_curve = [];
length_curve_norm = [];
aperture_curve = [];
aperture_curve_norm = [];
blank = [];
contrast = [];
distance = [];
whatvaries = {};

if ~isempty(C),

	if F0orF1 == 2,
		max_resp_f0 = max(C.data.f0curve{1}(2,:));
		max_resp_f1 = max(C.data.f1curve{1}(2,:));
		if max_resp_f0 > max_resp_f1, 
			F0orF1 = 0;
		else,
			F0orF1 = 1;
		end;
	end;

	[length_resp_p,vis_resp_p] = neuralresponsesig_grating(C.data,F0orF1);

	if F0orF1 == 0,
		length_curve = C.data.f0curve{1}(:,1:end/2);
		aperture_curve = C.data.f0curve{1}(:,1+end/2:end);
		aperture_curve(1,:) = [ 20 40 80 140 220 320 440 560 ];
		blank = C.data.blank.f0curve{1}(3:end);
	else,
		length_curve = C.data.f1curve{1}(:,1:end/2);
		aperture_curve = C.data.f1curve{1}(:,1+end/2:end);
		aperture_curve(1,:) = [ 20 40 80 140 220 320 440 560 ];
		blank = C.data.blank.f1curve{1}(3:end);
	end;
	length_curve(2,:) = length_curve(2,:) - blank(1);
	aperture_curve(2,:) = aperture_curve(2,:) - blank(1);

	if ~isempty(ds),
		g = load([getpathname(ds) filesep CT.data filesep 'stims.mat'],'-mat');
		gN = numStims(g.saveScript);
		for nn=1:gN,
			ppn = getparameters(get(g.saveScript,nn));
			if isfield(ppn,'contrast'),
				contrast(end+1) = getfield(ppn,'contrast');
				distance(end+1) = getfield(ppn,'distance');
			end;
		end;
		contrast = unique(contrast);
		distance = unique(distance);
		whatvaries = sswhatvaries(g.saveScript);
	end;

elseif ~isempty(B), % for cells that only saw the length tuning

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

	if F0orF1 == 0,
		length_curve = B.data.f0curve{1};
		blank = B.data.blank.f0curve{1}(3:end);
	else,
		length_curve = B.data.f1curve{1};
		blank = B.data.blank.f1curve{1}(3:end);
	end;
	length_curve(2,:) = length_curve(2,:) - blank(1);

	if ~isempty(ds),
		g = load([getpathname(ds) filesep BT.data filesep 'stims.mat'],'-mat');
		gN = numStims(g.saveScript);
		for nn=1:gN,
			ppn = getparameters(get(g.saveScript,nn));
			if isfield(ppn,'contrast'),
				contrast(end+1) = getfield(ppn,'contrast');
				distance(end+1) = getfield(ppn,'distance');
			end;
		end;
		contrast = unique(contrast);
		distance = unique(distance);
		whatvaries = sswhatvaries(g.saveScript);
	end;
end;

if ~isempty(length_curve),
	length_curve_norm = length_curve;
	length_curve_norm(2,:) = length_curve_norm(2,:)/max(length_curve_norm(2,:));
end;

if ~isempty(aperture_curve),
	aperture_curve_norm = aperture_curve;
	aperture_curve_norm(2,:) = aperture_curve_norm(2,:)/max(aperture_curve_norm(2,:));
end;

out = var2struct('vis_resp_p', 'length_resp_p', 'length_curve', 'length_curve_norm', 'aperture_curve', 'aperture_curve_norm', 'blank', 'contrast', 'distance', 'whatvaries');


