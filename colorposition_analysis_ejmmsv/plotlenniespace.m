function plotlenniespace

Az = 0:1:359;


Sc = -sin(Az*pi/180);
Mc = -cos(Az*pi/180);
Lc = cos(Az*pi/180);

figure;
subplot(3,1,1);
plot(Az,Sc,'b'); 
hold on;
plot(Az,Mc,'g');
plot(Az,Lc,'r');
box off

subplot(3,1,2);
plot(Az,Sc,'b'); 
hold on;
plot(Az,0.5*(Mc+Lc),'y');
plot(Az,0.5*(Mc-Lc),'m');
box off
