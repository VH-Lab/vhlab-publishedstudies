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
%                                      typical rearing, agegroup == 90 (first entry)
%                                      typical rearing, agegroup == 60 (second entry)
%                                      typical rearing, agegroup == 40 (third entry)
%                                      dark reared , agegroup == 40 (fourth entry)
%                                      dark reared, grating training, agegroup == 40 (fifth entry)
% title_strings                    | A cell list of title strings describing each group in 'myinds'
% 

rearing_types = {cellinfo.rearing};
rearing_inds = { find(strcmp('typical',rearing_types))  find(strcmp('dark',rearing_types))  };  % typical, dark
training_types = {cellinfo.training_type};
training_inds = { find(strcmp('multidirectional',training_types)) find(strcmp('none',training_types)) };
agegrouping_inds = { find( [cellinfo.agegroup] == 40)  find( [cellinfo.agegroup] == 60) find([cellinfo.agegroup]==90) };

 % now length tuning info


 % plot typically-reared, absolute responses
 % then plot dark-reared, no training, absolute responses
 % then plot dark-reared, multidirectional trianing, absolute responses

myinds = { intersect(rearing_inds{1}, agegrouping_inds{1}), intersect(rearing_inds{2},training_inds{2}), intersect(rearing_inds{2},training_inds{1}) };
title_strings = {'TR P40','Dark reared','Dark reared, trained'};

myinds = { intersect(rearing_inds{1}, agegrouping_inds{3}), intersect(rearing_inds{1}, agegrouping_inds{2}), intersect(rearing_inds{1}, agegrouping_inds{1}), intersect(rearing_inds{2},training_inds{2}), intersect(rearing_inds{2},training_inds{1}) };
title_strings = {'TR 90', 'TR 60', 'TR P40','Dark reared','Dark reared, trained'};

studygroups = workspace2struct;
studygroups = rmfield(studygroups,'cellinfo');

