function [oi_theory, ois,cvs,vecmags] = TestNew2

% TESTNEW2 - A head-to-head competition between 3 orientation measures
%
%
%

ois = [];
oi_theory = [];
cvs = [];
vecmags = [];

 % vary the amount of orientation selectivity systematically (looping over i),

 % and compute 5 repeated measurements for each amount (looping over j)
 
for k=1:25,
    k
    for i=1:20,
          output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',1,'anglestep',22.5,'noise_level',0);
          oi_t = compute_orientationindex(0:359,output.FITCURVE);
        for j=1:100,
            output = OriDirCurveDemo('Rp',i/2,'Rn',i/4,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0,'anglestep',22.5,'noise_level',5);
            oi_theory(i,j) = oi_t;
            ois(i,j) = compute_orientationindex(output.measured_angles,output.orimn);
            cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
            vecmags(i,j) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
        end;
	end;
    std_2(k,:) = std(ois,0,2)';
    std_3(k,:) = std(cvs,0,2)';
    std_4(k,:) = std(vecmags,0,2)';
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

%
x = mean(oi_theory,2)

std1 = std(oi_theory,0,2)'
std2 = std(ois,0,2)'
std3 = std(cvs,0,2)'
std4 = std(vecmags,0,2)'

stderr2 = std2/(sqrt(25))
stderr3 = std3/(sqrt(25))
stderr4 = std4/(sqrt(25))

figure;


plot(x,std2,'go-');
hold on
plot(x,std3,'ko-');
plot(x,std4,'ro-');
errorbar(x,std2,stderr2,'g-')
errorbar(x,std3,stderr3,'k-')
errorbar(x,std4,stderr4,'r-')

xlabel('Underlying orientation selectivity index value (theoretical OSI value)');
ylabel('Standard deviation of ois (green), cvs (black), vecmags (red)');

box off;


