function plotlineweightvsf1f0(prefix,expernames)

cells = {}; cellnames = {};


for i=1:length(expernames),
    disp(['Reading data from experiment ' expernames{i} '.']);    
    ds = dirstruct([prefix filesep expernames{i}]);
    [mycells,mycellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    cells = cat(2,cells,mycells); cellnames = cat(2,cellnames,mycellnames');
end;

f1f0=[];
NormOverlap=[];


for i=1:length(cells),
    rd = tsrelative_depth(cells{i})/1000;
    A=findassociate(cells{i},'SP F0 Ach normalized overlap','','');
    B=findassociate(cells{i},'SP F0 Ach lineweight visual response p','','');
    [f1f0r,ori,oi,tunewidth,cv] = f1f0ratio(cells{i});
    if ~isempty(rd)&~isempty(A)&~isempty(f1f0r),
        if B.data<0.05, 
            f1f0=[f1f0 f1f0r];
            NormOverlap=[NormOverlap A.data];
        end
    end;
end;

plot(NormOverlap, f1f0, 'bo');
[SLOPE,OFFSET,SLOPE_CONFINTERVAL,RESID, RESIDINT, STATS] = quickregression(NormOverlap',f1f0',.05);
SLOPE,SLOPE_CONFINTERVAL,STATS
hold on 
plot([0 1], OFFSET+SLOPE*[0 1], 'r--');
axis equal square
box off
axis([0 1 0 1])
xlabel('Normalized Overlap')
ylabel('F1/(F0+F1)')

