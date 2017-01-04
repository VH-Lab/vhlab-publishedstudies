function [oi_theory, ois,cvs,vecmags] = TestNew3

% TESTNEW - A head-to-head competition between 3 orientation measures
%
%
%

ois = [];
oi_theory = [];
cvs = [];
vecmags = [];


 % vary the amount of orientation selectivity systematically (looping over i),

 % and compute 5 repeated measurements for each amount (looping over j)

figure;

for i=1:4:20,
	hold on;
    output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',1,'noise_level',0)
	angles=0:359;
    [err,output.FITCURVE] = otfit_carandini_err([10-i/2 i/2 40 20 i/4],angles); 
    %[err,output.FITCURVE] = otfit_carandini_err([Rsp Rp Op sigma Rn],angles); 
    %[err,output.FITCURVE] = otfit_carandini_err([0 10 40 20 10-i/2],angles);    % direction


    osi_fit(i,1) = fit2fitoi([0:359;output.FITCURVE])
    pref_theory = i+10-i/2;
	orth_theory = 10-i/2;
    oi_theory(i,1) = (pref_theory - orth_theory)/pref_theory;
	ois(i,1) = compute_orientationindex(output.measured_angles,output.orimn);
	cvs(i,1) = compute_circularvariance(output.measured_angles,output.orimn);
    vecmags(i,1) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
    plot(0:359,output.FITCURVE)
end;

