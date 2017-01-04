function [x,y,shape,inds]=plotsimplecomplexori(cells, xaxis)

useoi = 0;
plotbox = 0;

cla;
inds = [];
x = []; y = []; shape = [];
cmap=jet(100);
for i=1:length(cells),
    [f1f0,ori,oi,tunewidth,cv,di,sigori,dicv] = f1f0ratio(cells{i});
    bwAsoc = findassociate(cells{i},'SP F0 Ach black white fraction','','');
    bwSig = findassociate(cells{i},'SP F0 Ach lineweight varies p','','');
    bwpAsoc = findassociate(cells{i},'SP F0 Ach black white peak fraction','','');
    normareaover=findassociate(cells{i},'SP F0 Ach normalized area overlap','','');
    rd = tsrelative_depth(cells{i})/1000;
    col = [ 0.7 0.7 0.7];
    if ~isempty(bwpAsoc),
        if bwSig.data<0.05,
            %col = [1 1 0]+[1.5 -1.5 0]*2*rectify(bwpAsoc.data-0.5)+[-1.5 -1.5 1.5]*2*rectify(1-bwpAsoc.data-0.5);
            %col(find(col<0))=0; col(find(col>1)) = 1;
            col=cmap(round(bwpAsoc.data*100),:);
        end; 
    else,
	clear bwSig;
	bwSig.data = 1;
    end;
    % if 1) not is empty rd AND
    %    2) not is empty f1f0 AND
    %    3) not is empty bwAsoc AND bwSig.data<0.05, or if the xaxis does not equal 5
    if ~isempty(rd)&~isempty(f1f0)&(~(isempty(bwAsoc)&bwSig.data>=0.05&xaxis==5))&(~(isempty(bwpAsoc)&bwSig.data>=0.05&xaxis==6))&(~(isempty(bwAsoc)&bwSig.data>=0.05&xaxis==9)),
        inds(end+1) = i;
        hold on;
        oi = rescale(oi,[0 1],[0 1]);
        %cv = rescale(cv,[0 1],[0 1]);
        f1f0 = 2*rescale(f1f0,[0 1],[0 1]);
        if useoi,
            if oi>0.6, oiv = 0.15; oiw=0.03; elseif oi<.3, oiv = 0; oiw=0.03; else, oiv = 0.3; oiw=0.06; end;
        else, %cv
            if (1-cv)>0.6, oiv = 0.15; oiw=0.03; elseif (1-cv)<.3, oiv = 0; oiw=0.03; else, oiv = 0.3; oiw=0.06; end;
        end;
        if xaxis==1, xval = f1f0;
        elseif xaxis==2, xval = oi;
        elseif xaxis==3, xval = tunewidth/100;
        elseif xaxis==4, xval = cv;
        elseif xaxis==5, xval = bwAsoc.data;
        elseif xaxis==6, xval = bwpAsoc.data;
        elseif xaxis==7, xval = 1-cv;
	elseif xaxis==8, xval = 1-dicv;
	elseif xaxis==9, xval = 1-normareaover.data;
        end;
        %h=plotoribox(xval,rd,ori,oiw,0.03+0.15*oi,1,'k-');        
        if plotbox,
            h=plotoribox(xval,rd,ori,oiw,0.03+0.15*((1-cv)*(~useoi)+oi*(useoi)),1,'col',col);
        else,
            h=plot(xval,rd,'.','color',col,'markersize',9);
        end;
        
        x(end+1) = xval; y(end+1) = rd; shape(end+1)=ori;
    end;
end;

set(gca,'ydir','reverse'); axis equal; axis([0 2 0 2]); box off;
plot([0 2],[950 950]/1000,'k--');
plot([0 2],[1350 1350]/1000,'k--');
