function chr2_plotoverallchange(vars,output,cells,cellnames,experids, expernames,varname,label,yaxislabel)

if nargin==0, % it is a buttondownfcn,

	ud = get(gcf,'userdata');
        [i]=findclosestpointclick([ud.datapoints.x ud.datapoints.y]);

        cellindex = ud.datapoints.index(i);

        disp(['Closest point = ' mat2str([ud.datapoints.x(i) ud.datapoints.y(i)],2) ', found cell ' ud.cellnames{cellindex}]);

        chr2_plotdirectiongratingresponses(ud.cells{cellindex},ud.cellnames{cellindex});

        return;
end;

figure;

struct2var(vars);

data = eval(varname);
exper_params = [experids(:) ones(numel(experids),1)];

[data_,exper_indexes_] = conditiongroup2cell(data,exper_params(:,1),exper_params(:,2));
[data_sign,exper_indexes2_] = conditiongroup2cell(di_match_initial,exper_params(:,1),exper_params(:,2));

[h0,datapoints0]=median_within_between_plot(data_,exper_indexes_,{label},'expernames',expernames);
delete(h0(1:2:end-1));

	% going with or against the grain
data2 = data_;
data3 = data_;
data4 = data_;
for i=1:length(data2),
	data2{i}(find(data_sign{i}<0)) =NaN;  %  with the grain
	data2{i}(find(isnan(data_sign{i}))) =NaN;  %  set neither to NaN
	data3{i}(find(data_sign{i}>=0)) =NaN;  % against the grain
	data3{i}(find(isnan(data_sign{i}))) =NaN;  %  set neither to NaN
	data4{i}(find(~isnan(data_sign{i}))) = NaN; % no 'grain' 
end;

[h1,datapoints1]=median_within_between_plot(data2,exper_indexes_,{label},...;
	'marker','o');
delete(h1(2:2:end));
delete(h1(end));

[h2,datapoints2]=median_within_between_plot(data3,exper_indexes_,{label},...
	'marker','v');
delete(h2(2:2:end));
delete(h2(end));

[h3,datapoints3]=median_within_between_plot(data4,exper_indexes_,{label},...
	'marker','s');
delete(h3(2:2:end));
delete(h3(end));

hold on;
a = axis;
plot([a(1) a(2)],[0 0],'k--');

ylabel(yaxislabel);

datapoints = catstructfields(datapoints0,datapoints1);
datapoints = catstructfields(datapoints,datapoints2);
datapoints = catstructfields(datapoints,datapoints3);

ud = workspace2struct;

set(gcf,'userdata',ud);
set(gca,'ButtonDownFcn','chr2_plotoverallchange');
