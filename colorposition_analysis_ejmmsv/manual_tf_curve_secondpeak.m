function [out] = manual_tf_curve_secondpeak(x, y, stderr_values)
%MANUAL_TF_CURVE_SECONDPEAK - Examine (manually) and report if there is a secondary peak in TF tuning curve
%
%  TF_SECONDARY_PEAK = MANUAL_TF_CURVE_SECONDPEAK(X, Y, STDERR_VALUES)
%
%  Presents the user with a graph of the TF tuning curve, and graphically
%  prompts the user with 2 questions: is there a secondary peak, and, if so,
%  where is it?
%
%  If the user indicates there is no secondary peak, then TF_SECONDARY_PEAK is NaN.
%  Otherwise, it is the temporal frequency indicated.
%


f = figure;
errorbar(x,y,stderr_values);

name= 'Characterize TF curve';
prompt = {'Is there a prominent secondary peak 0/1','If so, what is value of secondary peak?'};
numlines = 1;
defaultanswer = {'0','NaN'};

answer = inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer),
	out = [];
	return;
end;

issecondarypeak = eval(answer{1});

if issecondarypeak,
	out = eval(answer{2});
else,
	out = NaN;
end;

close(f);
