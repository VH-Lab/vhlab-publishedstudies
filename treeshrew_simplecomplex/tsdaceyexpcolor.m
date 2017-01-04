function [SconeFrac] = f1f0ratio(cell)

cefitparamsnk=findassociate(cell,'SP F0 CEDE Color NK Fit Params','','');
cefitnk=findassociate(cell,'SP F0 CEDE Color NK Fit','','');
cer = findassociate(cell,'SP F0 CEDE Response curve','','');
ces = findassociate(cell,'SP F0 CEDE sig S cone','','');
cesv = findassociate(cell,'SP F0 CEDE visual response p','','');
ceb = findassociate(cell,'SP F0 CEDE Blank Response','','');

SconeFrac = []; 
if ~isempty(cefitparamsnk),
    if cesv.data<0.05, % start off w/ no filter
                    titlestr{3} = [' L = ' num2str(cefitparamsnk.data(1),2) ', S = ' num2str(cefitparamsnk.data(2),2) '.'...
                ', LC50=' num2str(cefitparamsnk.data(3),2) ', SC50=' num2str(cefitparamsnk.data(4),2) ...
                ', LN=' num2str(cefitparamsnk.data(5),2) ', SN=' num2str(cefitparamsnk.data(6),2) '.'];
        
        Stot = cefitparamsnk.data(2)*naka_rushton_func(1,cefitparamsnk.data(4),cefitparamsnk.data(6));
        Ltot = cefitparamsnk.data(1)*naka_rushton_func(1,cefitparamsnk.data(3),cefitparamsnk.data(5));
        SconeFrac = Stot/(abs(Ltot)+abs(Stot));
    end;
end;

