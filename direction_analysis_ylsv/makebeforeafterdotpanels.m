function makebeforeafterdotpanels(beforewithafterfig, afterfig)

 % copy axes with image of before with all cells drawn (including those
 % after in red).  After fig should just have all cells in the after view.
 % yellow highlighted cell should not be a cell in the field
 
delete(findobj(beforewithafterfig,'color',[1 1 0]));
delete(findobj(afterfig,'color',[1 1 0]));
delete(findobj(beforewithafterfig,'visible','off'));
delete(findobj(afterfig,'visible','off'));
delete(findobj(beforewithafterfig,'type','text'));
delete(findobj(afterfig,'type','text'));


afterax = findobj(afterfig,'type','axes');
beforeax = findobj(beforewithafterfig,'type','axes');
redguys = findobj(beforeax,'type','line','color',[1 0 0]);

set(redguys,'parent',afterax);

figure(beforewithafterfig);
lns = findobj(beforewithafterfig,'type','line');

for i=1:length(lns),
    patch(get(lns(i),'xdata'),get(lns(i),'ydata'),get(lns(i),'color'));
end;

delete(lns);

figure(afterfig);

lns = findobj(afterfig,'type','line');

for i=1:length(lns),
    patch(get(lns(i),'xdata'),get(lns(i),'ydata'),get(lns(i),'color'));
end;

delete(lns);

figure(afterfig); set(gca,'visible','off'); axis([0 512 0 512]);

figure(beforewithafterfig); set(gca,'visible','off'); axis([0 512 0 512]);