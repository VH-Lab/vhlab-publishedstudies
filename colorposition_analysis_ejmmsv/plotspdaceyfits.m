function plotspdaceyfits(prefix,expernames)

cells = {}; cellnames = {};


for i=1:length(expernames),
    disp(['Reading data from experiment ' expernames{i} '.']);    
    ds = dirstruct([prefix filesep expernames{i}]);
    [mycells,mycellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    cells = cat(2,cells,mycells); cellnames = cat(2,cellnames,mycellnames');
end;

inc=10;

for i=1:length(cells),
    rd = tsrelative_depth(cells{i})/1000;
    A=findassociate(cells{i},'SP F0 CEDE Response curve','','');
    if ~isempty(rd)&~isempty(A),
        if inc==10, figure; inc=1; end;
        subplot(3,3,inc);
        plotspdacey(cells{i},cellnames{i});
        inc=inc+1;
    end;
end;
