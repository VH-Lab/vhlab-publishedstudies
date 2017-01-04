function assoc = string_to_associates(string, type_list)
% DIRNAMES_TO_ASSOCIATES - Create a list of associates that have a given string as a data field
% 
%   ASSOC = STRING_TO_ASSOCIATES(STRING, TYPE_LIST)
%
%   Creates a list of associates with the types in cell list TYPE_LIST.
%   The OWNER and DESC fields of the associate are left blank.
%

assoc = struct('type','','owner','','data','','desc','');
assoc = assoc([]);

if ischar(type_list),
	type_list = {type_list};
end;

for i=1:length(type_list),
	assoc(end+1) = struct('type',type_list{i},'owner','','data',string,'desc','');
end;
