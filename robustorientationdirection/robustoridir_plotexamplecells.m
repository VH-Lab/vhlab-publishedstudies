function robustoridir_plotexamplecells
% ROBUSTORIDIR_PLOTEXAMPLECELLS - Plot orientation/direction responses from example cells
%
%  Plots orientation/direction tuning responses from example cells
%
%

 % unoriented cell was generated with
 % output = OriDirCurveDemo('noise_level',2,'numTrials',5, 'Rsp',3,'Rp',0,'Rn',0); % how it was generated
 % direction-selective cell was generated with
 % output = OriDirCurveDemo('noise_level',2,'numTrials',5,'Op',30); % how it was generated 
 % cell that was only orientation selective but not direction selective was generated with
 %  output = OriDirCurveDemo('noise_level',2,'numTrials',5,'Opref',120,'Rn',10); % how it was generated
 %        NOTE: these cells were made when dirmean field of output from OriDirCurveDemo was called orimn

names = {'robustoridir_unorientedcell', 'robustoridir_orionly', 'robustoridir_dircell'};

for i=1:length(names),
	disp(['Working on cell ' names{i}]);

	output = getfield(load(names{i}),'output')
	% plot raw data
	figure;
	he=myerrorbar(output.measured_angles,output.orimn,output.oristde,output.oristde);
	axis([-22.5 360+22.5 0 16]);
	hold on;
	[dummy,real_fit] = otfit_carandini_err([output.Rsp output.Rp output.Opref output.sigma output.Rn],0:359);
	plot(0:359,real_fit,'k');

	[angles_ori,responses_ori] = dirspace2orispace(output.measured_angles,output.orimn);
	resp_ori = mean(responses_ori,2);

	figure;
	[hh,outputs]=polarplot_ori(angles_ori, resp_ori,'showmeanvector',1,'showcircularvariance',0);
	figure;
	[hh,outputs]=polarplot_dir(output.measured_angles, output.orimn,'showmeanvector',1,'showdircircularvariance',0);

	osi=compute_orientationindex(output.measured_angles,output.orimn),
	dsi=compute_directionindex(output.measured_angles,output.orimn),
	oneminuscv=1-compute_circularvariance(output.measured_angles,output.orimn),
	oneminusdcv=1-compute_dircircularvariance(output.measured_angles,output.orimn),

	outputs,
end;

