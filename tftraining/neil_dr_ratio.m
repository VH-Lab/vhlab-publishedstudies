function dr = neil_dr_ratio(thecell, testname, varargin)
% NEIL_DR_RATIO - Calculate direction ratio for Neil's data
%
%  DR = NEIL_DR_RATIO(THECELL, TESTNAME, ...)
%
% Loads data from TESTNAME (e.g., 'Dir1Hz3') and calculates the
% direction ratio for cell THECELL.  The training angle is looked
% up with the 'Training Angle' associate. 
%
% The behavior of the program can be modified by passing NAME/VALUE
% pairs as additional arguments:
% Parameter (default)            | Description:
% -------------------------------------------------------------------
% ErrorIfTrainingTypeNotUni (1)  | Generate an error if the Training Type
%                                |   associate is not 'unidirectional'.
% AssociateTestPrefix ('SP F0 ') | Prefix of associate to read
% AssociateTestPostfix           | Postfix of associate to read
% ('Ach OT Carandini Fit Params')|
% BlankTestPostfix               | Postfix of blank response
%  ('Ach OT Blank Response')     |

 % create default variables

ErrorIfTrainingTypeNotUni = 1;
AssociateTestPrefix = 'SP F0 ';
AssociateTestPostfix = 'Ach OT Carandini Fit Params';
BlankTestPostfix = 'Ach OT Blank Response';

assign(varargin{:});

if ErrorIfTrainingTypeNotUni,
	B = findassociate(thecell,'Training Type','','');

	if isempty(B),
		error(['No Training Type associate.']);
	end;

	if ~strcmp(lower(B.data),'unidirectional'),
		error(['Expected unidirectional training but got ' B.data '.']);
	end;
end;

A = findassociate(thecell,[AssociateTestPrefix testname ' ' AssociateTestPostfix],'','');
Bl= findassociate(thecell,[AssociateTestPrefix testname ' ' BlankTestPostfix],'','');
C = findassociate(thecell,'Training Angle','','');

if isempty(A),
	error(['No associate ' [AssociateTestPrefix testname ' ' AssociateTestPostfix] '.']);
end;
if isempty(Bl),
	error(['No associate ' [AssociateTestPrefix testname ' ' BlankTestPostfix] '.']);
end;
if isempty(C),
	error('No Training Angle associate.');
end;

dr = fit2fitdr_angle(A.data,Bl.data(1),C.data);

if isnan(dr), dr = 0; end;
