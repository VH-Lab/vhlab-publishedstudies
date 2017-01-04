function stim=createmodeloristim(stimspacex,stimspacey,ori,length,width)

values = zeros(size(stimspacex));
xi = stimspacex(1,:);  x0 = findclosest(xi,-length/2); x1 = findclosest(xi,length/2);
yi = stimspacey(:,1);  y0 = findclosest(yi,-width/2);  y1 = findclosest(yi,width/2);

ori = -ori/(180/pi);
trans = [cos(ori) -sin(ori) ; sin(ori) cos(ori)];

rotspace = (trans*[reshape(stimspacex,prod(size(stimspacex)),1) reshape(stimspacey,prod(size(stimspacey)),1)]')';
rotspacex = reshape(rotspace(:,1),size(stimspacex,1),size(stimspacey,2));
rotspacey = reshape(rotspace(:,2),size(stimspacey,1),size(stimspacey,2));
values(x0:x1,y0:y1) = 1;

stim = griddata(rotspacex,rotspacey,values,stimspacex,stimspacey,'linear');
stim(find(isnan(stim))) = 0;

return;
pts = [-length width; -length -width; length -width; length width; -length width]/2;
pts = (trans*pts')';
stim = single(inpolygon(stimspacex,stimspacey,pts(:,1),pts(:,2)));

