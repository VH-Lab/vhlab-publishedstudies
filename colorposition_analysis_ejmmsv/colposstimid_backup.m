function [is_type,must_be_unique,must_ask,replace_existing] = colposstimid(type, script, md, nameref, dirname, otherunlabeleddirs,ds)

% COLPOSSTIMID - Identifies test directories for Color/Position tests
%
%  Conforms to the IDENTIFYTESTDIRGLOBALS standard.
%
%  [IS_TYPE,MUST_BE_UNIQUE,MUST_ASK,REPLACE_EXISTING,]=
%         COLPOSSTIMID(TYPE,SCRIPT,MD,NAMEREF,DIRNAME,
%              OTHERUNLABELEDDIRS,DS)
%
%  If called with no arguments then the function attempts to
%  add itself to the IDTestDir list.  If another function
%  already identifies a given stimulus type then a warning is
%  given and the function is replaced.
%
%  Understands the following types:
%
%  'Best OT recovery test'
%  'Best X pos recovery test'
%  'Best Y pos recovery test'
%  'Best GLUT orientation test'
%  'Best GABA orientation test'

types = {'Best OT recovery test','Best X pos recovery test','Best Y pos recovery test',...
	'Best GLUT orientation test','Best GABA orientation test','Best Flash OT recovery test'};

if nargin==0,
	identifytestdirglobals;
	for i=1:length(types),
		found = 0;
		for j=1:length(IDTestDir),
			if strcmp(IDTestDir(j).type,types{i}),
				found = 1;
				if ~strcmp(IDTestDir(j).function,'colposstimid'),
					warning(['Replacing test id function ' IDTestDir(j).function ...
						' with colposstimid for type ' types{i} '.']);
					IDTestDir(j).function = 'colposstimid';
				end;
				break;
			end;
		end;
		if ~found, IDTestDir(end+1) = struct('type',types{i},'function','colposstimid'); end;
	end;
	return;
end;

is_type=0; must_ask=0;must_be_unique=0;replace_existing=0;

for i=1:length(types),
	if strcmp(type,types{i}),
		if strcmp(type,'Best OT recovery test'), 
			[is_type,must_be_unique,must_ask,replace_existing]=ismytestdir(sswhatvaries(script),'angle',1,1,1);
		elseif strcmp(type,'Best Flash OT recovery test'),
			[is_type,must_be_unique,must_ask,replace_existing]=ismytestdir(sswhatvaries(script),'angle',1,1,1);			
		else,
			[is_type,must_be_unique,must_ask,replace_existing]=isother(type,script);
		end;
	end;
end;

function [is_type,mbu,ma,re] = ismytestdir(desc,param,munique,mustask,replaceexisting)
is_type=0;mbu=munique;ma=mustask;re=replaceexisting;
%is_type = 1;
if ~isempty(intersect(desc,param)), is_type = 1; end;
%if length(desc)==1, if strcmp(desc{1},param), is_type=1; end; end;

function [is_type,mbu,ma,ra] = isother(type,script);
is_type = 0; mbu = 0; ma = 0; ra = 0;
switch type,
	case {'Best X pos recovery test', 'Best Y pos recovery test'},
		testgood = 1;
		rects = [];
		for i=1:numStims(script),
			if ~isfield(getparameters(get(script,i)),'isblank'),
				testgood=testgood*strcmp('periodicstim',class(get(script,i)));
			end;
		end;
		if numStims(script)<3, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				if ~isfield(getparameters(get(script,i)),'isblank'),
					rects = [rects; getfield(getparameters(get(script,i)),'rect')];
				end;
			end;
			rs = max(diff(rects));
			if strcmp(type,'Best X pos recovery test')&rs(2)==rs(4)&rs(4)==0&rs(1)>0&rs(3)>0&rs(1)<70&rs(3)<70,
				is_type=1;mbu=1;ma=1;ra=1;
			elseif strcmp(type,'Best Y pos recovery test')&rs(1)==rs(3)&rs(1)==0&rs(2)>0&rs(4)>0&rs(2)<70&rs(4)<70,
				is_type=1;mbu=1;ma=1;ra=1;
			end;
		end;
	case {'Best GLUT orientation test','Best GABA orientation test'}, 
		testgood = 1;
		anglesCurr = [];
		for i=1:numStims(script),
			p = getparameters(get(script,i));
			testgood = testgood & isfield(p,'iontophor_curr');
			if ~testgood, break; end;
			if ~isfield(p,'isblank'),
				testgood = testgood * strcmp('periodicstim',class(get(script,i)));
				anglesCurr = [anglesCurr; p.angle p.iontophor_curr ];
			else, 
				anglesCurr = [anglesCurr; Inf p.iontophor_curr ];
			end;
		end;
        if ~isempty(anglesCurr)&(length(find(~isinf(unique(anglesCurr(:,1)))))<4), testgood = 0; end; % must be some angles
		if testgood,
			% now there must be one set of angles with a negative current for Glutamate, positive for GABA
			currsi0 = find(anglesCurr(:,2)==0);
			angs0 = sort(anglesCurr(currsi0,1));
			currs = unique(anglesCurr(:,2));
			testgood = 0;
			if strcmp(type,'Best GLUT orientation test'),  % must be at least one negative current w/ all angles represented
				goodcurrs = currs(find(currs<0));
				for i=1:length(goodcurrs),
					currsi = find(anglesCurr(:,2)==goodcurrs(i));
					if eqlen(angs0,sort(anglesCurr(currsi,1))), testgood = 1; break; end;
				end;
			elseif strcmp(type,'Best GABA orientation test'), % must be at least one positive current w/ all angles represented
				goodcurrs = currs(find(currs>0));
				for i=1:length(goodcurrs),
					currsi = find(anglesCurr(:,2)==goodcurrs(i));
					if eqlen(angs0,sort(anglesCurr(currsi,1))), testgood = 1; break; end;
				end;
			end;
		end;
		if testgood,
			is_type=1;mbu=0;ma=1;ra=1;
		end;
end;

