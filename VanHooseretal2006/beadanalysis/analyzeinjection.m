function [ci, dens] = analyzeinjection(filename,injsize, plotit)

%  ANALYZEINJECTION - Analyze clustering and density of injection
%
%  [CI,DENS] = analyzeinjection(filename,injsize, plotit)
%

pts = load([filename '_results.txt'],'-ascii');
roi = load([filename '_roi.txt'],'-ascii');

roipts = roi(:,2:3)-repmat([pts(1,2) pts(1,3)],length(roi),1);
cellpts = pts(:,2:3)-repmat([pts(1,2) pts(1,3)],length(pts),1);

data = load([filename '_data'],'-mat');

scale = data.scale;

if plotit,
	scalepts = cellpts / scale;
	scaleroi = roipts / scale;

	figure;

	plot(scalepts(2:end,1),scalepts(2:end,2),'bo');
	set(gca,'fontsize',16,'fontweight','bold','linewidth',2);
	hold on;
	plot(scalepts(1,1),scalepts(1,2),'go');
	CIRC_X = [ -injsize : 0.01 : injsize];
	CIRC_Y = sqrt([ (injsize)^2 - CIRC_X.^2 ]);
	plot(CIRC_X,CIRC_Y,'g','linewidth',2);
	plot(CIRC_X,-CIRC_Y,'g','linewidth',2);
	plot(scaleroi(:,1),scaleroi(:,2),'r','linewidth',2);
	ylabel('mm','fontsize',16,'fontweight','bold');
	xlabel('mm','fontsize',16,'fontweight','bold');
	axis equal;
end;

densbins = [0.5:0.1:3];
[dens] = calc_cell_density(cellpts,roipts,scale,0.4,0.1,densbins,0.1);

[ci,ncells] = calc_cluster_index(cellpts,roipts,scale,injsize,1.0,0.1,0.5,0.1);

disp(['Median ci is ' num2str(median(ci)) '.']);

disp(['Saving results to ' filename '_data.']);
save([filename '_data'],'scale','dens','densbins','ci','ncells','-mat');
