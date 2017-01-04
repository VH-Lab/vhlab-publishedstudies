function [oi_theory, ois,cvs,vecmags] = TestNew

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

for i=1:20,
    i,
    output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0);
	for j=1:100,
		output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0);
		pref_theory = i+10-i/2;
		orth_theory = 10-i/2;
		oi_theory(i,j) = (pref_theory - orth_theory)/pref_theory;
		ois(i,j) = compute_orientationindex(output.measured_angles,output.orimn);
		cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
		vecmags(i,j) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
	end;
end;

figure;

plot(oi_theory(:),ois(:),'go');
hold on
plot(oi_theory(:),1-cvs(:),'kx');
plot(oi_theory(:),vecmags(:),'rs');
plot(mean(oi_theory,2),mean(ois,2),'g-','linewidth',2);
plot(mean(oi_theory,2),mean(vecmags,2),'r-','linewidth',2);
plot(mean(oi_theory,2),mean(1-cvs,2),'k-','linewidth',2);
box off;

ylabel('Traditional OSI (Green), Vector magnitude (Red), Cir Var (Black)');
xlabel('Underlying orientation selectivity index value (theoretical OSI value)');


std1 = std(oi_theory,0,2)
std2 = std(ois,0,2)
std3 = std(cvs,0,2)
std4 = std(vecmags,0,2)


figure;


plot(mean(oi_theory,2),std2,'go-');
hold on
plot(mean(oi_theory,2),std3,'ko-');
plot(mean(oi_theory,2),std4,'ro-');

xlabel('Underlying orientation selectivity index value (theoretical OSI value)');
ylabel('OSI (Green), ]vector magnitude (Red), Standard Deviation (Black)');

box off;

%where did the line go??? PLAY AROUND WITH THIS FOR TOMORROW.

%plot(std1,std2,'co-','linewidth',2);
%plot(std1,std3,'bo-','linewidth',2);
%plot(std1,std4,'yo-','linewidth',2);

%std1 = std(oi_theory,0,2)
%std2 = std(ois,0,2)
%std3 = std(1-cvs,0,2)
%std4 = std(vecmags,0,2)

%std1 = std(mean(oi_theory,2))
%std2 = std(mean(ois,2))
%std3 = std(mean(1-cvs,2))
%std4 = std(mean(vecmags,2))




%plot((std1),std(ois,2),'g-','linewidth',2);
%plot((std1),std(vecmags,2),'r-','linewidth',2);
%plot((std1),std(1-cvs,2),'k-','linewidth',2);
%std1 = std(oi_theory, 2)
%std2 = std(ois,2)
%plot(std1,std2,'g-','linewidth',2);

%std3 = std(oi_theory,2)
%std4 = std(vecmags,2)
%plot(std3,std4,'r-','linewidth',2);

%std5 = std(oi_theory,2)
%std6 = std(1-cvs,2)
%plot(std5,std6,'k-','linewidth',2);

