function somegoodresp=plotrespnamessteps(cell,begstr,respname,fitname,signame,blankrespname,stepspname,varargin)
somegoodresp = 0;

subtractblank=0;
plotblankrange=[0 180];
plotcolors = [0 0 0; 0 0 1];
blankstepnum = [1];
stepblankxticks = [0 180+22.5];
blanksymbol = 'oso^d';
errorbartee = 4;
dontclose = 1;
usepolar = 0;
eb=1;
fit=1;
usesig=0;
xlims = [];

assign(varargin{:});
steps = findassociate(cell,stepspname,'','');

if ~isempty(steps), steps = steps.data; else, steps = []; end;
axis;
hold on;
for i=1:length(steps)
    [begstr ' ' int2str(i) ' ' respname],
	ras = findassociate(cell,[begstr ' ' int2str(i) ' ' respname],'',''),
	fita = findassociate(cell,[begstr ' ' int2str(i) ' ' fitname],'',''),
	siga = findassociate(cell,[begstr ' ' int2str(i) ' ' signame],'','');
	if ~isempty(blankrespname), bra = findassociate(cell,[begstr ' ' int2str(i) ' ' blankrespname],'','');
	else, bra = [];
	end;
	if isempty(siga), sigval = Inf; else, sigval = siga.data; end;
	if (usesig==0)|(usesig>0&sigval<0.05),
		somegoodresp = 1;
        if ~usepolar,
            if ~isempty(ras) & eb,
                if subtractblank&~isempty(bra),
                    h=myerrorbar(ras.data(1,:),ras.data(2,:)-bra.data(1),ras.data(4,:),ras.data(4,:),'',errorbartee);
                    set(h,'color',plotcolors(i,:));
                    delete(h(2));                   
                else,
                    h=myerrorbar(ras.data(1,:),ras.data(2,:),ras.data(4,:),ras.data(4,:),'',errorbartee);
                    set(h,'color',plotcolors(i,:));
                    delete(h(2));
                    if subtractblank&isempty(bra), warning(['No blank data to subtract.']); end;
                end;
            end;
            if ~isempty(fita) & fit,
                if ~isempty(xlims), myfitinds = find(fita.data(1,:)>=xlims(1)&fita.data(1,:)<=xlims(2));
                else, myfitinds = 1:length(fita.data(1,:));
                end;
                if subtractblank&~isempty(bra),
                    h=plot(fita.data(1,myfitinds),fita.data(2,myfitinds)-bra.data(1));
                    set(h,'linewidth',2,'color',plotcolors(i,:));		
                else,
                    h=plot(fita.data(1,myfitinds),fita.data(2,myfitinds));
                    set(h,'linewidth',2,'color',plotcolors(i,:));
                    if subtractblank&isempty(bra), warning(['No blank data to subtract.']); end;
                end;
            end;
            if ~isempty(bra)&(~subtractblank|plotblankrange)&(i==blankstepnum),
                h=plot(plotblankrange,bra.data(1)*[1 1],'k');
                h1=plot(plotblankrange,(bra.data(1)+bra.data(3))*[1 1],'k--');
                h2=plot(plotblankrange,(bra.data(1)-bra.data(3))*[1 1],'k--');
                set(h,'linewidth',2);
                set(h1,'linewidth',2);
                set(h2,'linewidth',2);
            elseif ~isempty(bra)&(~subtractblank|plotblankrange)&(i~=blankstepnum),
                h=myerrorbar(stepblankxticks(i),bra.data(1),bra.data(3),bra.data(3),'',errorbartee);
                set(h,'color',plotcolors(i,:));
                set(h(2),'marker',blanksymbol(i));
            end;
        else,
            if ~isempty(ras),
                hh=mmpolar(ras.data(1,:)*pi/180,ras.data(2,:),'ko','style','compass','TTickDelta',45,'RGridLineWidth',2,'TGridLineWidth',2,'fontname','arial','border','off','fontsize',16);
                set(hh,'color',plotcolors(i,:));
                hold on;
            end;
            if ~isempty(fita)&fit,
                hh=mmpolar(fita.data(1,:)*pi/180,fita.data(2,:),'style','compass','TTickDelta',45,'RGridLineWidth',2,'TGridLineWidth',2,'fontname','arial','border','off','fontsize',16);
                set(hh,'linewidth',2,'color',plotcolors(i,:));
            end;
        end;
	end;

end;
if somegoodresp == 0&~dontclose, close(gcf); end;
