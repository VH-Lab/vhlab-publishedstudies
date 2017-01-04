function rd = tsrelative_depth(cell)

A1=findassociate(cell,'depth','','');
A2=findassociate(cell,'Layer 4 boarder depths','','');
A3=findassociate(cell,'Putative Layer','','');

rd = [];

if ~isempty(A1)&~isempty(A2),
    depth = A1.data;
    if ischar(depth), depth = str2nume(depth); end;
    if length(A2.data)==2,
        rd = fix(rescale(depth,A2.data,[950 1350],1));
    elseif length(A2.data)==3,
        if depth>A2.data(3),
            rd = fix(rescale(depth,A2.data(2:3),[950 1350],1));   
        else, rd = fix(interp1(A2.data,[0 950 1350],depth,'linear'));
        end;
    end;
elseif ~isempty(A3),
    switch A3.data,
        case 'LGN6',
            rd = 2.0;
        case {'LGN4','LGN5'},
            rd = 2.4;
        case {'LGN1','LGN2'},
            rd = 2.133;
        case 'LGN3',
            rd = 2.2667;
    end;
    if ~isempty(rd), rd = (rd + 0.01)*1000; end;
end;
