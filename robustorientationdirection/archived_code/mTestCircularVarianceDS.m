function TestCircularVarianceDS
% TestCircularVarianceDS  Compare DSI vs. 1 - Dir Circular Variance for measuring orientation selectivity
%
%   Produces a simulation of direction-selective responses for underlying direction selectivity values
%   ranging from 0.05 to 1.
%
%   In the first figure, the raw underlying direction selectivity curves are plotted.
%
%   In the second figure, DSI and 1-DirCirVar values for 5 example simulations at each underlying DSI
%   value are plotted. The mean DSI and 1-DirCirVar values for 25*5 example simulations at each
%   underlying DSI are shown.
%
%   In the third figure, the average standard deviation of DSI and 1-DirCirVar values for 25 runs of
%   5 simulations.


dis = [];
di_theory = [];
cvs = [];
dcvs = [];
dcvs_all = [];
dis_all = [];

theory_curve_figure = figure;
 
for k=1:25
    disp(['Starting simulation run ' int2str(k) ' of ' int2str(25) '.']);
    for i=1:20,
        output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',0,'sigma',20,'doplotting',0,'dofitting',1,'anglestep',22.5,'noise_level',0);
	[dummy,real_fit] = otfit_carandini_err([output.Rsp output.Rp output.Opref output.sigma output.Rn],0:359);
	if k==1,
		figure(theory_curve_figure);
		hold on;
		plot(0:359,real_fit);
	end;
	di_t = compute_directionindex(0:359,real_fit);
        for j=1:5,  
            output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',0,'sigma',20,'doplotting',0,'dofitting',0,'anglestep',22.5,'noise_level',5,'numTrials',4);
            di_theory(i,j) = di_t;
            dis(i,j) = compute_directionindex(output.measured_angles,output.dirmean);
            dis_all(i,j+(k-1)*5) = compute_directionindex(output.measured_angles,output.dirmean);
            dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.dirmean);
            dcvs_all(i,j+(k-1)*5) = compute_dircircularvariance(output.measured_angles,output.dirmean);
        end;
    end;
    std_2(k,:) = std(dis,0,2)';
    std_4(k,:) = std(1-dcvs,0,2)';
    if k==25,
       % plot means
	mean_figure = figure;
	plot(di_theory(:),dis(:),'go'); % individual observations
	hold on
	plot(di_theory(:),1-dcvs(:),'kx'); % individual observations
	plot(mean(di_theory,2),mean(dis_all,2),'g-','linewidth',2); % lines
	plot(mean(di_theory,2),mean(1-dcvs_all,2),'k-','linewidth',2); % lines
	box off;
    end;
end;
 
%
x = mean(di_theory,2)
std2 = mean(std_2,1)';
std4 = mean(std_4,1)';
stderr2 = std(std_2,0,1)'/(sqrt(25))
stderr4 = std(std_4,0,1)'/(sqrt(25))
 
figure;
hold on;
plot(x,std2,'bx-');
plot(x,std4,'mx-');
errorbar(x,std2,stderr2,'b-')
errorbar(x,std4,stderr4,'m-')
box off;
 
xlabel('Underlying direction selectivity index value (theoretical DSI value)');
ylabel('Standard deviations w/ error bars; dis (blue), and 1-dcvs (magenta)');

disp(['Real underlying DSI: ' mat2str(x) ]);

