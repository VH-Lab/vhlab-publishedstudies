function plot_sl_predicted(fig, m, alpha, thresh)


X = [0:100];

R_down_min = X;
if m<2, error(['this function only makes sense if m > 1']); end;
R_up_max = X + (m-1+1*(m-2))*alpha*thresh;

DSI_max = (R_up_max-R_down_min)./(R_up_max+R_down_min);
DI_max = (R_up_max-R_down_min)./(R_up_max);

subplot(2,2,1);
A = axis;
hold on;
plot(X,R_up_max,'r-');
plot(X,R_down_min,'y-');
axis(A);

subplot(2,2,2);
A = axis;
hold on;
plot(X,DI_max,'r-');
axis(A);

subplot(2,2,3);
A = axis;
hold on;
plot(X,DSI_max,'r-');
axis(A);

subplot(2,2,4);
A = axis;
hold on;
plot(X,DSI_max,'r-');
axis(A);
