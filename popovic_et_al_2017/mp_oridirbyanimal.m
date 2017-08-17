function [out] = mp_oridirbyanimal(oridir)
% MP_ORIDIRBYANIMAL - Compute orientation and direction statistics by animal
%
%


cvs = {};
dirinds = {};

for i=1:5, % 5 different conditions
	cvs{i} = [];
	dirinds{i} = [];
	U = unique(oridir.animal_id{i});
	for j=1:numel(U),
		cvs{i}(j) = mean(oridir.cv_ind{i}(find(oridir.animal_id{i}==U(j))));
		dirinds{i}(j) = mean(oridir.dir_ind{i}(find(oridir.animal_id{i}==U(j))));
	end
end

clear oridir;
out = workspace2struct;
