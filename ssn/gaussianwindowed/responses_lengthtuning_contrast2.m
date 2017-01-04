function [newcell, responses] = responses_lengthtuning_contrast2(ds, mycell, mycellname, gausswind)
% RESPONSES_LENGTHTUNING_CONTRAST2 - Read length tuning and contrast responses from cell
%
%  [NEWCELL, RESPONSES] = RESPONSES_LENGTHTUNING_CONTRAST2(DS, MYCELL, MYCELLNAME, GAUSSWIND)
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
%  Why the 2?  This uses a different function to pull out the curves.
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
responses.blank = [];
responses.blankind = [];

length_scale = 1;

if gausswind == 1,
	length_scale = 1/3;
end;

distance_scale = 0;  % scale length by monitor distance and pixels per cm
global pixels_per_cm;

for i=1:length(goodlist),
	[dummy,dummy,dummy,dummy,dummy,s,co] = singleunitgrating_simple(ds,newcell,mycellname,goodlist{i},'stimnumber',0);

	start_row = length(responses.contrasts);

	contrasts_here = [];
	lengths_here = [];

	for j=1:numStims(s.stimscript),  % first loop through to examine contrasts and lengths that are here
		p = getparameters(get(s.stimscript,j));
		if distance_scale==0,
			distance_scale = p.distance;
		end;
		if ~isfield(p,'isblank'),
			contrasts_here(end+1) = p.contrast;
			lengths_here(end+1) = atan2(p.length*length_scale/pixels_per_cm, distance_scale)*180/pi;
		end;
	end;

	contrasts_here = unique(contrasts_here);
	lengths_here = unique(lengths_here);

	for j=1:numStims(s.stimscript),
		p = getparameters(get(s.stimscript,j));
		if ~isfield(p,'isblank'),
			k = find(contrasts_here==p.contrast);
			l = find(lengths_here==atan2(p.length*length_scale/pixels_per_cm, distance_scale)*180/pi);
	
			responses.thelengths(start_row+k,l) = atan2(p.length*length_scale/pixels_per_cm, distance_scale)*180/pi;
			responses.thecontrasts(start_row+k,l) = p.contrast;
			responses.mean(start_row+k,l) = co.f0curve{1}(2,j);
			responses.mean_blanksubtracted(start_row+k,l) = co.f0curve{1}(2,j)-co.f0blank(1);
			responses.stddev(start_row+k,l) = co.f0curve{1}(3,j);
			responses.stderr(start_row+k,l) = co.f0curve{1}(4,j);
			responses.indresps{start_row+k}{l} = co.f0vals{1}(:,j);
			responses.f1mean(start_row+k,l) = co.f1curve{1}(2,j);
			responses.f1mean_blanksubtracted(start_row+k,l) = co.f1curve{1}(2,j)-co.f1blank(1);
			responses.f1stddev(start_row+k,l) = co.f1curve{1}(3,j);
			responses.f1stderr(start_row+k,l) = co.f1curve{1}(4,j);
			responses.f1indresps{start_row+k}{l} = co.f1vals{1}(:,j);
		end;
	end;

	responses.contrasts = [responses.contrasts ; contrasts_here(:)];
	responses.lengths= [responses.lengths; lengths_here(:)];
end;

  % step 5, select the top contrast for a standard output
if size(responses.mean,1)>1, error(['have to deal with different sizes.']); end;

responses_all = responses;

responses.f0curve{1} = [responses.lengths(:)'; responses.mean(:)'; responses.stddev(:)'; responses.stderr(:)']; 
responses.f1curve{1} = [responses.lengths(:)'; abs(responses.f1mean(:)'); responses.f1stddev(:)'; responses.f1stderr(:)']; 
responses.f0vals = {reshape( cell2mat(co.f0vals{1}), length(co.f0vals{1}{1}), length(co.f0vals{1}) )};  %responses.indresps{1};
responses.f1vals = {reshape( cell2mat(co.f1vals{1}), length(co.f1vals{1}{1}), length(co.f1vals{1}) )};  %responses.indresps{1};
responses.blank.f0curve = {[0 ; co.f0blank(:)]};
responses.blank.f1curve = {[0 ; abs(co.f1blank(:))]};
responses.blank.f0vals = {co.f0blankinds(:)};
responses.blank.f1vals = {abs(co.f1blankinds(:))};

if gausswind,
	typestring = 'Contrast/length gauss resp';
else,
	typestring = 'Contrast/length sharp resp';
end;

assoc = struct('type',typestring,'owner','','data',responses,'desc','');
assoc(2) = struct('type',[typestring ' all'],'owner','','data',responses_all,'desc','');

for i=1:length(assoc),
	newcell = associate(newcell,assoc(i));
end;


