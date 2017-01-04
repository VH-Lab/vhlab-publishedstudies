function [newcell, stimparams] = stimshape_lengthtuning_contrast(ds, mycell, mycellname, gausswind)
% STIMSHAPE_LENGTHTUNING_CONTRAST2 - Determine stimulus shape on the screen
%
%  [NEWCELL, STIMPARAMS] = RESPONSES_LENGTHTUNING_CONTRAST2(DS, MYCELL, MYCELLNAME, GAUSSWIND)
%
%  Reads in stimparams from length tuning and contrast stimulation.  The directory structure
%  DS is examined, and all records that contain stimuli that have stimuli that vary in size
%  or contrast will be included.  MYCELL is the cell to be examined.
%
%  If GAUSSWIND is 1, then only gratings that used a gaussian window will be included. If 0,
%  then only gratings with non-gaussian windows will be included.
%
%  Any directories that contain poor information should have their reference.txt files
%  renamed so they are not analyzed.
%
%  NOTE: This function assumes that the length step sizes are the same from experiment
%  to experiment.
%
%  The STIMPARAMS returned include the x center position, y center position, and length and contrast.
%

newcell = mycell;

 % step 1, identify the name/ref pair that corresponds to this cell

nameref = cellname2nameref(mycellname);

 % step 2, identify the directories in the directory structure DS where this name/ref pair was recorded

dirlist = gettests(ds,nameref.name,nameref.ref);

 % step 3, look at each directory and see if it has files that vary in length or contrast

goodlist = {};

for i=1:length(dirlist),
	stimfilename = [getpathname(ds) filesep dirlist{i} filesep 'stims.mat'];
	if exist(stimfilename),
		g = load(stimfilename);
		var = sswhatvaries(g.saveScript);  % what varies?
		if any(strcmp('rect',var))&any(strcmp('stimnumber',var))&any(strcmp('length',var)),
			p = getparameters(get(g.saveScript,1));
			if gausswind&p.windowShape==8, 
				goodlist{end+1} = dirlist{i};
			elseif ~gausswind&p.windowShape~=8,
				goodlist{end+1} = dirlist{i};
			end;
		end;
	end;
end;

 % step 4, 

stimparams.contrasts = [];
stimparams.lengths = [];
stimparams.thelengths = [];
stimparams.thecontrasts = [];
stimparams.x_center = [];
stimparams.y_center = [];

length_scale = 1;

if gausswind == 1,
	length_scale = 1/3;
end;

for i=1:length(goodlist),
	[dummy,dummy,dummy,dummy,dummy,s,co] = singleunitgrating_simple(ds,newcell,mycellname,goodlist{i},'stimnumber',0);

	start_row = length(stimparams.contrasts);

	contrasts_here = [];
	lengths_here = [];

	for j=1:numStims(s.stimscript),  % first loop through to examine contrasts and lengths that are here
		p = getparameters(get(s.stimscript,j));
		if ~isfield(p,'isblank'),
			contrasts_here(end+1) = p.contrast;
			lengths_here(end+1) = p.length * length_scale;
		end;
	end;

	contrasts_here = unique(contrasts_here);
	lengths_here = unique(lengths_here);

	for j=1:numStims(s.stimscript),
		p = getparameters(get(s.stimscript,j));
		if ~isfield(p,'isblank'),
			k = find(contrasts_here==p.contrast);
			l = find(lengths_here==p.length * length_scale);
	
			stimparams.thelengths(start_row+k,l) = p.length * length_scale;
			stimparams.thecontrasts(start_row+k,l) = p.contrast;
			stimparams.x_center(start_row+k,l) = mean([p.rect([1 3])]);
			stimparams.y_center(start_row+k,l) = mean([p.rect(1+[1 3])]);
		end;
	end;

	stimparams.contrasts = [stimparams.contrasts ; contrasts_here(:)];
	stimparams.lengths= [stimparams.lengths; lengths_here(:)];
end;

if gausswind,
	typestring = 'Contrast/length gauss stimsize';
else,
	typestring = 'Contrast/length sharp stimsize';
end;

assoc = struct('type',typestring,'owner','','data',stimparams,'desc','');

for i=1:length(assoc),
	newcell = associate(newcell,assoc(i));
end;


