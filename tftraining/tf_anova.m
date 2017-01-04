function [p,table,stats] = tf_anova(A1,A2, A3, TF)
% TF_ANOVA do an anova on TF responses
%
%   [P,TAB,STATS] = TF_ANOVA(A1,A2,A3,TF)
%
%   A1 and A2 are assumed to be columns of cell responses
%   measured under different condition.  The TF of each row
%   is given in TF.  An anovan is performed and the p value,
%   table and stats are returned.
%
%   Example:
%        z1 = load('FourHzInitial');
%        z2 = load('FourHz3Hours');
%        z3 = load('FourHz6Hours');
%        TF = [ ... ]; % fill in values
%        A1 = orderpref_null(z1.allcells1,TF);
%        A2 = orderpref_null(z2.allcells2,TF);
%        A3 = orderpref_null(z3.allcells3,TF);
%        [p,table,stats]=tf_anova(A1,A2,A3,TF);
% 

X = [];
G = [];

for i=1:size(A1,2),
	for j=1:size(A1,1),
		if ~isnan(A1(j,i)),
			if j<=size(A1,1)/2,
				up = 1;
			else,
				up = 0;
			end;
			G = [ G; TF(j) 1 up];
			X = [X; A1(j,i)];
		end;
	end;
end;

for i=1:size(A2,2),
	for j=1:size(A2,1),
		if ~isnan(A2(j,i)),
			if j<=size(A2,1)/2,
				up = 1;
			else,
				up = 0;
			end;
			G = [ G; TF(j) 2 up];
			X = [ X; A2(j,i)];
		end;
	end;
end;

for i=1:size(A3,2),
	for j=1:size(A3,1),
		if ~isnan(A3(j,i)),
			if j<=size(A3,1)/2,
				up = 1;
			else,
				up = 0;
			end;
			G = [ G; TF(j) 3 up];
			X = [ X; A2(j,i)];
		end;
	end;
end;

[p,table,stats]=anovan(X,G,'model',2,'varnames',strvcat('TF','cond','dir'));
