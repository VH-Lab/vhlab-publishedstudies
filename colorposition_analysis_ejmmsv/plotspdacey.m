function plotspdacey(cell,cellname)


cer = findassociate(cell,'SP F0 CEDE Response curve','','');
ces = findassociate(cell,'SP F0 CEDE sig S cone','','');
cesv = findassociate(cell,'SP F0 CEDE visual response p','','');
ceb = findassociate(cell,'SP F0 CEDE Blank Response','','');
cefit=findassociate(cell,'SP F0 CEDE Color Fit','','');
cefitparams=findassociate(cell,'SP F0 CEDE Color Fit Params','','');
cefitparamsnk=findassociate(cell,'SP F0 CEDE Color NK Fit Params','','');
cefitc=findassociate(cell,'SP F0 CEDE Color C Fit','','');
cefitd=findassociate(cell,'SP F0 CEDE Color D Fit','','');
cefitcomb=findassociate(cell,'SP F0 CEDE Color Comb Fit','','');
cefitnk=findassociate(cell,'SP F0 CEDE Color NK Fit','','');
cefitnkt=findassociate(cell,'SP F0 CEDE Color NKT Fit','','');	
cefitr4 = findassociate(cell,'SP F0 CEDE Color R4 Fit','','');

dinds = [1:12 15 16 13 14];
dinds1 = [1:12];
dinds2 = [15 16];
dinds3 = [13 14];
dinds1x = [1:12];
dinds2x = [13 14];
dinds3x = [15 16];  

plotnonsig = 1;
fit=1;
titlestr = '';

if ~isempty(cer)&~isempty(ces)&~isempty(cesv),
    if plotnonsig|(cesv.data<0.05), % if sig S and significant variation across all stims
        
        h=myerrorbar(cer.data(1,dinds1x),cer.data(2,dinds1),cer.data(4,dinds1),cer.data(4,dinds1),'',0.3);
        set(h,'color',[0 0 0],'linewidth',2);
        hold on;
        h=myerrorbar(cer.data(1,dinds2x),cer.data(2,dinds2),cer.data(4,dinds2),cer.data(4,dinds2),'',0.3);
        set(h,'color',[0 0 0],'linewidth',2);
        h=myerrorbar(cer.data(1,dinds3x),cer.data(2,dinds3),cer.data(4,dinds3),cer.data(4,dinds3),'k.',0.3);
        set(h,'color',[0 0 0],'linewidth',2);
        if ~isempty(ceb),
            plot([-100 100],ceb.data(1)*[1 1],'k-','linewidth',2);
            plot([-100 100],(ceb.data(1)+ceb.data(3))*[1 1],'k--','linewidth',2);
            plot([-100 100],(ceb.data(1)-ceb.data(3))*[1 1],'k--','linewidth',2);
        end;
        if fit==1&~isempty(cefitr4),
            plot(cefitr4.data.fit(1,dinds1x),cefitr4.data.fit(2,dinds1),'ms--','linewidth',2);
            plot(cefitr4.data.fit(1,dinds2x),cefitr4.data.fit(2,dinds2),'ms--','linewidth',2);
            plot(cefitr4.data.fit(1,dinds3x),cefitr4.data.fit(2,dinds3),'ms','linewidth',2);
            titlestr{1} = [cellname ',p=' num2str(cesv.data)];
            titlestr{2} = ['SE = ' num2str(cefitr4.data.se,2) ', LE = ' num2str(cefitr4.data.le,2) 'SI = ' num2str(cefitr4.data.si,2) ', LI = ' num2str(cefitr4.data.li,2) '.'];
            cefitparams = cefitnk;
            titlestr{3} = [' L = ' num2str(cefitparamsnk.data(1),2) ', S = ' num2str(cefitparamsnk.data(2),2) '.'...
                ', LC50=' num2str(cefitparamsnk.data(3),2) ', SC50=' num2str(cefitparamsnk.data(4),2) ...
                ', LN=' num2str(cefitparamsnk.data(5),2) ', SN=' num2str(cefitparamsnk.data(6),2) '.'];
            %if ~isempty(cefitc), plot(cefitc.data.fit(1,:),cefitc.data.fit(2,:)+ceb.data(1),'b--'); end;
            %if ~isempty(cefitd), plot(cefitd.data.fit(1,:),cefitd.data.fit(2,:)+ceb.data(1),'c','linewidth',4); end;
            %if ~isempty(cefitcomb), plot(cefitcomb.data.fit(1,:),cefitcomb.data.fit(2,:)+ceb.data(1),'r--'); end;
            %if ~isempty(cefitnkt), plot(cefitnkt.data.fit(1,:),cefitnkt.data.fit(2,:)+ceb.data(1),'g--'); end;
            if ~isempty(cefitnk), plot(cefitnk.data(1,dinds1x),cefitnk.data(2,dinds1),'s-','color',[0.8 0.8 0.8],'linewidth',2); end;
            if ~isempty(cefitnk), plot(cefitnk.data(1,dinds2x),cefitnk.data(2,dinds2),'s-','color',[0.8 0.8 0.8],'linewidth',2); end;
            if ~isempty(cefitnk), plot(cefitnk.data(1,dinds3x),cefitnk.data(2,dinds3),'s','color',[0.8 0.8 0.8],'linewidth',2); end;
        end;
        A = axis;
        if cesv.data>0.05, plot([0 17],A([3 4]),'k','linewidth',2); plot([0 17],A([4 3]),'k','linewidth',2); end;

        axis([0 17 A([3 4])]);
        
        title([titlestr],'interp','none');
        ylabel('Rate (Hz)');
        xlabel('Stim number');
    end
end


