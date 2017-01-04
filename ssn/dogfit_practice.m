function dogfit_practice

 % let's say we have a curve with max rate 5 
 % from 1 to 40 degrees in 30 steps
 % let's say maxr is at location 20 degrees

x = linspace(1,40,30);

maxr = 5;
locmaxr = (15);
minr = 0;
locminr = 1;
[minx,locminx] = min(x);
[maxx,locmaxx] = max(x);
rend = 0;

lowerlimit = [-5 0 minx 0 0 -10000 -10000];
upperlimit = [ 5 1 maxx 10000 1 10000 10000];

a1 = maxr;
a2 = rand;
a3 = 0.5*x(locmaxr)+rand*30;
a4 = rand*(maxr-rend);
a5 = rand;
a6 = x(locmaxr)+rand*30;
a7 = rand;

dfit = a1*(erf(a2*(x-a3))/2 + 0.5)-a4*(erf(a5*(x-a6))/2 + a7);

plot(x,dfit);

xlabel('X - degrees');
ylabel('Response');
