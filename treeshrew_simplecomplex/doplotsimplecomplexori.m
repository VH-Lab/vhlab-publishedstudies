function doplotsimplecomplexori(prefix,expernames)

  % prefix = 'e:\svanhooser\data\';
  % expernames={'2008-05-22','2008-05-30','2008-06-05','2008-06-18'};

cells = {}; cellnames = {};

for i=1:length(expernames),
    ds = dirstruct([prefix filesep expernames{i}]);
    [mycells,mycellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    cells = cat(2,cells,mycells); cellnames = cat(2,cellnames,mycellnames');
end;

figure;
subplot(1,2,1);
[x,y,s]=plotsimplecomplexori(cells,1);
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.1, 2.0, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8],'linewidth',2);
ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
axis([0 1.5 -0.2 2]);
xlabel('2*F1/(F0+F1)'); ylabel('Depth (mm, adjusted)');
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);

subplot(1,2,2);
[x,y,s]=plotsimplecomplexori(cells,2);
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.1, 2.0, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8],'linewidth',2);
ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
axis([0 1.5 -0.2 2]);
xlabel('Orientation index'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);