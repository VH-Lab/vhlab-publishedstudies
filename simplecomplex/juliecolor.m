function juliecolor

middle = [0 0 0];  % r g b
ON = [0 0 1.5];
OFF= [1.5 0 0];

cmap = OFF'*2*rectify([0:0.01:1]-0.5)+ON'*2*rectify(1-[0:0.01:1]-0.5) + repmat(middle',1,101);

cmap(find(cmap>1))=1; cmap(find(cmap<0))=0;

for i=1:100,
    cmap2(:,:,i) = cmap;
end;

cmap3(:,:,1) = cmap2(1,:,:);
cmap3(:,:,2) = cmap2(2,:,:);
cmap3(:,:,3) = cmap2(3,:,:);

figure;
image(cmap3);