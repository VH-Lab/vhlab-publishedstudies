
prefix = 'e:\svanhooser\julielo\';
expnames = {'2009-08-18','2009-08-26','2009-09-22','2009-09-29'};

for i=1:length(expnames),
    ds = dirstruct([prefix expnames{i}]);
    [cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    
    for j=1:length(cells),
        T = findassociate(cells{j},'','','');
        if length(T)>10,
            figure;
            subplot(3,2,1);
            plotchr2response(cells{j},cellnames{j},'Orientation');
            subplot(3,2,2);
            plotchr2response(cells{j},cellnames{j},'Frequency');
            subplot(3,2,3);
            plotchr2response(cells{j},cellnames{j},'Contrast');
            subplot(3,2,4);
            plotchr2response(cells{j},cellnames{j},'Length');
            subplot(3,2,5);
            plotchr2response(cells{j},cellnames{j},'Aperature');
            subplot(3,2,6);
            plotchr2response(cells{j},cellnames{j},'Contrast2');
            
        end;
    end;
end;