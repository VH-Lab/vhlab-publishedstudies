function doplotsimplecomplexori5_2(cells,cellnames, prefix, expernames)

  % prefix = 'e:\svanhooser\data\';
  % expernames={'2008-05-22','2008-05-30','2008-06-05','2008-06-18'};


if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

    xaxlabel = get(get(gca,'xlabel'),'string'),
    switch xaxlabel,
        case 'Orientation index',
            K = 1;
        case '2*F1/(F0+F1)',
            K = 2;
        case 'OFF/(OFF+ON)',
            K = 3;
    end;
    K,
    [i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.pts{K},1),1)-ud.pts{K}).^2')'),0);
	if v<50,
        i2 = i;
        i = ud.inds{K}(i);
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} ' w/ value ' num2str(ud.pts{K}(i2,1)) '.']);
		else,
			disp(['Closest cell is # ' int2str(i) ' w/ value ' num2str(ud.pts{K}(i2,1)) '.']);
		end;
        figure;
        subplot(2,2,1);
        plotf1f0OTcurve(ud.cells{i},ud.cellnames{i});
        subplot(2,2,2);
        plotlineweight(ud.cells{i},ud.cellnames{i});
        ch=findobj(gca,'type','text');
        delete(ch);
        plot([-5 -5],[0 10],'k-'); axis off;
        A=axis;
        plot([A(1) A(2)],[0 0],'k--');
        subplot(2,2,3);
        plotcycleavg(ud.cells{i},ud.cellnames{i});
	end;
	return;
end;

 % this is where the function really begins

figure;
pts = { [] [] [] };
subplot(1,3,2);
[x,y,s,inds{1}]=plotsimplecomplexori(cells,3); 
pts{1} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.8, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
%ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Tuning width/100'); ylabel('Depth (mm, adjusted)');
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;

subplot(1,3,1);
[x,y,s,inds{2}]=plotsimplecomplexori(cells,2);
pts{2} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.8, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
%ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1.5],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Orientation index'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;


subplot(1,3,3);
[x,y,s,inds{3}]=plotsimplecomplexori(cells,4);
global myvar
myvar.x = x; myvar.y = y; myvar.s = s;
pts{3} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.8, 0.2,'median',0);
mn = mean(x);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
plot([mn mn]*0+0.5,[-0.2 2],'k--','linewidth',1);
ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Circular variance'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;

ud.pts=pts; ud.cells=cells;ud.cellnames=cellnames;ud.inds=inds;
set(gcf,'userdata',ud,'buttondownfcn','doplotsimplecomplexori5_2');
