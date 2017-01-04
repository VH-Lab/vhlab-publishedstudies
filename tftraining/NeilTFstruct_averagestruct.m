function [out] = NeilTFstruct_averagestruct(TFstruct, threshold)
%
%  
%  The variable 'out' is a structure with the following fields:
%  Fieldname:   | Description     
%  ----------------------------------------------------------------
%  groups       | Group variables [TF_training_freq{0,1,4} time{1,2,3,4} animal{1..16}]
%  tf_axis      | TF axis for combined data
%  tf_resps     | Responses for that cell for those tf_axis values (normalized reponse)
%  dir_dos_tfs  | TFs at which Direction selectivity (DOS) is measured
%  dir_dos      | DOS for those tFs
%  dir_pop_tfs  | TFs at which Direction selectivity (POP) is measured
%  dir_pop      | POP for those tFs

groups = [];
tf_axis = [];
tf_resps = [];
dir_dos_tfs = [];
dir_dos = [];
dir_pop_tfs = [];
dir_pop = [];

for i=1:length(TFstruct),
	for j=1:length(TFstruct(i).TF_vis_significance),
		if TFstruct(i).TF_vis_significance{j}<threshold,
			groups(end+1,:) = [TFstruct(i).TF_trainingtf j TFstruct(i).TF_experid ];
			[tf_resps,tf_axis] = simpletable(tf_resps,tf_axis,...
				TFstruct(i).TF_responses_norm{j}(2,:),TFstruct(i).TF_responses_norm{j}(1,:));
			[dir_dos,dir_dos_tfs] = simpletable(dir_dos,dir_dos_tfs,...
				TFstruct(i).TF_DS_dos_BS_median{j}(1,:),TFstruct(i).TF_DS_TFlist{j}(1,:));
			[dir_pop,dir_pop_tfs] = simpletable(dir_pop,dir_pop_tfs,...
				TFstruct(i).TF_DS_pop_BS_median{j}(1,:),TFstruct(i).TF_DS_TFlist{j}(1,:));
		end;
	end;
end;

out = var2struct('groups','tf_axis','tf_resps','dir_dos_tfs','dir_dos','dir_pop_tfs','dir_pop');
