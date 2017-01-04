function check_manually_scored_secondary_tf_peaks(output1,output2, out1, out2)
%CHECK_MANUALLY_SCORED_SECONDARY_TF_PEAKS - Manually score TF peaks from tree shrew data
%
%  CHECK_MANUALLY_SCORED_SECONDARY_TF_PEAKS(OUTPUT1,OUTPUT2, OUT1, OUT2)
%
%  Uses supersubplot to show the primary and secondary TF peaks
% 


for j=1:2,
	
	eval(['out = out' int2str(j) ';']);
	eval(['output = output' int2str(j) ';']);

	f = figure;
	for i=1:length(out),
		supersubplot(f,3,3,i);
		errorbar(output.all_x,output.all_reallyraw(i,:),output.all_stderr(i,:));
		[mx,mxloc] = max(output.all_reallyraw(i,:));
		mxloc_x = output.all_x(mxloc);
		hold on;
		A=axis;
		h1=patch(mxloc_x+[-0.5 0.5 0.5 -0.5],A([3 3 4 4]),[0.5 0.5 0.5]);
		movetoback(h1);
		if ~isnan(out(i)),
			h2=patch(out(i)+[-0.5 0.5 0.5 -0.5],A([3 3 4 4]),[0 0 0.5]);
			movetoback(h2);
		end;
		axis(A);
		box off;
	end;

end;

