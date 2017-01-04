function [p,table,stats] = tf_anova2di(DI1,DI2, TF)
% TF_ANOVA do an anova on TF responses
%
%   [P,TAB,STATS] = TF_ANOVDI2DI(DI1,DI2,TF)
%
%   DI1 and DI2 are assumed to be columns of DI values 
%   measured under different condition.  The TF of each row
%   is given in TF.  An anovan is performed and the p value,
%   table and stats are returned.
%
%   Example:
%        z1 = load('FourHzInitial');
%        z2 = load('FourHz3Hours');
%        TF = [ ... ]; % fill in values
%        [DI1,DI1] = orderpref_null(z1.allcells1,TF);
%        [DI2,DI2] = orderpref_null(z2.allcells2,TF);
%        [p,table,stats]=tf_anova2di(DI1,DI2,TF);
% 

X = [];
G = [];

for i=1:size(DI1,2),
	for j=1:size(DI1,1),
		if ~isnan(DI1(j,i)),
			G = [ G; TF(j) 1 ];
			X = [X; DI1(j,i)];
		end;
	end;
end;

for i=1:size(DI2,2),
	for j=1:size(DI2,1),
		if ~isnan(DI2(j,i)),
			G = [ G; TF(j) 2 ];
			X = [ X; DI2(j,i)];
		end;
	end;
end;

[p,table,stats]=anovan(X,G,'model',2,'varnames',strvcat('TF','cond'));
