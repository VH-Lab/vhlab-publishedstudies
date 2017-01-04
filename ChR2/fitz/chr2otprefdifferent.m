function p = chr2otprefdifferent(cell)

% CHR2OTPREFDIFFERENT
%
%  P=CHR2OTPREFDIFFERENT(CELL)
%
%  Gives probability that orientation measured with ChR2 and without ChR2
%  are different.
%

A = findassociate(cell,'SP F0 1 Ach OT Response curve','','');
B = findassociate(cell,'SP F0 2 Ach OT Response curve','','');
C = findassociate(cell,'SP F0 1 Ach OT Response struct','','');
D = findassociate(cell,'SP F0 2 Ach OT Response struct','','');


p = 1;

keyboard
