function make_horz_fig

filename = 'squ3_18_h2';
filename = 'treeshrewbead';

figure;

pts = load([filename '_results.txt'],'-ascii');
roi = load([filename '_roi.txt'],'-ascii');

roipts = roi(:,2:3)-repmat([pts(1,2) pts(1,3)],length(roi),1);
cellpts = pts(:,2:3)-repmat([pts(1,2) pts(1,3)],length(pts),1);

data = load([filename '_data'],'-mat');
scale = data.scale;

scalepts = cellpts / scale;
scaleroi = roipts / scale;

R = find(sqrt(scalepts(2:end,1).^2+scalepts(2:end,2).^2)>0.400);

scalepts = [scalepts(1,1:2) ; scalepts(R+1,1:2)];

plot(scalepts(2:end,1),scalepts(2:end,2),'bo');
set(gca,'fontsize',16,'fontweight','bold','linewidth',2);
hold on;
plot(scalepts(1,1),scalepts(1,2),'go');
CIRC_X = [ -0.40 : 0.01 : 0.40];
CIRC_Y = sqrt([ 0.40^2 - CIRC_X.^2 ]);
plot(CIRC_X,CIRC_Y,'g','linewidth',2);
plot(CIRC_X,-CIRC_Y,'g','linewidth',2);
plot([scaleroi(:,1);scaleroi(1,1)],[scaleroi(:,2);scaleroi(1,2)],'r','linewidth',2);
ylabel('mm','fontsize',16,'fontweight','bold');
xlabel('mm','fontsize',16,'fontweight','bold');
axis equal;

