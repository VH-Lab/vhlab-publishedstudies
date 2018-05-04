function mousevision_ciplot(output)

figure;

plot(1,output.CI{1},'ko');
hold on
plot([0.6 1.4],[0 0],'k--','linewidth',1);

mn = mean(output.CI{1});

plot([0.8 1.2],[mn mn],'k-','linewidth',2);

axis([0 2 -1 1]);

box off;
