function md = associate_all(md, associates)
% ASSOCIATE_ALL - Associate a list of measureddata objects with a list of associates
%
%  MDLIST = ASSOCIATE_ALL(MDLIST, ASSOCIATELIST)
%
%  Associates (verb) a list of associates (noun) with all of the 
%  measureddata objects in the cell list MDLIST.
%
%  See also: ASSOCIATE
%

for i=1:length(md),
	for j=1:length(associates),
		md{i} = associate(md{i},associates(j));
	end;
end;
