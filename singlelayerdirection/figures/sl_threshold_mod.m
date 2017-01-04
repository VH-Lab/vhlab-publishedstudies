function sl_threshold_mod

alpha = 4.5941e8;
GSynAP_20 = 0.00000000713888861239;   % 7.1e-9

figure;
subplot(3,2,1);

plot([0 15],[0 15],'g-');
hold on;
plot([0 15],alpha*GSynAP_20+[0 15],'r');
box off;
ylabel('R_{up}');
xlabel('R_{down}');

Wji = GSynAP_20 + 1e-9*[0 2 4 6];
Wij = GSynAP_20 + 1e-9*[-2];

Rdown_axis = 0:15;
Rup_max = alpha*GSynAP_20+Rdown_axis;
DSI_max = (Rup_max - Rdown_axis)./(Rup_max + Rdown_axis);

Rup =   alpha*rectify(2*Wji-GSynAP_20) + alpha*2*rectify(Wij-GSynAP_20);
Rdown = alpha*rectify(2*Wij-GSynAP_20) + alpha*2*rectify(Wji-GSynAP_20);
DSI = (Rup-Rdown)./(Rup+Rdown);

plot(Rdown,Rup,'ko');
axis equal square;
axis([0 15 0 15]);

subplot(3,2,2);

plot(Rdown_axis,DSI_max,'b-');
hold on;
plot(Rdown,DSI,'ko');

xlabel('R_{down}');
ylabel('DSI');
box off;




subplot(3,2,5);

GSynAP = GSynAP_20 + [-2:2 ] * 1e-9;
alphas = alpha*GSynAP_20./GSynAP;

Wji = GSynAP_20 + 1e-9*[2];
Wij = GSynAP_20 + 1e-9*[-2];

Rup =     alphas.*rectify(2*Wji-GSynAP) + alphas.*2.*rectify(Wij-GSynAP);
Rdown =   alphas.*rectify(2*Wij-GSynAP) + alphas.*2.*rectify(Wji-GSynAP);
DSI = (Rup-Rdown)./(Rup+Rdown);

plot(Rdown_axis,Rup_max,'r-');
hold on;
plot(Rdown_axis,Rdown_axis,'g-');
plot(Rdown,Rup,'ko');
box off; 
axis equal square;
axis([0 15 0 15]);

subplot(3,2,6);

plot(Rdown_axis,DSI_max,'b-');
hold on;
plot(Rdown,DSI,'ko');
xlabel('R_{down}');
ylabel('DSI');
box off;


GSyn_AP_Vthresh55 = 7.1389e-09;
GSyn_slope_Vthresh55 = 4.6646e+08;
alphaT_Vthresh55 = 3.3300;

GSyn_AP_Vthresh50 = 9.6070e-09;
GSyn_slope_Vthresh50 = 3.6265e+08;
alphaT_Vthresh50 = 3.4839;


