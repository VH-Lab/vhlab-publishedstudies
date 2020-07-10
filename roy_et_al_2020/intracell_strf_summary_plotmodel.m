function intracell_strf_summary_plotmodel(oristruct)
%
%
%

oristruct = oristruct(strcmpi('mean',{oristruct.response_type}));

y = find([oristruct.young]==1);
o = find([oristruct.young]~=1);

fig = figure('tag','ori_model_summary');

subplot(2,2,1);
h=plot([-10 30],[-10 30],'k--')
hold on;
for y_ = 1:numel(y),
	plot(oristruct(y(y_)).actual.tuning_curve.mean, oristruct(y(y_)).model.tuning_curve.mean,'go')
end;
axis equal square
axis([-10 30 -10 30]);

title(['Naive']);
box off

ylabel('Predicted response');
xlabel('Actual response');

subplot(2,2,2);
h=plot([-10 30],[-10 30],'k--');
hold on
for o_ = 1:numel(o),
	plot(oristruct(o(o_)).actual.tuning_curve.mean, oristruct(o(o_)).model.tuning_curve.mean,'mo')
end;

axis equal square

title(['Experienced']);

box off

ylabel('Predicted response');
xlabel('Actual response');
axis([-10 30 -10 30]);

