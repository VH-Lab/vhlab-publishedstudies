function mouse_tp_addvariables(dirname, age, sex, mouse_number_string, monocularly_deprived_onset, monocularly_deprived_offset, eye_deprived, dark_rearing_onset, dark_rearing_offset, strain_name, genotype_code, hemisphere_recorded)
% MOUSE_TP_ADDVARIABLES - Add associate variables to all cells in the database
% 
%   MOUSE_TP_ADDVARIABLES(DIRNAME, AGE, SEX, MONOCULARLY_DEPRIVED_ONSET, MONOCULARLY_DEPRIVED_OFFSET,
%       EYE_DEPRIVED, DARK_REARING_ONSET, DARK_REARING_OFFSET, STRAIN_CODE, GENOTYPE_CODE, HEMISPHERE_RECORDED)
%
%   Adds associate variables to all cells in the database for the experiment in directory
%   DIRNAME. 
%
%   AGE:  A number, postnatal days
%   SEX: string 'male' or 'female'
%   MOUSE_NUMBER_STRING: String with mouse number and ID info
%   MONOCULARLY_DEPRIVED_ONSET: Postnatal age of onset of monocular deprivation (or empty for none)
%   MONOCULARLY_DEPRIVED_OFFSET: Postnatal age of offset of monocular deprivation (or empty for none)
%   EYE_DEPRIVED: string, 'right' or 'left' or 'none' or 'both'
%   DARK_REARING_ONSET: Postnatal age of onset of dark-rearing (or empty for none)
%   DARK_REARING_OFFSET: Postnatal age of offset of dark-rearing (or empty for none)
%   STRAIN_NAME: a name
%   GENOTYPE_CODE: a number
%   HEMISPHERE_RECORDED: The hemisphere that was imaged or recorded: 'right' or 'left'
%   

 % STEP 1, create the associates

assoc=newassoc('Age','mouse_tp_addvariables',age,'Postnatal age');
if ~isempty(sex), assoc(end+1)=newassoc('Sex','mouse_tp_addvariables',lower(sex),'Animal sex'); end;
assoc(end+1)=newassoc('Mouse #','mouse_tp_addvariables',mouse_number_string,'Mouse number code');
if ~isempty(monocularly_deprived_onset),
	assoc(end+1)=newassoc('Monocularly Deprived Onset','mouse_tp_addvariables',monocularly_deprived_onset,...
		'Postnatal day of onset of monocular deprivation by lid suture');
end;
if ~isempty(monocularly_deprived_offset),
	assoc(end+1)=newassoc('Monocularly Deprived Offset','mouse_tp_addvariables',monocularly_deprived_offset,...
		'Postnatal day of offset of monocular deprivation');
end;
assoc(end+1)=newassoc('Eye Deprived','mouse_tp_addvariables',lower(eye_deprived),'Eye that was deprived, if any');
if ~isempty(dark_rearing_onset),
	assoc(end+1)=newassoc('Dark rearing onset','mouse_tp_addvariables',dark_rearing_onset,'Postnatal day of onset of dark-rearing');
end;
if ~isempty(dark_rearing_offset),
	assoc(end+1)=newassoc('Dark rearing offset','mouse_tp_addvariables',dark_rearing_offset,'Postnatal day of offset of dark-rearing');
end;
assoc(end+1)=newassoc('Strain','mouse_tp_addvariables',strain_name,'Strain name for identifying experimental condition');
assoc(end+1)=newassoc('Genotype code','mouse_tp_addvariables',genotype_code,'Genotype code for identifying experimental condition');
assoc(end+1)=newassoc('Hemisphere recorded','mouse_tp_addvariables',lower(hemisphere_recorded),'Hemisphere recorded');



 % STEP 2, check for errors

if isempty(age),
	error(['Age must be provided.']);
end;
if ~any(strcmp(eye_deprived,{'right','left','none','both'})),
	error(['Eye deprived must be string: ''right'', ''left'', ''both'', or ''none''']);
end;
if ~isempty(sex),  % unknown is not an error
	if ~any(strcmp(sex,{'male','female'})),
		error(['Sex must be string: ''male'' or ''female''']);
	end;
else,
	warning('No information about the animal''s sex was provided.');
end;
if ~any(strcmp(hemisphere_recorded,{'right','left'})),
	error(['Hemisphere_recorded must be string: ''left'' or ''right''']);
end;
if xor(isempty(monocularly_deprived_onset),isempty(monocularly_deprived_offset)),
	error(['Monocularly deprived onset and offset must either both be numbers or both be empty.']);
end;
if xor(isempty(dark_rearing_onset),isempty(dark_rearing_offset)),
	error(['Dark rearing onset and offset must either both be numbers or both be empty.']);
end;
if ~isempty(monocularly_deprived_onset),
	if strcmp(eye_deprived,'none'),
		error(['Monocular deprivation time given, eye_deprived cannot be ''none''.']);
	end;
end;



 % STEP 3, load the database, modify it, and save it back

ds = dirstruct(dirname);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

for i=1:length(cells),
	for j=1:length(assoc),
		[a,inds] = findassociate(cells{i},assoc(j).type,assoc(j).owner,'');
		if ~isempty(a),
			if i==1, disp(['Disassociating ' assoc(j).type '.']); end;
			cells{i} = disassociate(cells{i},inds);
		end;
	end;
end;

cells = associate_all(cells,assoc);

disp(['Now saving cells back to database.']);
saveexpvar(ds,cells,cellnames,0);


