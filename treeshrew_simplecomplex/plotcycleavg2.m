function plotcycleavg(mycell,mycellname, varargin)

testname = 'FineDir test';
fnameprefix = '/Volumes/Data1/jared/';
dirname = '';
param = 'angle';

if nargin>2,
    assign(varargin{:});    
end;

myassoc=findassociate(mycell,testname,'','');
if ~isempty(myassoc) | ~isempty(dirname),
    if isempty(dirname), dirname = myassoc.data; end;
    cn=mycellname(end-9:end);
    cn(find(cn=='_'))='-';
    %fname = ['e:\svanhooser\data\' cn];
    fname = [fnameprefix cn]; 
    ds = dirstruct(fname);
	[dummy,dummy,dummy,params,dummy,dummy,co]=singleunitgrating2(ds, mycell, mycellname, dirname, param, 0);

    [f1f0,dirpref,oiind,tunewidth,cv] = f1f0ratio(mycell);
    rs = findassociate(mycell,'SP F0 Ach OT Response struct','','');
    if isempty(rs),
	bl.data = 0;
    else,
	bl.data = rs.data.spont(1);
    end;
    
    best = 3; %findclosest(co.curve{1}(1,:),dirpref);
    ro = getoutput(co.cycg_rast{1});
    
    df = diff(ro.bins{best}(1:2));
    norm = 1/(ro.N(best)*df);
    tf = params{best}.tFrequency;
    
    %h=bar(ro.bins{best},ro.counts{best}*norm); box off;
    %set(h,'facecolor',[0 0 0]);
    values = sort(ro.rast{best}(1,:));
    values = [values-1/tf values values+1/tf];
    
    [Yn,Xn] = slidingwindowfunc(values, values, -0.050/2, 0.001, 1/tf+0.050, 0.050,'length',0);
    plot(Xn,Yn/(0.050*ro.N(best))-bl.data(1),'k-');
    
    A=axis;
    [ro.bins{best}(1) ro.bins{best}(end)],
    axis([0 1/tf min(A(3),-1) A(4)]);
    hold on;
    f1 = mean(co.f1vals{1}(:,best));
    f0=mean(co.f0vals{1}(:,best));
    t = 0:0.001:1/tf;
    %plot(t,f0,'g--');
    %plot(t,f0+real(f1*exp(sqrt(-1)*(2*pi-pi/2)*tf*t)),'r');
    plot([t],0*t,'k--');
    box off;
    plot([.05 .05],[0 10],'k-','linewidth',2);
    axis off;
end;

return;

if ~isempty(RW),
    hold off;
    h=myerrorbar(RW.data(1,:),RW.data(2,:),RW.data(4,:),RW.data(4,:),'b');
    %delete(h(2));  %if you want to delete the line connecting bars
    hold on;
    h=myerrorbar(RB.data(1,:),RB.data(2,:),RB.data(4,:),RB.data(4,:),'k');
    %delete(h(2));  %if you want to delete the line connecting bars
    plot([min(RW.data(1,:)) max(RW.data(1,:))], [x.data x.data], 'r--');
    
    A=axis;
    try,
        ymin=min([min(RB.data(2,:)-RB.data(4,:)) min(RW.data(2,:)-RW.data(4,:))])-1;
        ymax=max([max(RB.data(2,:)+RB.data(4,:)) max(RW.data(2,:)+RW.data(4,:))])+1;
        axis([min(RW.data(1,:)) max(RW.data(1,:)) ymin ymax]);
    catch, disp('error'); 
    end;
    text(min(RW.data(1,:)),ymin+0.6*(ymax-ymin),['NPotOverlap: ' num2str(ro.data,2)],'fontsize',8);
    text(min(RW.data(1,:)),ymin+0.7*(ymax-ymin),['lwvisp: ' num2str(z.data,2)],'fontsize',8);
    text(min(RW.data(1,:)),ymin+0.8*(ymax-ymin),['blackwhitefraction: ' num2str(p.data,2)],'fontsize',8);
    text(min(RW.data(1,:)),ymin+0.9*(ymax-ymin),['NAreaOverlap: ' num2str(q.data,2)],'fontsize',8);
    text(min(RW.data(1,:)),ymin+1.0*(ymax-ymin),['NormOverlap: ' num2str(v.data,2)],'fontsize',8);
    title(mycellname, 'interp', 'none');
    box off
end;

