function layer=tscelllayer(cell)

A = findassociate(cell,'Putative Layer','','');

layer = [];

if ~isempty(A),
    switch(A.data),
        case {'2','3'},
            layer = 2;
        case {'4a','4b','4m'},
            layer = 4;
        case {'5','6'},
            layer = 5;
    end;
end;

