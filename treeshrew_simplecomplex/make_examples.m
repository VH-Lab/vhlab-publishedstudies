function make_examples

X = [ -15:0.1:15 ];

figure;
 % lgn receptive field
 % difference of gaussians

A1 = 1;
S1 = 3;

A2 = -0.2;
S2 = 6;

y_lgn = [A1 * exp(-(X.^2)/(2*S1^2)) + A2 * exp(-(X.^2)/(2*S2^2))];
on_lgn = rectify(y_lgn);
off_lgn = rectify(-y_lgn);

subplot(2,2,1);

plot(X,on_lgn,'-','color',[0.7 0.7 0.7])
hold on;
plot(X,off_lgn,'k-');
plot(X,0,'k--');
box off;

 % simple cell

A1 = 1;
S1 = 6;
SF = 0.2;

y_simple = [A1 * exp(-(X.^2)/(2*S1^2)) .* sin(X * SF)];
on_simple = rectify(y_simple);
off_simple = rectify(-y_simple);

subplot(2,2,2);

plot(X,on_simple,'-','color',[0.7 0.7 0.7])
hold on;
plot(X,off_simple,'k-');
plot(X,0,'k--');
box off;


% complex cell
AC = 1;
S1 = 8;

y_complex = [A1 * exp(-(X.^2)/(2*S1^2)) ];
on_complex = rectify(y_complex);
off_complex = rectify(-y_complex);

subplot(2,2,3);

plot(X,on_complex,'-','color',[0.7 0.7 0.7])
hold on;
plot(X,off_complex,'k-');
plot(X,0,'k--');
box off;

subplot(2,2,4);

T = [0:0.001:2*pi];

plot(T,sin(T),'k-');
hold on;
plot(T,cos(T),'k-');
box off;

figure;
 % lgn receptive field
 % difference of gaussians

A1 = 1;
S1 = 20;

A2 = -0.7;
S2 = 6;

X2 = 0:0.1:60;

y_lgn = [A1 * exp(-(X2.^2)/(2*S1^2)) + A2 * exp(-(X2.^2)/(2*S2^2))];
on_lgn = rectify(y_lgn);
off_lgn = rectify(-y_lgn);

subplot(2,2,1);

plot(X2,on_lgn,'-','color',[0.7 0.7 0.7])
hold on;
plot(X2,off_lgn,'k-');
plot(X2,0,'k--');
box off;

 % 

A1 = 1;
S1 = 20;

A2 = -1;
S2 = 6;

X2 = 0:0.1:60;

y_lgn = [A1 * exp(-(X2.^2)/(2*S1^2)) + A2 * exp(-(X2.^2)/(2*S2^2))];
on_lgn = rectify(y_lgn);
off_lgn = rectify(-y_lgn);

subplot(2,2,2);

plot(X2,on_lgn,'-','color',[0.7 0.7 0.7])
hold on;
plot(X2,off_lgn,'k-');
plot(X2,0,'k--');
box off;

