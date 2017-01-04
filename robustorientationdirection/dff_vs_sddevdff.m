function [sddev_dff, dff, sddev_dff_max, dff_max, slope, offset, slope_confinterval, stats] = dff_vs_sddevdff(structlist)
% DFF_VS_SDDEVDFF - Plot and compute relationship between mean delta F / F and the standard deviation of the same quantity
%
%  [STDDEV_DFF, DFF, SDDVEV_DFF_MAX, DFF_MAX, SLOPE, OFFSET, SLOPE_CONFINTERVAL] = DFF_VS_SDDEVDFF(STRUCTLIST)
%
%  STRUCTLIST should be a list of MEASUREDDATA object associates with at least one of the following entries:
%
%  'TP Ach OT Response struct'
%  'TP ME Ach OT Response struct'
%
%  The 'MAX' entries only include the largest response
% 

sddev_dff = [];
dff = [];
dff_max = [];
sddev_dff_max = [];

assoc_list = {'TP Ach OT Response struct', 'TP ME Ach OT Response struct'};

for i=1:length(structlist),
	for j=1:length(structlist{i}),
		if any(strcmp(structlist{i}(j).type, assoc_list)),
			dff = cat(1,dff,structlist{i}(j).data.curve(2,:)');
			sddev_dff = cat(1,sddev_dff,structlist{i}(j).data.curve(3,:)');

			[mx,mi] = max(structlist{i}(j).data.curve(2,:));
			dff_max(end+1) = mx;
			sddev_dff_max(end+1) = structlist{i}(j).data.curve(3,mi);
		end;
	end;
end;

inds = intersect(find(~isnan(dff)), find(~isnan(sddev_dff)));
dff = dff(inds);
sddev_dff = sddev_dff(inds);

[slope, offset, slope_confinterval, dummy, dummy, stats] = quickregression(dff,sddev_dff,0.05);

minx = min(dff);
maxx = max(dff);

figure;
%plot([minx maxx],slope*[minx maxx]+offset,'k--');
hold on;
plot(dff,sddev_dff,'k.');
box off;
xlabel('Mean Delta F / F');
ylabel('STDDEV Delta F / F');
title('Signal and noise in 2-photon recordings');

figure;
hold on;
plot(dff_max,sddev_dff_max,'k.');
box off;
xlabel('Mean Delta F / F');
ylabel('STDDEV Delta F / F');
title('Signal and noise in 2-photon recordings for maximum responses');

