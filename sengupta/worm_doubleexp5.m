function [P_nestedF]=worm_doubleexp2(S, T, Tshift)
% WORM_DOUBLEEXP - Fit the double exponential equation for 2 data sets in one go (Nested-F test)
%
%  [P_nested,P_nested2]=WORM_DOUBLEEXP2(S, T, Tshift)
%
%  S is the data; each column corresponds to a measurement at a different value of the vector
%  T, which has time values.
%  Tshift is the time shift for the data from the mutant condition
%
%  In interest of speed, I will do a poor job documenting (bad bad)

mn = nanmean(S)';
E = nanstderr(S)';
t = T(:);

signal_string_red4a = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*((1-exp(-t/a3)) )) + '  ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7*((1-exp(-abs(t-Tshift)/a9)))); ' ];

coeffs_red4a = {'a1','a2','a3','a6','a7','a9'};

g_red4a = fittype(signal_string_red4a,'coeff',coeffs_red4a,'indep','t','problem','Tshift');
fo_red4a = fitoptions('Method','NonlinearLeastSquares');
fo_red4a.Upper = [ 30 500 1000 10000 30 100 1000 ];
fo_red4a.Lower = [ -30 -500 0.5 10 -30 -100 1 ];
g_red4a = setoptions(g_red4a,fo_red4a);

[c_red4a,gof_red4a] = fit(t,mn,g_red4a,'problem',Tshift)

signal_string_red5 = [ 'transpose(stepfunc([0 Tshift 2*Tshift],[1 0],t)) .* (a1 + a2*((1-exp(-t/a3)) )) + '  ...
		  'transpose(stepfunc([0 Tshift 2*Tshift],[0 1],t)) .* (a6 + a7*((1-exp(-abs(t-Tshift)/a3)))); ' ];

coeffs_red5 = {'a1','a2','a3','a6','a7'};

g_red5 = fittype(signal_string_red5,'coeff',coeffs_red5,'indep','t','problem','Tshift');
fo_red5 = fitoptions('Method','NonlinearLeastSquares');
fo_red5.Upper = [ 30 500 1000 10000 30 100 ];
fo_red5.Lower = [ -30 -500 0.5 10 -30 -100 ];
g_red5 = setoptions(g_red5,fo_red5);

[c_red5,gof_red5] = fit(t,mn,g_red5,'problem',Tshift)


df_more = length(t) - 6; % let df be number of data points - number parameters
df_less = length(t) - 5; % same
SSE_moreP = gof_red4a.sse;
SSE_lessP = gof_red5.sse;
changeinerror = ((SSE_lessP - SSE_moreP)/SSE_moreP);
changeindegreesoffreedom = ((df_less-df_more)/df_more);
F = changeinerror / changeindegreesoffreedom;

P_nestedF = 1-fcdf(F,df_less-df_more,df_more);

% plot it

separator = find(t<Tshift,1,'last');

clf
h=myerrorbar(t,mn,E,E,'ko')
set(h(1),'linewidth',1);
hold on;
plot(t(1:separator),c_red5(t(1:separator)),'r-','linewidth',1);
plot(t(separator+1:end),c_red5(t(separator+1:end)),'r-','linewidth',1);
plot(t(1:separator),c_red4a(t(1:separator)),'g-');
plot(t(separator+1:end),c_red4a(t(separator+1:end)),'g-');

plot([0 1000],[mn(1) mn(1)],'k--','linewidth',2);

box off;
ylabel('Threshold (C)');
xlabel('Time (s)');


 % anova analysis

S_ = S;

S_(:,1:separator) = S_(:,1:separator)-c_red4a.a1;
S_(:,separator+1:end) = S_(:,separator+1:end)-c_red4a.a6;

Tbig = repmat(T(:)',size(S_,1),1);

G = ones(size(S_));
G(:,separator+1:end) = 2;
%keyboard
[P,table,STATS] = anova1(S_(:)', [Tbig(:)'],'off'); % Tbig(:)]);

figure;
multcompare(STATS);


figure;
semilogx(t(1:separator),c_red5(t(1:separator))-mn(1),'k-','linewidth',2);
hold on;
semilogx(t(separator+1:end)-Tshift,c_red5(t(separator+1:end))-mn(separator+1),'-','linewidth',2,'color',[0.5 0.5 0.5]);
h1=myerrorbar(t(1:separator),mn(1:separator)-mn(1),E(1:separator),E(1:separator),'ko');
set(h1(1),'linewidth',1);
h2=myerrorbar(t(separator+1:end)-Tshift,mn(separator+1:end)-mn(separator+1),E(separator+1:end),E(separator+1:end),'ks');
set(h2(1),'linewidth',1);
set(h2,'color',[0.5 0.5 0.5]);
xlabel('Time (minutes)');
ylabel('T_ (^\circ C)');
box off;


