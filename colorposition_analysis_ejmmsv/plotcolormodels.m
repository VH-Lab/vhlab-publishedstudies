function plotcolormodels

x = -10:0.05:10; sigm = 1.6;

LONLY = [ 0*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod

SONLY = [ sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           0*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod
	   
SUMMER = [ 0.5*sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
           sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
           0*sin(x);    ];  % no rod input  % rod

OPPONENT = [ sin(x).*exp(-x.^2/(2*sigm^2)) ; % S
             sin(x+pi).*exp(-x.^2/(2*sigm^2))  % L
             0*sin(x)];  % no rod input

RF = {LONLY, SONLY, SUMMER, OPPONENT};
figure;
for i=1:length(RF),
	
	subplot(2,2,i);
	plot(RF{i}(1,:),'b--');
	hold on;
	plot(RF{i}(2,:),'g--');
	axis([0 length(x)+1 -1 1]);
	set(gca,'box','off','xtick',[],'ytick',[],'visible','off');
end;