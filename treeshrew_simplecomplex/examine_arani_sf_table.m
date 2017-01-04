function [percents, numbers] = examine_arani_sf_table(simple_table, complex_table, multiplier)

 % do a histogram for simple cells, all cells

N = size(simple_table,1) + size(complex_table,2),

BWs = simple_table(:,6);
BWc = complex_table(:,6);

BWs(find(isnan(simple_table(:,4)))) = -Inf;
BWs(find(isnan(simple_table(:,5)))) = Inf;
BWc(find(isnan(complex_table(:,4)))) = -Inf;
BWc(find(isnan(complex_table(:,5)))) = Inf;

BW = [BWs; BWc];

bins = [-Inf 0 1 2 3 4 5 6 Inf];
percent_simple = histc(BWs,bins) / N,
percent_total = histc(BW,bins) / N,

graphheight_simple = multiplier*histc(BWs,bins) / N,
graphheight_total = multiplier*histc(BW,bins) / N,

