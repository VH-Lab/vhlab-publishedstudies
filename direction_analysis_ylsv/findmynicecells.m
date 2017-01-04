function findmynicecells(tpf)


ds = dirstruct(tpf);
[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

DIRB = []; DIRA = [];
MXRB = []; MXRA = [];
IND = [];

for i=1:length(cells),
    dirb = findassociate(cells{i},'TP Ach OT Fit Direction index blr','','');
    dira = findassociate(cells{i},'TP ME Ach OT Fit Direction index blr','','');
    goodb = findassociate(cells{i},'TP Ach OT vec varies p','','');
    gooda = findassociate(cells{i},'TP ME Ach OT vec varies p','','');
    if ~isempty(dirb)&~isempty(dira)&gooda.data<0.05&goodb.data<0.05,
        IND(end+1) = i;
        DIRB(end+1) = dirb.data;
        DIRA(end+1) = dira.data;
        resp = findassociate(cells{i},'TP Ach OT Response curve','','');
        respa = findassociate(cells{i},'TP ME Ach OT Response curve','','');
        MXRB(end+1)= max(resp.data(2,:));
        MXRA(end+1) = max(respa.data(2,:));
    end;
end;

keyboard;