function chr2_oscores

z = load('scores.mat');
peaks = z.peaks;
scores = z.scores;

bins = [ 0:1:20 ];
bin_centers = bins + 0.5;

N=histc(scores,bins);

figure;
subplot(2,1,1);
bar(bin_centers,N,1);
xlabel('Oscillation score');
ylabel('Counts');
box off;

bins2 = [ 6:2:50 ];
bin_centers2 = bins2 + 1;
N2 = histc(peaks,bins2),

subplot(2,1,2);
bar(bin_centers2,N2,1);
xlabel('Peak (Hz)');
ylabel('Counts');
box off;

