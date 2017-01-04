function im_ = makesingleconditiondirimage(ds,dirname,sitename,plotit,edgegain)

singlecondfile = [getscratchdirectory(ds) filesep sitename '_' dirname '_SC'];
G = load(singlecondfile,'-mat');
indimages = G.indimages; clear G;
pv = load([getscratchdirectory(ds) filesep 'preview_' dirname '_ch1.mat']);


mn = Inf; mx  = -Inf;
for i=1:length(indimages),
    mn = min(mn,min(min(indimages{i})));
    mx = max(mx,max(max(indimages{i})));
end;
for i=1:length(indimages),
    indimages{i} = rescale(indimages{i},[0 mx]*edgegain,[0 4000]);
end;

%indimages{9} = rescale(pv.pvimg,[min(min(pv.pvimg)) 3000], [0 4000]); %max(max(pv.pvimg))],[0 4000]);

dirorder = [8 1 2 7 9 3 6 5 4];
dirorder = [1 2 3 8 9 4 7 6 5]; % 45 deg shift for ferret head position

i = 1;
imstart = i;
im_ = zeros(3*size(indimages{1},1),3*size(indimages{1},2));
ctr = [ ];
for j=1:3,
	for k=1:3,
		im_(1+(j-1)*size(indimages{dirorder(i)},1):j*size(indimages{dirorder(i)},1),1+(k-1)*size(indimages{dirorder(i)},2):k*size(indimages{dirorder(i)},2))=indimages{dirorder(i)};
		ctr(end+1,[1:2])=[median(1+(j-1)*size(indimages{dirorder(i)},1):j*size(indimages{dirorder(i)},1)) median(1+(k-1)*size(indimages{dirorder(i)},2):k*size(indimages{dirorder(i)},2))];
		i=i+1;
	end;
end;
imend = i-1;
if plotit,
	imagedisplay(im_,'Title',[dirname]);
end;
