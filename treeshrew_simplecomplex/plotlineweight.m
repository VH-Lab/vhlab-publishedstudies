function plotlineweight(mycell,mycellname)


RW=findassociate(mycell,'SP F0 Ach lineweight white response curve','','');
RB=findassociate(mycell,'SP F0 Ach lineweight black response curve','','');

ro=findassociate(mycell,'SP F0 Ach normalized potential overlap','','');
z=findassociate(mycell,'SP F0 Ach lineweight visual response p','','');
p=findassociate(mycell,'SP F0 Ach black white fraction','','');
q=findassociate(mycell,'SP F0 Ach normalized area overlap','','');
x=findassociate(mycell,'SP F0 Ach lineweight threshold','','');
v=findassociate(mycell,'SP F0 Ach normalized overlap','','');


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

