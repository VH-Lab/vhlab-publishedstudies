function plotchr2otprefs(cells)

OTpref = [];
CHOTpref = [];

for i=1:length(cells),
    A = findassociate(cells{i},'SP F0 1 Ach OT Fit Pref','','');
    B = findassociate(cells{i},'SP F0 2 Ach OT Fit Pref','','');
    C = findassociate(cells{i},'SP F0 1 Ach OT varies p','','');
    D = findassociate(cells{i},'SP F0 2 Ach OT varies p','','');
       %if ~isempty(A)&~isempty(B),
            %OTpref(end+1) = A.data;
            %CHOTpref(end+1) = B.data;
       %end;
       if ~isempty(A)&& ~isempty(B),
           if (C.data < 0.05) && (D.data < 0.05),
              OTpref(end+1) = A.data;
              CHOTpref(end+1) = B.data;
           end
       end       
    
end;

plot(OTpref,CHOTpref,'ko');
ylabel('OT Pref, ChR2'); xlabel('OT Pref, vis only');
