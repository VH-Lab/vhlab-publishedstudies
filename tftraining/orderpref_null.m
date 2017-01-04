function [A,DI] = orderpref_null(A, tfs)
% ORDERPREF_NULL - Order a matrix of temporal frequency responses 
%
%  [A,DI] = ORDERPREF_NULL(A, TFS)
%
%  A takes a matrix of responses to temporal frequencies in preferred
%  and null directions. Each column represents the activity of one cell.
%  The upper half of the column are the responses to one direction
%  and the bottom half of the column are the responses to the opposite
%  direction.  This function merely looks at the responses at 4Hz,
%  decides which is largest, and, if necessary, resorts the data so that
%  the preferred response is in the top half.

z = find(tfs==4);

for i=1:size(A,2),
	if A(z(1),i) < A(z(2),i), % we must flip
		A(:,i) = A(end:-1:1,i);
		%disp(['flipping']);
	end;
end;

DI = [];

for z=1:length(tfs)/2,
	DI(z,:) = (A(z,:) - A(length(tfs)+1-z,:))./(A(z,:)+A(length(tfs)+1-z,:)); 
end;
