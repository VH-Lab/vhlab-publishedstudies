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

 % vary the amount of orientation selectivity systematically (looping over i),
 % and compute 5 repeated measurements for each amount (looping over j)

for i=1:20,
	for j=1:100,
		output = OriDirCurveDemo('Rp',4*i,'Rn',i,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0);
		pref_theory = 4*i+(10-i/2);
		opposite_theory = i+(10-i/2);
		orth_theory = 10-i/2;
		oi_theory(i,j) = (pref_theory - orth_theory)/pref_theory;
		di_theory(i,j) = (pref_theory - opposite_theory)/pref_theory;
		ois(i,j) = compute_orientationindex(output.measured_angles,output.orimn);
		cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
		dis(i,j) = compute_directionindex(output.measured_angles,output.orimn);
		dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.orimn);
		vecmags(i,j) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
		dvecmags(i,j) = compute_dirvecmod(output.measured_angles, output.orimn);
	end;
end;

figure;

plot(di_theory(:),dis(:),'go');
hold on
plot(di_theory(:),1-dcvs(:),'kx');
plot(di_theory(:),dvecmags(:),'rs');
plot(mean(di_theory,2),mean(dis,2),'g-','linewidth',2);
plot(mean(di_theory,2),mean(dvecmags,2),'r-','linewidth',2);
plot(mean(di_theory,2),mean(1-dcvs,2),'k-','linewidth',2);
plot(mean(di_theory,2),mean(2*(1-cvs)-(1-dcvs),2),'b-','linewidth',2);
plot(di_theory(:),2*(1-cvs(:))-(1-dcvs(:)),'b^');
box off;

ylabel('Traditional DSI (Green), D Vector magnitude (Red), 1-DCircVar (Black)');
xlabel('Underlying orientation selectivity index value (theoretical OSI value)');

%
std2 = std(dis,0,2)
std3 = std(dvecmags,0,2)
std4 = std(1-dcvs,0,2)
std5 = std(2*(1-cvs)-(1-dcvs),0,2)

figure;

plot(mean(di_theory,2),std2,'go-');
hold on
plot(mean(di_theory,2),std3,'ro-');
plot(mean(di_theory,2),std4,'ko-');
plot(mean(di_theory,2),std5,'bo-');

box off;




















