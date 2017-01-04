function [newcell, responses] = responses_lengthtuning_contrast(ds, mycell, mycellname, gausswind)
% RESPONSES_LENGTHTUNING_CONTRAST - Read length tuning and contrast responses from cell
%
%  [NEWCELL, RESPONSES] = RESPONSES_LENGTHTUNING_CONTRAST(DS, MYCELL, MYCELLNAME, GAUSSWIND)
%
%  Reads in responses from length tuning and contrast stimulation.  The directory structure
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

 % step 4, extract the responses

responses.contrasts = [];
responses.lengths = [];
responses.thelengths = [];
responses.thecontrasts = [];
responses.mean = [];
responses.mean_blanksubtracted = [];
responses.stddev = [];
responses.stderr = [];
responses.indresps = {};
responses.f1mean = [];
responses.f1mean_blanksubtracted = [];
responses.f1stddev = [];
responses.f1stderr = [];
responses.f1indresps = {};

for i=1:length(goodlist),
	[dummy,dummy,dummy,dummy,dummy,s,co] = singleunitgrating2(ds,mycell,mycellname,goodlist{i},'stimnumber',0);

	start_row = length(responses.contrasts);

	contrasts_here = [];
	lengths_here = [];

	for j=1:numStims(s.stimscript),  % first loop through to examine contrasts and lengths that are here
		p = getparameters(get(s.stimscript,j));
		if ~isfield(p,'isblank'),
			contrasts_here(end+1) = p.contrast;
			lengths_here(end+1) = p.length;
		end;
	end;

	contrasts_here = unique(contrasts_here);
	lengths_here = unique(lengths_here);

	for j=1:numStims(s.stimscript),
		p = getparameters(get(s.stimscript,j));
		if ~isfield(p,'isblank'),
			k = find(contrasts_here==p.contrast);
			l = find(lengths_here==p.length);
	
			responses.thelengths(start_row+k,l) = p.length;
			responses.thecontrasts(start_row+k,l) = p.contrast;
			responses.mean(start_row+k,l) = co.f0curve{1}(2,j);
			responses.mean_blanksubtracted(start_row+k,l) = co.f0curve{1}(2,j)-co.blank.f0curve{1}(2,1);
			responses.stddev(start_row+k,l) = co.f0curve{1}(3,j);
			responses.stderr(start_row+k,l) = co.f0curve{1}(4,j);
			responses.indresps{start_row+k}{l} = co.f0vals{1}(:,j);
			responses.f1mean(start_row+k,l) = co.f1curve{1}(2,j);
			responses.f1mean_blanksubtracted(start_row+k,l) = co.f1curve{1}(2,j)-co.blank.f1curve{1}(2,1);
			responses.f1stddev(start_row+k,l) = co.f1curve{1}(3,j);
			responses.f1stderr(start_row+k,l) = co.f1curve{1}(4,j);
			responses.f1indresps{start_row+k}{l} = co.f1vals{1}(:,j);
		end;
	end;

	responses.contrasts = [responses.contrasts ; contrasts_here(:)];
	responses.lengths= [responses.lengths; lengths_here(:)];
end;

  % step 5, reorder the contrast rows so the go in order from lowest to highest

if gausswind,
	typestring = 'Contrast/length responses gauss';
else,
	typestring = 'Contrast/length responses sharp';
end;

assoc = struct('type',typestring,'owner','','data',responses,'desc','');

newcell = associate(mycell,assoc);


