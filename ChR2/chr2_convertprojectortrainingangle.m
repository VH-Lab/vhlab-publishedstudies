function chr2_convertprojectortrainingangle(prefix,expernames)
% CHR2_CONVERTPROJECTORTRAININGANGLE - Convert a projector-based training angle to a retina-based angle
%
%  CHR2_CONVERTPROJECTORTRAININGANGLE(PREFIX,EXPERNAMES)
%
%  Looks through a list of EXPERNAMES in the directory PREFIX and performs the following procedures
%  to convert the training angle from projector-based coordinates to retina-based coordinates:
%
%    1) Copies the original trainingangle.txt file to trainingangle_projector.txt.
%    2) Creates a new trainingangle.txt file with a converted angle (assumes right hemisphere)
%    3) Checks to see if the 'Training Angle' associate of all cells in the experiment exists;
%          if it does, it changes it to be the retina-based one.
%    
%    Note that if the trainingangle_projector.txt file exists, then all steps are skipped
%    (it is assumed that this procedure was performed previously).
%

for i=1:length(expernames),
	disp(['Working with experiment ' expernames{i} '...']);
	if exist([prefix filesep expernames{i} filesep 'trainingangle.txt']) & ...
		~exist([prefix filesep expernames{i} filesep 'trainingangle_projector.txt']),
		% convert
		disp(['...conversion needed in experiment ' expernames{i} '...']);
		% step 1 - copy the original file
		movefile([prefix filesep expernames{i} filesep 'trainingangle.txt'],...
			[prefix filesep expernames{i} filesep 'trainingangle_projector.txt']);

		% step 2 - convert the angle
		projector_angle = load([prefix filesep expernames{i} filesep 'trainingangle_projector.txt'],...
			'-ascii');
		retina_angle = trainingangle_ctx2retina(projector_angle,'right');
		save([prefix filesep expernames{i} filesep 'trainingangle.txt'],'projector_angle','-ascii');

		disp(['...Reading existing cells...']);

		ds = dirstruct([prefix filesep expernames{i}]);
		[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
		for c=1:length(cells),
			[a,inds] = findassociate(cells{c},'Training Angle','','');
			if ~isempty(a),
				cells{c} = disassociate(cells{c},inds);
			end;
			cells{c} = associate(cells{c},newassoc('Training Angle','',retina_angle,''));
		end;
		disp(['...Writing cells to disk...']);
		saveexpvar(ds,cells,cellnames,0);
	end;
end;
