function [im,scalebaraxes,scalebarimage] = dirtpocularpreferenceNEW2(tpf, property, pthresh, slicename, plotit, varargin)

%  DIRTPOCULARPREFERENCENEW2(TPF, PROPERTY, PTHRESH, SLICENAME, PLOTIT) - Analysis of
%  training effect of ocular transfter experiment, Plot Ocular prefence
%  maps (OD map) AND/OR direction turning curve before and after training 
%   groups:
%   trained eye, nontrained eye, 
%   cells that prefered the train angle and cells that orthogonal to the trained angle
%  
%  tpf, the file path of the twophoton file (e.g., 'E:\2photon\ferretdirection\oculartransfer\2010-01-07') 
%
%  property, associated name of each cells when adding to the database, see
%  colposstimid.m
%   2010-01-07, 2010-01-28, 2010-02-23: property = {'CONT ','IPSI ','CONT ME ','IPSI ME '};
%   2009-12-07: property = {'ME ','FE '}; t00010
%   2009-12-28: property = {'','ME '}; t00001
% 
%  pthresh, p value thresh to select cells, default is .05 for p value of
%  "OT visual resposne p", in order for the cells be appear, at least one
%  eye should be visual responsive
%  
%  slicename, 0 or slicename e.g., "t00002", if 0, than black background
%  [512 512], if not, then cell background defined by slicename
%  
%  plotit, 0 or 1, if 0, only OD map appear, if 1, direction turning curve
%  before and after training is plotted as well
%  
%  
%  features to add: modifiy colposstimid.m ??
%  see also pvcontinuousmap.m 

scalebaraxes = []; scalebarimage = [];

if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
    
	pt = pt(1,[1 2]); % get 2D proj
	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.pts,1),1)-ud.pts).^2')'),0);
    %keyboard;
	if v<50,
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} ' w/ value ' num2str(ud.values(i))...
                'w/' 'pt:' ' [' num2str(pt(1)) ',' num2str(pt(2)) '] and [i,v]:'  ' [' num2str(i) ',' num2str(v) ']' ]);
		else,
			disp(['Closest cell is # ' int2str(i) ' w/ value ' num2str(ud.values(i))...
                 'w/' 'pt:' ' [' num2str(pt(1)) ',' num2str(pt(2)) '] and [i,v]:'  ' [' num2str(i) ',' num2str(v) ']' ]);  
		end;
        ud.indexassoc;
        figure;
        myargs = {};
        plottpresponseOD(ud.cells{i},ud.cellnames{i},ud.indexassoc,1,1,ud.varargin{:});
	end;

	return;
end;

labels={'Contral eye', 'Ipsi eye'};

assign(varargin{:});

% load cells
ds = dirstruct(tpf);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
%[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp_001*','-mat');

myinds = [];
for j=1:length(cells),
    dirf2 = findassociate(cells{j},['TP ' property{1} 'Ach OT Fit Direction index blr'],'','');
    dirf2t = findassociate(cells{j},['TP ' property{2} 'Ach OT Fit Direction index blr'],'','');
    vp   = findassociate(cells{j},['TP ' property{1} 'Ach OT visual response p'],'',''); 
    vpt   = findassociate(cells{j},['TP ' property{2} 'Ach OT visual response p'],'','');
    
    if ~isempty(dirf2) & ~isempty(dirf2t) & (vp.data<pthresh || vpt.data<pthresh),
        myinds(end+1) = j; 
    end;
end;

mycells = cells(myinds);
mycellnames = cellnames(myinds);
%keyboard;
%%need modify	
% g = load('/users/yeli/documents/Data/minis/2009-12-07/analysis/scratch/preview_t00010_ch1.mat');
% gmax = max(g.pvimg(:));gmin = min(g.pvimg(:));
% im1 = rescale(g.pvimg,[gmin gmax],[0 1]);
if ischar(slicename),
    dirname = [tpf filesep slicename];
    im1 = previewprairieview(dirname,50,1,1);
    im1 = rescale(double(im1),[min(min(im1)) max(max(im1))],[0 1]);
else,  %keyboard;
    im1 = zeros(512,512);
    %im1 = zeros(slicename(2),slicename(1));
   
end;
    
im2 = im1; im3 = im1;

numcolors = length(0:100);
ctab = jet(numcolors);
mycolor = [0,0,0;1,0,0];
mystr = ['C';'I'];
if 0,
    for j = 1:2,
        for m = 1: findclosest(0:10,length(myinds)/25);
            dirfig(j-1+m) = figure;
        end;
        for i=1:length(myinds),
            n = floor((i-1)/25)+1;
            figure(dirfig(j-1+n));
            subplot(5,5,i-25*(n-1));
            fitx = 0:359;
            resp = findassociate(mycells{i},['TP ' property{j} 'Ach OT Response curve'],'','');
            resp = resp.data;
            fitd=findassociate(mycells{i},['TP ' property{j} 'Ach OT Carandini Fit'],'','');
            fity = fitd.data(2,:);
            blank = findassociate(mycells{i},['TP ' property{j} 'Ach OT Blank Response'],'','');
            blank = blank.data;
            xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
            vrp = findassociate(cells{i},['TP ' property{j} 'Ach OT visual response p'],'',''); 
            vvp = findassociate(cells{i},['TP ' property{j} 'Ach OT vec varies p'],'',''); 
            if vrp.data < .05 vrp = '*';else vrp = 'NS';end;
            if vvp.data < .05 vvp = '*';else vvp = 'NS';end;           
            h=myerrorbar(resp(1,:),resp(2,:),resp(4,:),'');
            set(h,'linewidth',1,'color',mycolor(j,:));		
            delete(h(2));
            hold on; hf = plot(fitx,fity,'k','linewidth',1,'color',mycolor(j,:));
            hold on; he=plot([0 360],blank(1)*[1 1],'k','linewidth',1,'color',mycolor(j,:));
            hold on; he1=plot([0 360],(blank(1)+blank(3))*[1 1],'k--','linewidth',1,'color',mycolor(j,:));
            hold on; he2=plot([0 360],(blank(1)-blank(3))*[1 1],'k--','linewidth',1,'color',mycolor(j,:));
            h0 = [h;hf;he;he1;he2];
            set(gca,'box','off');
            A = axis;
            %axis([min(fitx) max(fitx) A(3) A(4)]);
            ymin = min([resp(2,:),fity,(blank(1)-blank(3))]);
            ymax = max([resp(2,:),fity,(blank(1)+blank(3))]);
            axis([min(fitx) max(fitx) ymin-.01 ymax+.01]);
            %ylabel(ylab); xlabel(xlab);
            title([mystr(j) mycellnames{i}(9:15) ' vr:' vrp ' vv:' vvp],'interp','none');
            %axis equal;
        end;
    end;
end;

if plotit,
for m = 1: findclosest(0:10,length(myinds)/25);
        dirfig(m) = figure;
end;
end;

pts = []; inclpts = []; values = [];
for i=1:length(myinds),
    [OD,locinds,loc,ODdata] = newferretOD(mycells{i}, property);
    pki = findclosest(0:100,OD(6)*100);
    im1(locinds) = ctab(pki,1);
    im2(locinds) = ctab(pki,2);
    im3(locinds) = ctab(pki,3);
    [xyz]=tpgetcellposition(mycells{i});
    x = xyz(1);y = xyz(2);
    pts = [pts ; x y];
    inclpts(end+1) = i;
    values(end+1) = OD(1);
        
    n = floor((i-1)/25)+1;
    if plotit,
    figure(dirfig(n));
    subplot(5,5,i-25*(n-1));
    fitx = 0:359;
    resp = findassociate(mycells{i},['TP ' property{1} 'Ach OT Response curve'],'','');
    resp = resp.data;
    respt = findassociate(mycells{i},['TP ' property{2} 'Ach OT Response curve'],'','');
    respt = respt.data;
    fitd=findassociate(mycells{i},['TP ' property{1} 'Ach OT Carandini Fit'],'','');
    fity = fitd.data(2,:);
    fitdt=findassociate(mycells{i},['TP ' property{2} 'Ach OT Carandini Fit'],'','');
    fityt = fitdt.data(2,:);
    blank = findassociate(mycells{i},['TP ' property{1} 'Ach OT Blank Response'],'','');
    blank = blank.data;
    blankt = findassociate(mycells{i},['TP ' property{2} 'Ach OT Blank Response'],'','');
    blankt = blankt.data;
    xlab = 'direction (\circ)'; ylab = '\DeltaF/F';

    h=myerrorbar(resp(1,:),resp(2,:),resp(4,:),'');
    set(h,'linewidth',1,'color',[0,0,0]);		
    delete(h(2));
    hold on;
    ht=myerrorbar(respt(1,:),respt(2,:),respt(4,:),'');
    set(ht,'linewidth',1,'color',[1 0 0]);		
    delete(ht(2));
    
    hold on; hf = plot(fitx,fity,'k','linewidth',1);
    hold on; hft = plot(fitx,fityt,'k','linewidth',1,'color',[1,0,0]);
    hold on; he=plot([0 360],blank(1)*[1 1],'k','linewidth',1);
    hold on; het=plot([0 360],blankt(1)*[1 1],'k','linewidth',1,'color',[1,0,0]);
    hold on; he1=plot([0 360],(blank(1)+blank(3))*[1 1],'k--','linewidth',1);
    hold on; he1t=plot([0 360],(blankt(1)+blankt(3))*[1 1],'k--','linewidth',1,'color',[1,0,0]);
    hold on; he2=plot([0 360],(blank(1)-blank(3))*[1 1],'k--','linewidth',1);
    hold on; he2t=plot([0 360],(blankt(1)-blankt(3))*[1 1],'k--','linewidth',1,'color',[1,0,0]);
    h0 = [h;hf;he;he1;he2];
    h0t = [ht;hft;het;he1t;he2t];
    set(gca,'box','off');
    A = axis;
    %axis([min(fitx) max(fitx) A(3) A(4)]);
    ymin = min([resp(2,:),fity,(blank(1)-blank(3))]);
    ymint = min([respt(2,:),fityt,(blankt(1)-blankt(3))]);
    ymax = max([resp(2,:),fity,(blank(1)+blank(3))]);
    ymaxt = max([respt(2,:),fityt,(blankt(1)+blankt(3))]);
    axis([min(fitx) max(fitx) min([ymin,ymint])-.01 max([ymax,ymaxt])+.01]);
    %ylabel(ylab); xlabel(xlab);
    title([mycellnames{i}(9:15) ' ' num2str(OD(6),2) ' ' num2str(OD(5),2)],'interp','none');
    %axis equal;
    %keyboard; 
    end;
end;

im = cat(3,im1,im2,im3);

%Rp = fi.data(2,OtPi)-min(fi.data(2,OtNi),blankresp);

if 1,
    %ax = axes('position',[0.100    0.15    0.70    0.70]);
	figure;	
    imageh = image(im);%axes(ax);
    axis equal;
    
	% scale bar    
    scalebaraxes = axes('position',[0.9 0.11 0.05 0.8150]);
	scaleim1 = zeros(10,numcolors);
	scaleim2 = scaleim1; scaleim3 = scaleim1;
    ctab = jet(numcolors);
	for i=1:numcolors,
		scaleim1(:,i) = ctab(i,1);
		scaleim2(:,i) = ctab(i,2);
		scaleim3(:,i) = ctab(i,3);
	end;
    title('OD before');
	scalebarimage=image(cat(3,scaleim1',scaleim2',scaleim3'));
    
% 	set(gca,'fontsize',14);
 	set(gca,'xtick',[]);
% 	set(gca,'ytick',scalebarticks);
% 	ytick = get(gca,'ytick');
% 	yticklabs = {};
% 	for i=1:length(ytick),
% 		myind = findclosest(1:length(steps),ytick(i));
% 		yticklabs{i} = num2str(steps(myind),3);
% 	end;
% 	set(gca,'yticklabel',yticklabs);

	%axes(ax);
    %axis square;
end;

%    axis square;
if 1
    indexassocp = 'TP All Ach OT Fit Pref',
	myud = struct('pts',pts,'inclpts',inclpts,'cells',{mycells(inclpts)},'cellnames',{mycellnames(inclpts)},'indexassoc',indexassocp,'imagesize',[size(im,1) size(im,2)],...
        'values',values,'traindir',traindir);
    myud.varargin = varargin;
	set(gcf,'userdata',myud);
	set(imageh,'ButtonDownFcn','dirtpocularpreferenceNEW2');
	%keyboard;
end;
 
global myimmap

myimmap = im;


% % figure;
% % [Xn,Yn]=tpscatterplot(mycells,mycellnames,'TP Ach OT Fit Direction index blr','x',...
% %         'TP ME Ach OT Fit Direction index blr','y',2,...
% % 		'markersize',6,'colors',[0 0 0],'marker','o','clickfunction','plottpresponseclick','property','Recovery OT Fit Pref');
% % axis([0 1 0 1]);
% % hold on
% % plot([0 1],[0 1],'k--');
% % ylabel('Dir index after(\circ)'); 
% % xlabel('Dir index before(\circ)');
% %axis equal;
% 
% %dirtraintpexpsummary(cells,cellnames);
