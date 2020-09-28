function intracell_strf_markgarbage_all(experstruct, prefix)
% INTRACELL_STRF_FORMAT_ALL - use the index file to properly format all intracellular recording sessions from Arani
%
% INTRACELL_STRF_FORMAT_ALL(EXPERSTRUCT, PREFIX)
%
% EXPERSTRUCT is a tab-delimited file with fields 'Date' (indicating session date), 'cellNo' (indicating cell number),
% 'tuningCurve' (indicating the t folders to use for tuning curve data), 'revCorr' (indicating the t folders to use for reverse correlation data)
%
% Calls INTRACELL_STRF_FORMAT_EXP_DIR for each session.
%
% By default, PREFIX is '/Volumes/van-hooser-lab/Users/steve/araniintracellular/'

if nargin<2,
	prefix = '/Volumes/van-hooser-lab/Users/steve/araniintracellular/';
end

z = experstruct;

for i=1:numel(z),

	disp(['Now working on line ' int2str(i) ' of ' int2str(numel(z)) '.'])

	expdatenum = datenum(z(i).Date);
	expname = datestr(expdatenum,'yyyy-mm-dd');

	E = ndi_vhlab_expdir(expname,[prefix filesep expname]);
	
	gapp = ndi_app_markgarbage(E);

	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	z(i).cellNo,
	sharpprobe = getprobes(E, 'type', 'sharp-Vm', 'reference', z(i).cellNo);
	if numel(sharpprobe)~=1,
		error(['No sharp probe with the right number.']);
	end

	gapp.clearvalidinterval(sharpprobe{1});

	if ~any(isnan(z(i).reps_tuningcurve)),
		% meaning: stimuli N through M; it is the time of the Nth stimulus experienced in t_directory given
		% it is defined by a certain epoch that is given
                tfoldernum = sscanf(z(i).tuningCurve,'t%d'); 
		epochid = sprintf('t%.5d', tfoldernum); % this is the epochid
		% now need to know time of the Nth stimulus rep

		[data,t,timeref] = stimprobe{1}.readtimeseriesepoch(epochid, 0, Inf);

		repid = vlt.neuro.stimulus.stimids2reps(data.stimid, numel(unique(data.stimid)));
		first_good_rep = find(repid==z(i).reps_tuningcurve(1),1,'first');
		last_good_rep = find(repid==z(i).reps_tuningcurve(end),1,'last');

		dt = median(diff(t.stimon));
		t0 = max(  t.stimon(first_good_rep) - dt, 0);
		t1 = t.stimon(last_good_rep) + dt;

		if isempty(t1), keyboard; end;

		gapp.markvalidinterval(sharpprobe{1},t0,timeref,t1,timeref);
	end

	if ~any(isnan(z(i).reps_revcorr)),
		tfoldernum = sscanf(z(i).revCorr,'t%d'); 
		epochid = sprintf('t%.5d', tfoldernum); % this is the epochid
		% now need to know time of the Nth stimulus rep

		[data,t,timeref] = stimprobe{1}.readtimeseriesepoch(epochid, 0, Inf);

		first_good_rep = z(i).reps_revcorr(1);
		last_good_rep = z(i).reps_revcorr(end);

		dt = median(diff(t.stimon));
		t0 = max(  t.stimon(first_good_rep) - dt, 0);
		t1 = t.stimon(last_good_rep) + dt;
		if isempty(t1), keyboard; end;

		gapp.markvalidinterval(sharpprobe{1},t0,timeref,t1,timeref);
	end	
end


