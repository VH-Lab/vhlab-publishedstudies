function chr2_makesnapshots(dirname, leave_open)
% CHR2_MAKESNAPSHOTS - Make response snapshots PDFs for optical (*visual) stimulation
%
%  CHR2_MAKESNAPSHOTS(DIRNAME, [LEAVE_OPEN]...)
%
%  For a given experimental day, make PDF snapshots of the responses.
%
%  Calls the function CHR2_PLOTOPTICALGRATINGRESPONSES to make figure snapshots of
%  of the responses to various stimuli.
%
%  Snapshots are saved in the 'analysis/figures' subfolder in the experiment
%  folder with the name 'CELLNAME_OPT_SNAP'.
%
%  At this time, only cells with index values beteween 400 and 499 are considered.
%
%  If LEAVE_OPEN is provided, then the Matlab figure windows will be left open instead
%  of being closed.
%
%  *eventually will produce snapshots for visual stimulation as well

if nargin>1, leaveopen = leave_open; else, leaveopen = 0; end;

ds = dirstruct(dirname);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

[cells,cellnames]=filter_by_index(cells,cellnames,50,499);

snapshotdir = [getpathname(ds) filesep 'analysis' filesep 'figures'];

if ~exist(snapshotdir), 
	mkdir(snapshotdir);
end;



for i=1:length(cells),
	if 1,
		try,
			mkdir([snapshotdir filesep 'optical_grating_responses']);
		end;
		fig_current = gcf;
		try,
			chr2_plotopticalgratingresponses(cells{i},cellnames{i});
			saveas(gcf,[snapshotdir filesep 'optical_grating_responses' filesep cellnames{i} '_OPT_SNAP.pdf']);
		end;
		if fig_current~=gcf,
			if ~leaveopen, close; end; % close the current figure
		end;
	end;
	if 1,
		try,
			mkdir([snapshotdir filesep 'visual_grating_responses']);
		end;
		fig_current = gcf;
		try,
			chr2_plotdirectiongratingresponses(cells{i},cellnames{i});
			saveas(gcf,[snapshotdir filesep 'visual_grating_responses' filesep cellnames{i} '_DIR_SNAP.pdf']);
		end;
		if fig_current~=gcf,
			if ~leaveopen, close; end; % close the current figure
		end;
	end;
end;


