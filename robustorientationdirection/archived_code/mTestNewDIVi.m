function [oi_theory, ois,cvs,vecmags] = TestNewDIV

% TESTNEWDIV - A head-to-head competition between 3 orientation/direction measures
%
%
%

ois = [];
dis = [];
mdis = [];
oi_theory = [];
di_theory = [];
cvs = [];
dcvs = [];
vecmags = [];
dvecmags = [];


figure; 
 
for i=1:4:20,
    hold on;
    output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10+i/2,'sigma',20,'doplotting',0,'dofitting',1,'noise_level',0)
	angles=0:359;
    [err,output.FITCURVE] = otfit_carandini_err([0 10 40 20 10-i/2],angles);
    
    dsi_fit(i,1) = fit2fitdi([0:359;output.FITCURVE])
    pref_theory = i+10-i/2;
	opposite_theory = 10-i/2;
	orth_theory = 10-i/2;
	oi_theory(i,1) = (pref_theory - orth_theory)/pref_theory;
	di_theory(i,1) = (pref_theory - opposite_theory)/pref_theory;
	ois(i,1) = compute_orientationindex(output.measured_angles,output.orimn);
	cvs(i,1) = compute_circularvariance(output.measured_angles,output.orimn);
	dis(i,1) = compute_directionindex(output.measured_angles,output.orimn);
	dcvs(i,1) = compute_dircircularvariance(output.measured_angles,output.orimn);
	vecmags(i,1) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
	dvecmags(i,1) = compute_dirvecmod(output.measured_angles, output.orimn);
    plot(0:359,output.FITCURVE)
end;








