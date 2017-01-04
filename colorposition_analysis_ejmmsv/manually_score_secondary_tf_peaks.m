function [out1,out2] = manually_score_secondary_tf_peaks(output1,output2)
%MANUALLY_SCORE_SECONDARY_TF_PEAKS - Manually score TF peaks from tree shrew data
%
%  [OUT1,OUT2] = MANUALLY_SCORE_SECONDARY_TF_PEAKS(OUTPUT1,OUTPUT2)
%
%  OUT1 is secondary peak for all cells in OUTPUT1 (or NaN if no secondary peak),
%  and OUT2 is secondary peak for all cells in OUTPUT2 (or NaN if no secondary peak).
% 
%  OUTPUT1 and OUTPUT2 are outputs of DOTFANALYSIS (see that function)
%

k = [ones(size(output1.all_reallyraw,1),1) (1:size(output1.all_reallyraw,1))'  ; 2*ones(size(output2.all_reallyraw,1),1) (1:size(output2.all_reallyraw,1))'];

out1 = -1 * ones(size(output1.all_reallyraw,1),1);
out2 = -1 * ones(size(output2.all_reallyraw,1),1);

random_order = randperm(size(k,1));

count = 0;
for i = random_order,
	if k(i,1)==1,
		out1(k(i,2)) = manual_tf_curve_secondpeak(output1.all_x,output1.all_reallyraw(k(i,2),:),output1.all_stderr(k(i,2),:));
	elseif k(i,1)==2, 
		out2(k(i,2)) = manual_tf_curve_secondpeak(output1.all_x,output2.all_reallyraw(k(i,2),:),output2.all_stderr(k(i,2),:));
	end;
	count = count+1;
	disp(['Completed ' int2str(count) ' of ' int2str(size(k,1)) '.']);
end;


