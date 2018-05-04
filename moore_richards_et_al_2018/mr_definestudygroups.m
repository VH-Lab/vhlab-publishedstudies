function studygroups = mp_definestudygroups(cellinfo)
% MP_DEFINESTUDYGROUPS - Identifies different study groups (animal ages, training conditions) for MP experiments
%
%  Returns a structure STUDYGROUPS with fields:
% 
%  Fieldname                       | Description
%  ------------------------------------------------------------------------------
%  rearing_types                   | A cell list of rearing type for each cell
%  rearing_inds                    | A cell list of cellinfo index values that match:
%                                  |   'typical' (first entry) or 'dark' (second entry)
%  training_types                  | A cell list of training type for each cell
%  training_inds                   | A cell list of cellinfo index values that match:
%                                  |   'multidirectional' (first entry) or 'none' (second entry)
%  agegrouping_inds                | A cell list of cellinfo index values for cellinfo.agegroup that match:
%                                  |   40 (first entry), 60 (second entry), 90 (third entry)
%  myinds                          | A cell list of cellinfo index values that match:
%                                  |   typical rearing, agegroup == 90 (first entry)
%                                  |   typical rearing, agegroup == 60 (second entry)
%                                  |   typical rearing, agegroup == 40 (third entry)
%                                  |   dark reared , agegroup == 40 (fourth entry)
%                                  |   dark reared, grating training, agegroup == 40 (fifth entry)
% gene_inds                        | A cell list of gene indexes
% title_strings                    | A cell list of title strings describing each group in 'myinds'
% 

rearing_types = {cellinfo.rearing};

rearing_inds = { find(strcmp('typical',rearing_types))  find(strcmp('2md',rearing_types))  };  % typical, 2 days monocular deprivation
agegrouping_inds = { find( [cellinfo.agegroup] == 27)  find( [cellinfo.agegroup] == 34) find([cellinfo.agegroup]==90) };
gene_inds = { find(strcmp('Rem2++',{cellinfo.Genotype})) find(strcmp('Rem2--',{cellinfo.Genotype})) }; 


 % plot typically-reared, absolute responses
 % then plot dark-reared, no training, absolute responses
 % then plot dark-reared, multidirectional trianing, absolute responses

myinds = { intersect(intersect(gene_inds{1}, agegrouping_inds{1}),rearing_inds{1}) ...
		intersect(intersect(gene_inds{1}, agegrouping_inds{1}), rearing_inds{2}) ...
		intersect(intersect(gene_inds{2}, agegrouping_inds{1}), rearing_inds{1}) ...
		intersect(intersect(gene_inds{2}, agegrouping_inds{1}), rearing_inds{2}) ...
		intersect(gene_inds{1},agegrouping_inds{2}) intersect(gene_inds{2},agegrouping_inds{2}) };
title_strings = {'Rem2++ P27', 'Rem2++ P27 2MD', 'Rem2-- P27', 'Rem-- P27 2MD', 'Rem2++ P34','Rem2-- P34'};

studygroups = workspace2struct;
studygroups = rmfield(studygroups,'cellinfo');

