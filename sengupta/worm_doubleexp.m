function [P_nestedF,P_nestedF2]=worm_doubleexp(S, T, Tshift)
% WORM_DOUBLEEXP - Fit the double exponential equation for 2 data sets in one go (Nested-F test)
%
%  [P_nested,P_nested2]=WORM_DOUBLEEXP(S, T, Tshift)
%
%  S is the data; each column corresponds to a measurement at a different value of the vector
%  T, which has time values.
%  Tshift is the time shift for the data from the mutant condition
%
%  In interest of speed, I will do a poor job documenting (bad bad)

mn = nanmean(S)';
E = nanstderr(S)';
t = T(:);

% Full model

signal_string_full = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*(1-exp(-t/min(a3,a5))) + a4*(1-exp(-t/max(a3,a5)))) + ' ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7* (1-exp(-abs(t-Tshift)/min(a8,a10))) + a9 * (1-exp(-abs(t-Tshift)/max(a8,a10)))); ' ];

coeffs_full = {'a1','a2','a3','a4','a5','a6','a7','a8','a9','a10'};

g_full = fittype(signal_string_full,'coeff',coeffs_full,'indep','t','problem','Tshift');
fo_full = fitoptions('Method','NonlinearLeastSquares');
fo_full.Upper = [ 30 100 100 100 10000 30 100 100 100 10000 ];
fo_full.Lower = [ -30 -100 1 -100 10 -30 -100 1 -100 100 ];
g_full = setoptions(g_full,fo_full);

[c_full,gof_full] = fit(t,mn,g_full,'problem',Tshift)

% Model where there is only 1 largest time constant

signal_string_red = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*(1-exp(-t/a3)) + a4*(1-exp(-t/max(a3,a5)))) + '  ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7* (1-exp(-abs(t-Tshift)/a8)) + a9 * (1-exp(-abs(t-Tshift)/max(a8,a5)))); ' ];

coeffs_red = {'a1','a2','a3','a4','a5','a6','a7','a8','a9'};

g_red = fittype(signal_string_red,'coeff',coeffs_red,'indep','t','problem','Tshift');
fo_red = fitoptions('Method','NonlinearLeastSquares');
fo_red.Upper = [ 30 100 100 100 10000 30 100 100 100];
fo_red.Lower = [ -30 -100 1 -600 10 -30 -100 1 -100];
g_red = setoptions(g_red,fo_red);

[c_red,gof_red] = fit(t,mn,g_red,'problem',Tshift)

% nested F test, from my class, Lab 2.2

df_more = length(t) - 10; % let df be number of data points - number parameters
df_less = length(t) - 9; % same
SSE_moreP = gof_full.sse;
SSE_lessP = gof_red.sse;
changeinerror = ((SSE_lessP - SSE_moreP)/SSE_moreP);
changeindegreesoffreedom = ((df_less-df_more)/df_more);
F = changeinerror / changeindegreesoffreedom;

P_nestedF = 1-fcdf(F,df_less-df_more,df_more);


% Model where there is only 1 smallest time constant

signal_string_red2 = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*(1-exp(-t/a3)) + a4*(1-exp(-t/max(a3,a5)))) + '  ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7* (1-exp(-abs(t-Tshift)/a3)) + a9 * (1-exp(-abs(t-Tshift)/max(a3,a10)))); ' ];

coeffs_red2 = {'a1','a2','a3','a4','a5','a6','a7','a9','a10'};

g_red2 = fittype(signal_string_red2,'coeff',coeffs_red2,'indep','t','problem','Tshift');
fo_red2 = fitoptions('Method','NonlinearLeastSquares');
fo_red2.Upper = [ 30 100 100 100 10000 30 100 100 10000];
fo_red2.Lower = [ -30 -100 1 -100 10 -30 -100 -100 10 ];
g_red2 = setoptions(g_red2,fo_red2);

[c_red2,gof_red2] = fit(t,mn,g_red2,'problem',Tshift)


df_more = length(t) - 10; % let df be number of data points - number parameters
df_less = length(t) - 9; % same
SSE_moreP = gof_full.sse;
SSE_lessP = gof_red2.sse;
changeinerror = ((SSE_lessP - SSE_moreP)/SSE_moreP);
changeindegreesoffreedom = ((df_less-df_more)/df_more);
F = changeinerror / changeindegreesoffreedom;

P_nestedF2 = 1-fcdf(F,df_less-df_more,df_more);

signal_string_red3 = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*((1-exp(-t/min(a3,a5))) + a4*(1-exp(-t/max(a3,a5))))) + '  ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7* ((1-exp(-abs(t-Tshift)/min(a3,a5))) + a9 * (1-exp(-abs(t-Tshift)/max(a3,a5))))); ' ];

coeffs_red3 = {'a1','a2','a3','a4','a5','a6','a7','a9'};

g_red3 = fittype(signal_string_red3,'coeff',coeffs_red3,'indep','t','problem','Tshift');
fo_red3 = fitoptions('Method','NonlinearLeastSquares');
fo_red3.Upper = [ 30 200 200 200 10000 30 200 200 ];
fo_red3.Lower = [ -30 -200 0.1 -200 10 -30 -200 -200 ];
g_red3 = setoptions(g_red3,fo_red3);

[c_red3,gof_red3] = fit(t,mn,g_red3,'problem',Tshift)


% plot it

separator = find(t<Tshift,1,'last');

clf
h=myerrorbar(t,mn,E,E,'ko')
set(h(1),'linewidth',1);
hold on;
plot(t(1:separator),c_full(t(1:separator)),'r-','linewidth',1);
plot(t(separator+1:end),c_full(t(separator+1:end)),'r-','linewidth',1);
plot(t(1:separator),c_red(t(1:separator)),'g-');
plot(t(separator+1:end),c_red(t(separator+1:end)),'g-');
plot(t(1:separator),c_red2(t(1:separator)),'m-');
plot(t(separator+1:end),c_red2(t(separator+1:end)),'m-');
plot(t(1:separator),c_red3(t(1:separator)),'k-','linewidth',2);
plot(t(separator+1:end),c_red3(t(separator+1:end)),'k-','linewidth',2);

plot([0 1000],[mn(1) mn(1)],'k--','linewidth',2);

box off;
ylabel('Threshold (C)');
xlabel('Time (s)');


 % anova analysis

S_ = S;

S_(:,1:separator) = S_(:,1:separator)-c_red3.a1;
S_(:,separator+1:end) = S_(:,separator+1:end)-c_red.a6;

Tbig = repmat(T(:)',size(S_,1),1);

G = ones(size(S_));
G(:,separator+1:end) = 2;
%keyboard
[P,table,STATS] = anova1(S_(:)', [Tbig(:)'],'off'); % Tbig(:)]);

figure;
multcompare(STATS);


t1_sep = t(1):t(separator);
tsep_end = t(separator+1):t(end);

figure;
plot(t1_sep,c_red3(t1_sep)-mn(1),'k-','linewidth',2);
hold on;
plot(tsep_end-Tshift,c_red3(tsep_end)-mn(separator+1),'-','linewidth',2,'color',[0.5 0.5 0.5]);
h1=myerrorbar(t(1:separator),mn(1:separator)-mn(1),E(1:separator),E(1:separator),'ko');
set(h1(1),'linewidth',1);
h2=myerrorbar(t(separator+1:end)-Tshift,mn(separator+1:end)-mn(separator+1),E(separator+1:end),E(separator+1:end),'ks');
set(h2(1),'linewidth',1);
set(h2,'color',[0.5 0.5 0.5]);
xlabel('Time (minutes)');
ylabel('Change in Th from Th(0) (^\circ C)');
box off;


figure;
plot(t1_sep,c_full(t1_sep)-mn(1),'k-','linewidth',2);
hold on;
plot(tsep_end-Tshift,c_full(tsep_end)-mn(separator+1),'-','linewidth',2,'color',[0.5 0.5 0.5]);
h1=myerrorbar(t(1:separator),mn(1:separator)-mn(1),E(1:separator),E(1:separator),'ko');
set(h1(1),'linewidth',1);
h2=myerrorbar(t(separator+1:end)-Tshift,mn(separator+1:end)-mn(separator+1),E(separator+1:end),E(separator+1:end),'ks');
set(h2(1),'linewidth',1);
set(h2,'color',[0.5 0.5 0.5]);
xlabel('Time (minutes)');
ylabel('Change in Th from Th(0) (^\circ C)');
title('Full model')
box off;


