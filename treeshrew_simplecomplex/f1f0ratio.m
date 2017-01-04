function [f1f0,dirpref,oiind,tunewidth,cv,di,sig_ori,dicv] = f1f0ratio(cell)

A1 = findassociate(cell,'SP F0 Ach OT visual response p','','');
A2 = findassociate(cell,'SP F0 Ach OT Carandini Fit','','');
A3 = findassociate(cell,'SP F1 Ach OT Carandini Fit','','');
A4 = findassociate(cell,'SP F0 Ach OT Response struct','','');

A5 = findassociate(cell,'SP F0 Ach OT Tuning width','','');
A6 = findassociate(cell,'SP F1 Ach OT Tuning width','','');
A7 = findassociate(cell,'SP F0 Ach OT Circular variance','','');
A8 = findassociate(cell,'SP F1 Ach OT Circular variance','','');
A9 = findassociate(cell,'SP F0 Ach OT Orientation index','','');
A10 = findassociate(cell,'SP F1 Ach OT Orientation index','','');
A11 = findassociate(cell,'SP F0 Ach OT Fit Direction index blr','','');
A12 = findassociate(cell,'SP F1 Ach OT Fit Direction index blr','','');
A13 = findassociate(cell,'SP F0 Ach OT vec varies p','','');
A14 = findassociate(cell,'SP F1 Ach OT vec varies p','','');



f1f0 = []; dirpref = []; oiind = []; tunewidth = []; cv = []; di =[];  dicv = [];
sig_ori = [];
if ~isempty(A1)&~isempty(A2)&~isempty(A3)&~isempty(A4),
    if A1.data<1, % start off w/ no filter
        [mxf0,indf0]=max(A2.data(2,:)-A4.data.spont(1));
        [mxf1,indf1]=max(A3.data(2,:));
        if mxf0>mxf1,
            ind = indf0;
            oiind=fit2fitoi(A2.data, 0);
            oiind=A9.data;
            tunewidth=A5.data;
            cv = A7.data;
            di = A11.data;
            sig_ori = A13.data;
            dicv = cell2dircircular_variance(cell, 'SP F0 Ach');
        else,
            ind = indf1;
            oiind=fit2fitoi(A3.data, 0);
            oiind=A10.data;
            tunewidth = A6.data;
            cv = A8.data;
            di = A12.data;
            sig_ori = A14.data;
            dicv = cell2dircircular_variance(cell, 'SP F1 Ach');
        end;
        dirpref = A2.data(1,ind);
        f1f0 = A3.data(2,ind)./(A2.data(2,ind)+A3.data(2,ind));
    end;
    if A1.data>0.05, tunewidth = 90; end;
end;
