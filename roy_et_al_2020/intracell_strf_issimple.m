function b = intracell_strf_issimple(name)
% INTRACELL_STRF_ISSIMPLE - is this cell a simple cell by our criteria?
%
% B = INTRACELL_STRF_ISSIMPLE(NAME)
%
% Given a name string such as 'intra _ 102@t00006', returns 0 or 1 if cell number (102 in this case)
% matches our list of simple cells.

sp = find(name==' ',1,'last');
amb = find(name=='@',1,'first');

if isempty(sp) | isempty(amb) | sp>amb,
	error(['error decoding name.']);
end;

num = str2num(name(sp+1:amb-1));

issimple = [34 40 41 102 110 116 120 121    25 26 56 58 59 60 63 65 67 68 80 84 86 95 96 119 ]; % arani

%issimple = [ 34, 40, 41, 102, 116, 120, 121, 122,  25, 26, 56, 58, 59, 60, 67, 80, 86, 95, 119]; % jason exclusion criteria added

b = ~isempty(intersect(num,issimple));

