t0=0;dt=1e-4;t1=1; N=50; theta = -pi/2:(pi/N):pi/2-pi/N;
% use dydt_1_3 for parts 1-3, dydt_4 for the other part
W=1./(N)*((J0+J2*cos(2*((cumsum(repmat(pi/N,N,N))'+repmat(((pi/2-2*pi/N):-(pi/N):(-pi/2-pi/N))',1,N))+pi/2+pi/N))));

if 1,  % #1
n=0; J0=-7.3;J2=11; C=0.04;e=0.1; Ie=40*C*(1-e+e*cos(2*(theta)))';
r=zeros(N,1); [t,r]=rk4(r,t0,dt,t1,Ie,W,n);
subplot(3,2,1); hold off; plot(theta,Ie); subplot(3,2,2); hold off; plot(theta,r(:,end));
n=0; J0=-7.3;J2=11; C=0.08;e=0.1; Ie=40*C*(1-e+e*cos(2*(theta)))'; r=zeros(N,1); [t,r]=rk4(r,t0,dt,t1,Ie,W,n);r1=r;
subplot(3,2,1); hold on; plot(theta,Ie,'r'); subplot(3,2,2); hold on; plot(theta,r(:,end),'r');
n=0; J0=-7.3;J2=11; C=0.16;e=0.1; Ie=40*C*(1-e+e*cos(2*(theta)))'; r=zeros(N,1); [t,r]=rk4(r,t0,dt,t1,Ie,W,n);
subplot(3,2,1); hold on; plot(theta,Ie,'g'); subplot(3,2,2); hold on; plot(theta,r(:,end),'g');
n=0; J0=-7.3;J2=11; C=0.32;e=0.1; Ie=40*C*(1-e+e*cos(2*(theta)))'; r=zeros(N,1); [t,r]=rk4(r,t0,dt,t1,Ie,W,n);
subplot(3,2,1); hold on; plot(theta,Ie,'k'); subplot(3,2,2); hold on; plot(theta,r(:,end),'k');
subplot(3,2,1); xlabel('Angle (radians)'); ylabel('Input current (nA)'); title('Input current');
subplot(3,2,2); xlabel('Angle (radians)'); ylabel('Firing rate (Hz)'); title('Steady-state network activity');
subplot(3,2,3); plot(theta,W(:,26),'b'); hold on; plot([-pi/2 pi/2],[0 0],'--'); xlabel('Angle (radians)');
                ylabel('Weight'); title('Connections from 0 rad to others');
subplot(3,2,4); hold off; plot(t(1:1000),r(26,1:1000),'b'); hold on; plot(t(1:1000),10*r(13,1:1000),'g');
                          plot(t(1:1000),10*r(1, 1:1000),'k'); title('Timecourse of response.');
			ylabel('Firing rate (Hz)'); xlabel('Time (s)');
subplot(3,2,6);hold off; plot(t(1:1000),r1(26,1:1000)/r1(26,end)); hold on; plot(t(1:1000),r(26,1:1000)/r(26,end),'k');
title('Normalized responses of 8%, 32% contrast'); ylabel('Normalized firing rate'); xlabel('Time (s)');
end;

