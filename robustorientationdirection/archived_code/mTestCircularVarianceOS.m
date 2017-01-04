function TestCircularVarianceOS
% TestCircularVarianceOS - Compare OSI vs. 1 - Circular Variance for measuring orientation selectivity
%
%   Produces a simulation of orientation-selective responses for underlying orientation selectivity values
%   ranging from 0.05 to 1.  
%
%   In the first figure, the raw underlying orientation selectivity curves are plotted.
%
%   In the second figure, OSI and 1-CirVar values for 5 example simulations at each underlying OSI
%   value are plotted. The mean OSI and 1-CirVar values for 25*5 example simulations at each
%   underlying OSI are shown.
%
%   In the third figure, the average standard deviation of OSI and 1-CirVar values for 25 runs of
%   5 simulations.
%

ois = [];
oi_theory = [];
cvs = [];
cvs_all = [];
ois_all = [];

theory_curve_figure = figure;
 
for k=1:25
    disp(['Starting simulation run ' int2str(k) ' of ' int2str(25) '.']);
    for i=1:20,
        output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',1,'anglestep',22.5,'noise_level',0);
	[dummy,real_fit] = otfit_carandini_err([output.Rsp output.Rp output.Opref output.sigma output.Rn],0:359);
	if k==1,
		figure(theory_curve_figure);
		hold on;
		plot(0:359,real_fit);
	end;
	oi_t = compute_orientationindex(0:359,real_fit);
        for j=1:5,  
            output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0,'anglestep',22.5,'noise_level',5,'numTrials',4);
            oi_theory(i,j) = oi_t;
            ois(i,j) = compute_orientationindex(output.measured_angles,output.dirmean);
            ois_all(i,j+(k-1)*5) = compute_orientationindex(output.measured_angles,output.dirmean);
            cvs(i,j) = compute_circularvariance(output.measured_angles,output.dirmean);
            cvs_all(i,j+(k-1)*5) = compute_circularvariance(output.measured_angles,output.dirmean);
        end;
    end;
    std_2(k,:) = std(ois,0,2)';
    std_4(k,:) = std(1-cvs,0,2)';
    if k==25,
       % plot means
	mean_figure = figure;
	plot(oi_theory(:),ois(:),'go'); % individual observations
	hold on
	plot(oi_theory(:),1-cvs(:),'kx'); % individual observations
	plot(mean(oi_theory,2),mean(ois_all,2),'g-','linewidth',2); % lines
	plot(mean(oi_theory,2),mean(1-cvs_all,2),'k-','linewidth',2); % lines
	box off;
    end;
end;
 
%
x = mean(oi_theory,2)
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
 
xlabel('Underlying orientation selectivity index value (theoretical OSI value)');
ylabel('Standard deviations w/ error bars; ois (blue), and 1-cvs (magenta)');

disp(['Real underlying OSI: ' mat2str(x) ]);

