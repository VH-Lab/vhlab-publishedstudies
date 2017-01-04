function [P,curve] = fit_simplecomplex_model;

numL4Pts = 100;
oris = [45 45+90 ];
phases = 0:pi/6:2*pi;
%sfs = [ 0.05 0.1 0.2 0.4 0.8 1.6];
sfs = [ 0.1 0.2 0.4 ];

contrasts = [0.16 0.32 0.64 1];
%contrasts = 1;
ori = 45;

xi=linspace(-7.5,7.5,numL4Pts);
yi=linspace(-7.5,7.5,numL4Pts);
[stimspacex,stimspacey] = meshgrid(xi,yi);

% make oriented gratings

stimoris = [];
for i=1:length(oris),
        for p=1:length(phases),
                stimoris = cat(3,stimoris,make_ori_grating(stimspacex,stimspacey,oris(i),0.05,phases(p)));
        end;
end;
[stimoris_on,stimoris_off] = compute_layer4_resp(stimoris);

stimsf = [];
for s=1:length(sfs),
        for p=1:length(phases),
                stimsf = cat(3,stimsf,make_ori_grating(stimspacex,stimspacey,ori,sfs(s),phases(p)));
        end;
end;
[stimsf_on,stimsf_off] = compute_layer4_resp(stimsf);

%P0 = [ 4/100 0 1 ];
%P0 = [0.0580 0 1];
%P0 = [1.1278 0 1 0.3285];
%P0 = [1.1278  0.34 10]*100;
P0 = [1.1372    0.3428   10.2500];
simplecomplex_globals;
%l4gain = 0.0580;
P = fminsearch(@(P) mymodelerr(P,stimoris_on,stimoris_off,stimsf_on,stimsf_off,oris,contrasts,phases,sfs),P0);
[err] = mymodelerr(P,stimoris_on,stimoris_off,stimsf_on,stimsf_off,oris,contrasts,phases,sfs);
curve = [];

simplecomplex_globals;
P = P/100;
l4gain = abs(P(1));l4inhGain = abs(P(2));
%l4FFiT = P(2); l4FFiG = abs(P(3));
l4inhTau = abs(P(3));

function [err] = mymodelerr(P,stimoris_on,stimoris_off,stimsf_on,stimsf_off,oris,contrasts,phases,sfs);

err = 0;

SFx = [ 0.05 0.2 0.5 ];
%SFr = [ 0 40 0];
SFr = [ 0 40 ];

%c = [0.04 0.08 0.16 0.32 0.64 1];
OTr = [ 12 0 ; 20 0;  35 0; 40 0];
%OTr = [ 40 0];
%OTr = [ 12 ; 20 ;  35 ; 40 ];
connmethod = 'unielongffinhib';

simplecomplex_globals;
P = P/100;
l4gain = abs(P(1));l4inhGain = abs(P(2));
%l4FFiT = P(2); l4FFiG = abs(P(3));
l4inhTau = abs(P(3));

if 0,
 % now compute responses
l4resp = [];
for c=1:length(contrasts),
	[layer4ONinput,layer4OFFinput] = compute_layer4_input(45,0,connmethod,stimoris_on*contrasts(c),stimoris_off*contrasts(c));
	l4resp=[l4resp ;
		mean(reshape(layer4ONinput,length(phases),length(oris)))+mean(reshape(layer4OFFinput,length(phases),length(oris)))];
end;

curve = l4resp;
l4resp(find(l4resp<0&OTr==0)) = 0;
err = sum(sum(  (l4resp - OTr).^2));
P,l4resp,err,
return;
end;
[layer4ONinput,layer4OFFinput] = compute_layer4_input(45,0,connmethod,stimsf_on,stimsf_off);
l4resp2 = mean(reshape(layer4ONinput,length(phases),length(sfs)))+mean(reshape(layer4OFFinput,length(phases),length(sfs)));

%curve = [reshape(l4resp,1,2) l4resp2];
curve = [l4resp2];
%curve = [];
%D = [0 15 30 20 0 0];
D = [15 30 20];
err = err + sum( (l4resp2-D).^2);

P,l4resp2,err,

