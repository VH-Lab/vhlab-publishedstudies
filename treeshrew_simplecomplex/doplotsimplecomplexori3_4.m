function doplotsimplecomplexori3(cells,cellnames,prefix,expernames)

  % prefix = 'e:\svanhooser\data\';
  % expernames={'2008-05-22','2008-05-30','2008-06-05','2008-06-18'};


if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

    xaxlabel = get(get(gca,'xlabel'),'string'),
    switch xaxlabel,
        case {'Orientation index', 'CV','Overlap'},
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

figure;
pts = { [] [] [] };
subplot(1,3,2);
[x,y,s,inds{1}]=plotsimplecomplexori(cells,9);
pts{1} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.6, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
%ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Overlap'); ylabel('Depth (mm, adjusted)');
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3_3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;
x_overlap = x; y_overlap = y;


subplot(1,3,1);
[x,y,s,inds{2}]=plotsimplecomplexori(cells,1);
pts{2} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.6, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
%ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1.5],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('2*F1/(F0+F1)'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;
x_mod = x; y_mod = y;


subplot(1,3,3);
[x,y,s,inds{3}]=plotsimplecomplexori(cells,6);
pts{3} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.6, 0.2,'median',0);
mn = mean(x);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
plot([mn mn]*0+0.5,[-0.2 2],'k--','linewidth',1);
ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('OFF/(OFF+ON)'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;
x_onoff = x; y_onoff = y;

[x_ori,y_ori,s_,inds{4}] = plotsimplecomplexori(cells,7);

ud.pts=pts; ud.cells=cells;ud.cellnames=cellnames;ud.inds=inds;
set(gcf,'userdata',ud,'buttondownfcn','doplotsimplecomplexori3');

lll = {};
lll{2} = find(y_overlap>0.95&y_overlap<1.35);
lll{1} = find(y_overlap==2.133+.01|y_overlap==2.4+0.01);
lll{3} = find(y_overlap<0.95);
ll = {};
ll{2} = find(y_mod>0.95&y_mod<1.35);
ll{1} = find(y_mod==2.133+.01|y_mod==2.4+0.01);
ll{3} = find(y_mod<0.95);
l = {};
l{1} = intersect(inds{1}(lll{1}),inds{2}(ll{1}));
l{2} = intersect(inds{1}(lll{2}),inds{2}(ll{2}));
l{3} = intersect(inds{1}(lll{3}),inds{2}(ll{3}));

disp(['Significance: ON/OFF seg (overall, LGNvsL4,L4vsL23,LGNvs23): ' ...
	num2str(kruskal_wallis_test(x_overlap(lll{1}),x_overlap(lll{2}),x_overlap(lll{3})),3) ...
	', ' ...
	num2str(kruskal_wallis_test(x_overlap(lll{1}),x_overlap(lll{2})),3) ...
	', ' ...
	num2str(kruskal_wallis_test(x_overlap(lll{2}),x_overlap(lll{3})),3) ...
	', ' ...
	num2str(kruskal_wallis_test(x_overlap(lll{1}),x_overlap(lll{3})),3) ...
	]);

titlelist = {'LGN','L4','L2/3'};

figure;
for i=1:3,
    subplot(2,2,i); 
    zzz1 = [];
    zzz2 = [];
    for j=1:length(l{i}),
	zz1 = find(inds{2}==l{i}(j));
	zzz1(end+1) = zz1; 
	%z2 = find(inds{1}(lll{i})==l{i}(j));
	zz2 = find(inds{1}==l{i}(j));
	zzz2(end+1) = zz2;
    end;
    plot(x_mod(zzz1),x_overlap(zzz2),'k.');
    axis square; box off; axis([0 1.5 0 1]);
    hold on; plot([0 1.5],[0.5 0.5],'k--');
    plot([1 1],[0 1],'k--')
    xlabel('Modulation'); ylabel('ON/OFF seg');
    title(titlelist{i});
end;

ll = {};
ll{2} = find(y_ori>0.95&y_ori<1.35);
ll{1} = find(y_ori==2.133+.01|y_ori==2.4+0.01);
ll{3} = find(y_ori<0.95);
l = {};
l{1} = intersect(inds{1}(lll{1}),inds{4}(ll{1}));
l{2} = intersect(inds{1}(lll{2}),inds{4}(ll{2}));
l{3} = intersect(inds{1}(lll{3}),inds{4}(ll{3}));
figure;
for i=1:3,
    subplot(2,2,i); 
    zzz1 = [];
    zzz2 = [];
    for j=1:length(l{i}),
        zz1 = find(inds{4}==l{i}(j));
        zzz1(end+1) = zz1;
        %z2 = find(inds{1}(lll{i})==l{i}(j));
        zz2 = find(inds{1}==l{i}(j));
        zzz2(end+1) = zz2;
    end;
    plot(x_overlap(zzz2),x_ori(zzz1),'k.');
    axis square; box off; axis([0 1.5 0 1]);
    hold on; plot([0 1.5],[0.5 0.5],'k--');
    plot([1 1],[0 1],'k--')
    xlabel('ON/OFF seg'); ylabel('1-CV');
    title(titlelist{i});
end;


cols = [ 0 0 0 ; 0 0 0 ; 0.5 0.5 0.5];
syms = {'-','--','-'};
labs = {'Modulation','ON/OFF','ON/OFF seg','1-CV'};


figure;
for i=1:4, for j=1:3,
    subplot(2,2,i);
    if i==1, d = x_mod; yd = y_mod; elseif i==2, d = 2*abs(x_onoff-0.5); yd = y_onoff; elseif i==3, d = x_overlap; yd = y_overlap; elseif i==4, d = x_ori; yd = y_ori; end;
    l = {};
    l{2} = find(yd>0.95&yd<1.35);
    l{1} = find(yd==2.133+.01|yd==2.4+0.01);
    l{3} = find(yd<0.95);
    [X,Y]=cumhist(d(l{j}), [0 1.5], 0.01);
    hold on
    plot(X,Y,syms{j},'color',cols(j,:));
    title(labs{i});
    axis square; box off; axis([0 1.5 0 100]);
    if i>1, axis([0 1 0 100]); end;
end;end;

borders = [ 0              0.475 ;
            0.475          0.95  ; 
            0.95           0.95+0.13;
            0.95+0.13333   0.95+2*0.1333;
            0.95+2*0.13333 0.95+3*0.1333;
          ];

cols2 = gray(7);
syms2 = {'-','-','-','-','-','-'};

keyboard;

figure;
for i=1:4,
	for j=1:5,
		subplot(2,2,i);
		if i==1, d = x_mod; yd = y_mod;
		elseif i==2, d = 2*abs(x_onoff-0.5); yd = y_onoff;
		elseif i==3, d = x_overlap; yd = y_overlap;
		elseif i==4, d = x_ori; yd = y_ori;
		end;
		ddddi = find(yd>borders(j,1)&yd<=borders(j,2));
		[X,Y]=cumhist(d(ddddi), [0 1.5], 0.01);
		hold on
		plot(X,Y,syms2{j},'color',cols2(j,:));
		title(labs{i});
		axis square;
		box off;
		axis([0 1.5 0 100]);
		if i>1, axis([0 1 0 100]); end;
	end;
end;

figure;
d = x_onoff; yd = y_onoff;
l = {};
l{2} = find(yd>0.95&yd<1.35);
l{1} = find(yd==2.133+.01|yd==2.4+0.01);
l{3} = find(yd<0.95);
for i=1:3,
    [N,X]=quickhist(d(l{i}),[0:.1:1]);
    subplot(2,2,i);
    h=bar(X,N); set(h,'facecolor',[0 0 0 ]);
    axis([0 1 0 15]); box off;
end;


