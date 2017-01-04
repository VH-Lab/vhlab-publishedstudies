function analyze_ssm_all

prefix = '/Volumes/Data1/Ameya/';

dirnames = {'2012-06-27','2012-07-10','2012-07-24','2012-08-08','2012-08-14','2012-08-23'};

for i=1:length(dirnames),
	analyze_ssm([prefix dirnames{i}],1,1,0,1);
end;

