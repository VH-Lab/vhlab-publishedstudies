function dodaceypca(prefix, expernames, varargin)

if nargin==0,
    ud = get(gcf,'userdata');
    pt = get(gca,'CurrentPoint');
    uda = get(gca,'userdata');
	pt = pt(1,[1 2]); % get 2D proj

	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.score(:,uda),1),1)-ud.score(:,uda)).^2')'),0);

	if v<50,
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} '.']);
		end;
        figure;
        myargs = {};
        i = ud.myinds(i);
        plottpresponse(ud.cells{i},ud.cellnames{i},'Color Dacey Expanded',1,1,ud.varargin{:});
	end;
    return;
end;


cellarch = {};
cellnamearch = {};

pcavec = [];
myinds = [];

for i=1:length(expernames),
    tpf = [ prefix filesep expernames{i}],
    ds = dirstruct(tpf);
    [cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');
    lastind = length(cellarch);
    cellarch = cat(2,cellarch,cells);
    cellnamearch = cat(1,cellnamearch, cellnames);
    
    for j=1:length(cells),
        
        p = findassociate(cells{j},'TP CEDE visual response p','','');
        a1=findassociate(cells{j},'TP CEDE Response curve','','');
        bl=findassociate(cells{j},'TP CEDE Blank Response','','');
        
        if ~isempty(p)&p.data<0.05&isgooddaceyexpanded(cells{j}),
            myinds(end+1) = lastind + j;
            pcavec = [pcavec; (a1.data(2,:)-bl.data(1))];
        end;
    end;
end;

keyboard;
normpcavec = pcavec./repmat(max(pcavec')',1,size(pcavec,2));
%normpcavec = pcavec./repmat(sum(pcavec')',1,size(pcavec,2));

[coeff,latent,explained]=pcacov(cov(normpcavec));

[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(4);
CF1 = ((Sc-Lc)-abs(Lc+Sc))';
CF2 = (abs(Sc)-abs(Lc))';
CF3 = 0.5*ones(size(Lc))';


mn = normpcavec - repmat(mean(normpcavec),size(normpcavec,1),1);
pvauto = (mn) * coeff;
pvman = (mn) * [CF1 CF2 CF3];
pv = pvauto;
figure;
set(gcf,'userdata',struct('myinds',myinds,'cells',{cellarch},'cellnames',{cellnamearch},'score',pvauto,'myscore',pvman,'coeff',coeff,'latent',latent,'explained',explained,'pcavec',pcavec,'varargin',{varargin}));
prs = [1 2; 1 3; 3 2]; plotnum = [ 3 1 4];
for i=1:3,
    subplot(2,2,plotnum(i));
    plot(pv(:,prs(i,1)),pv(:,prs(i,2)),'k.');
    set(gca,'buttondownfcn','dodaceypca');
    set(gca,'userdata',prs(i,:));
    xlabel(int2str(prs(i,1))); ylabel(int2str(prs(i,2)));
end;

cd e:\svanhooser\scone

save daceypca5.mat
